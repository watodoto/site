#!/bin/bash

# ---------------- DATA CONFIG ----------------
gbb_names=(
    "DEV_SCREEN_SHORT_DELAY"
    "LOAD_OPTION_ROMS"
    "ENABLE_ALTERNATE_OS"
    "FORCE_DEV_SWITCH_ON"
    "FORCE_DEV_BOOT_USB"
    "DISABLE_FW_ROLLBACK_CHECK"
    "ENTER_TRIGGERS_TONORM"
    "FORCE_DEV_BOOT_ALTFW"
    "DEPRECATED_RUNNING_FAFT"d
    "DISABLE_EC_SOFTWARE_SYNC"
    "DEFAULT_DEV_BOOT_ALTFW"
    "DISABLE_AUXFW_SOFTWARE_SYNC"
    "DISABLE_LID_SHUTDOWN"
    "FORCE_UNLOCK_FASTBOOT"
    "FORCE_MANUAL_RECOVERY"
    "DISABLE_FWMP"
    "ENABLE_UDC"
    "FORCE_CSE_SYNC"
)

gbb_descs=(
    "Reduce the dev screen delay to 2 sec from 30 sec. Beep is also removed."
    "[Unsupported] BIOS should load option ROMs from arbitrary PCI devices."
    "[Unsupported] Boot a non-ChromeOS kernel."
    "Force dev switch on, regardless of physical/keyboard dev switch. Be careful; this does not bypass FWMP."
    "Allow booting from external disk even if dev_boot_usb=0."
    "Disable firmware rollback protection."
    "Allow Enter key to trigger dev->tonorm screen transition."
    "Allow booting altfw OSes even if dev_boot_altfw=0."
    "[Deprecated] Currently running FAFT tests. Should not normally be set."
    "Disable EC software sync."
    "Default to booting altfw OS when dev screen times out."
    "Disable auxiliary firmware (auxfw) software sync."
    "Disable shutdown on lid closed."
    "Allow full fastboot capability even in verified mode, and regardless of OEM lock."
    "Recovery mode always assumes manual recovery, even if EC_IN_RW=1."
    "Ignore FWMP."
    "Enable USB Device Controller."
    "Always sync CSE, even if it is same as CBFS CSE."
)

# ---------------- STATE ----------------
gbb_states=()
for ((i=0; i<${#gbb_names[@]}; i++)); do
    gbb_states+=(0)
done

total_flags=${#gbb_names[@]}
current_index=0

# ---------------- TERMINAL SETUP ----------------
orig_tty=$(stty -g 2>/dev/null || echo "")

stty -echo -icanon min 1 time 0

# ---------------- CLEANUP (IMPORTANT FIX) ----------------
cleanup() {
    printf "\e[?25h\e[0m"
    if [[ -n "$orig_tty" ]]; then
        stty "$orig_tty" 2>/dev/null
    fi
    clear
    exit 0
}
trap cleanup EXIT INT TERM

# ---------------- BITWISE ----------------
calc_gbb_hex() {
    local hex_val=0
    for i in "${!gbb_names[@]}"; do
        [[ "${gbb_states[$i]}" == "1" ]] && (( hex_val |= (1 << i) ))
    done
    printf "0x%X" "$hex_val"
}

decode_gbb_hex() {
    local input_val="${1#0x}"
    [[ -z "$input_val" ]] && return

    local dec_val=$((16#$input_val))

    for i in "${!gbb_names[@]}"; do
        if (( (dec_val & (1 << i)) != 0 )); then
            gbb_states[$i]=1
        else
            gbb_states[$i]=0
        fi
    done
}

# ---------------- INPUT ----------------
read_key() {
    local key rest

    IFS= read -rsn1 key || return

    [[ -z "$key" ]] && return

    if [[ "$key" == $'\e' ]]; then
        IFS= read -rsn2 -t 0.001 rest || rest=""
        key+="$rest"
    fi

    INPUT_KEY="$key"
}

# ---------------- DRAW ----------------
draw_interface() {
    printf "\e[H\e[?25l"

    local current_hex
    current_hex=$(calc_gbb_hex)

    local desc_lines=()
    while read -r line; do
        desc_lines+=("$line")
    done < <(echo "${gbb_descs[$current_index]}" | fold -s -w 49)

    echo "┌───────────────────────────────────┬───────────────────────────────────────────────────┐"
    echo "│      GBB-flaginator in Bash!      │ Press enter to select, Use arrows to navigate.    │"
    echo "├───────────────────────────────────┤ Press E to exit the tool!                         │"

    for i in "${!gbb_names[@]}"; do
        local marker=" "
        [[ $i -eq $current_index ]] && marker=">"

        local box="[ ]"
        [[ "${gbb_states[$i]}" == "1" ]] && box="[x]"

        local left_content
        left_content=$(printf "%s %s %-27s" "$marker" "$box" "${gbb_names[$i]}")

        local right_content=""
        local sep=0

        case "$i" in
            0) right_content=" Press D to decode flags.                          │" ;;
            1) right_content="───────────────────────────────────────────────────┤"; sep=1 ;;
            2) right_content=$(printf " Flags: %-42s │" "$current_hex") ;;
            3) right_content="───────────────────────────────────────────────────┤"; sep=1 ;;
            4) right_content=$(printf " %-49s │" "${gbb_names[$current_index]:0:49}") ;;
            5) right_content=$(printf " %-49s │" "${desc_lines[0]:-}") ;;
            6) right_content=$(printf " %-49s │" "${desc_lines[1]:-}") ;;
            7) right_content=$(printf " %-49s │" "${desc_lines[2]:-}") ;;
            8) right_content="───────────────────────────────────────────────────┘"; sep=1 ;;
            *) right_content="" ;;
        esac

        if (( i <= 8 )); then
            if (( sep )); then
                printf "│ %s ├%s\n" "$left_content" "$right_content"
            else
                printf "│ %s │%s\n" "$left_content" "$right_content"
            fi
        else
            printf "│ %s │\n" "$left_content"
        fi
    done

    echo "└───────────────────────────────────┘"
}

# ---------------- MAIN LOOP ----------------
clear
printf "\e[?25l"

while true; do
    draw_interface
    read_key

    case "$INPUT_KEY" in
        s|S|$'\e[B')
            (( current_index < total_flags - 1 )) && ((current_index++))
            ;;
        w|W|$'\e[A')
            (( current_index > 0 )) && ((current_index--))
            ;;
        $'\n'|$'\r')
            (( gbb_states[current_index] ^= 1 ))
            ;;
d|D)
    printf "\e[?25h"
    printf "\nEnter hex string (ex. 0x18019): "

    # temporarily restore canonical mode JUST for input
    stty sane
    read -r user_input

    # restore TUI mode
    stty -echo -icanon min 1 time 0

    if [[ "$user_input" =~ ^(0x)?[0-9a-fA-F]+$ ]]; then
        decode_gbb_hex "$user_input"
    fi

    printf "\e[?25l"
    ;;
        e|E)
            cleanup
            ;;
    esac

    sleep 0.02
done
