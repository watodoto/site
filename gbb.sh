#!/bin/bash

# When run via curl | bash, stdin is the pipe not the terminal.
[[ ! -t 0 ]] && exec < /dev/tty

# ---------------- DATA ----------------

gbb_names=(
    "DEV_SCREEN_SHORT_DELAY"
    "LOAD_OPTION_ROMS"
    "ENABLE_ALTERNATE_OS"
    "FORCE_DEV_SWITCH_ON"
    "FORCE_DEV_BOOT_USB"
    "DISABLE_FW_ROLLBACK_CHECK"
    "ENTER_TRIGGERS_TONORM"
    "FORCE_DEV_BOOT_ALTFW"
    "DEPRECATED_RUNNING_FAFT"
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
    "[Unsupported] Currently running FAFT tests. May enable workarounds in firmware, should not be set by the user."
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

gbb_states=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
total_flags=${#gbb_names[@]}
current_index=0

decode_mode=0
decode_input=""
decode_error=""

# ---------------- MATH ----------------

calc_hex() {
    local val=0
    for i in "${!gbb_states[@]}"; do
        if [[ ${gbb_states[$i]} -eq 1 ]]; then
            (( val |= (1 << i) ))
        fi
    done
    printf "0x%x" "$val"
}

decode_hex() {
    local input="${1#0x}"
    input="${input#0X}"
    [[ -z "$input" ]] && return 1
    [[ ! "$input" =~ ^[0-9a-fA-F]+$ ]] && return 1
    local dec=$(( 16#$input ))
    for i in "${!gbb_names[@]}"; do
        (( (dec & (1 << i)) != 0 )) && gbb_states[$i]=1 || gbb_states[$i]=0
    done
    return 0
}

# ---------------- WORD WRAP ----------------

wrap_text() {
    local text="$1"
    local width="$2"
    local line=""
    for word in $text; do
        if [[ -z "$line" ]]; then
            line="$word"
        elif (( ${#line} + 1 + ${#word} <= width )); then
            line="$line $word"
        else
            echo "$line"
            line="$word"
        fi
    done
    [[ -n "$line" ]] && echo "$line"
}

# ---------------- DRAW ----------------

L_INNER=35
R_INNER=51

# Print N copies of a character without spawning subprocesses
repeat_char() {
    local char="$1"
    local count="$2"
    local i
    for (( i=0; i<count; i++ )); do
        printf '%s' "$char"
    done
}

draw() {
    printf "\e[H"

    local hex
    hex=$(calc_hex)

    local flag_name="${gbb_names[$current_index]}"
    local flag_desc="${gbb_descs[$current_index]}"

    local wrap_width=$(( R_INNER - 2 ))
    local -a desc_lines
    while IFS= read -r dl; do
        desc_lines+=("$dl")
    done < <(wrap_text "$flag_desc" "$wrap_width")

    local -a right_content
    right_content[0]="Press ENTER to toggle selected flag."
    right_content[1]="Press E to exit the editor."
    right_content[2]="Press D to decode flags."
    right_content[3]=""
    right_content[4]="Flags: $hex"
    right_content[5]=""
    right_content[6]="$flag_name"
    for i in "${!desc_lines[@]}"; do
        right_content[$((7 + i))]="${desc_lines[$i]}"
    done

    # Right panel has a fixed height — pad to MAX_R_ROWS so it never shrinks
    # between flags and leaves ghost lines from longer descriptions
    local MAX_R_ROWS=11
    local r_rows=${#right_content[@]}
    # Pad right_content up to MAX_R_ROWS with empty strings
    for (( i=r_rows; i<MAX_R_ROWS; i++ )); do
        right_content[$i]=""
    done
    r_rows=$MAX_R_ROWS

    local total_rows=$(( total_flags > r_rows ? total_flags : r_rows ))

    # Top border
    printf "┌"
    repeat_char '─' $L_INNER
    printf "┬"
    repeat_char '─' $R_INNER
    printf "┐\n"

    # Header row
    local header_l="GBB-flaginator in Bash!"
    local header_pad_l=$(( (L_INNER - ${#header_l}) / 2 ))
    local header_pad_r=$(( L_INNER - ${#header_l} - header_pad_l ))
    printf "│%*s%s%*s│" "$header_pad_l" "" "$header_l" "$header_pad_r" ""
    printf " %-*s│\n" $(( R_INNER - 1 )) "${right_content[0]}"

    # Divider under header (left only, right panel continues open)
    printf "├"
    repeat_char '─' $L_INNER
    printf "┤"
    printf " %-*s│\n" $(( R_INNER - 1 )) "${right_content[1]}"

    # r_content_rows = number of rows the right panel content occupies inside the loop
    local r_content_rows=$(( r_rows - 2 ))

    # Flag rows
    for (( row=0; row<total_rows; row++ )); do
        if (( row < total_flags )); then
            local marker=" "
            [[ $row -eq $current_index ]] && marker=">"
            local box="[ ]"
            [[ ${gbb_states[$row]} -eq 1 ]] && box="[x]"
            local left_text
            left_text=$(printf "%s %s %-*s" "$marker" "$box" $(( L_INNER - 6 )) "${gbb_names[$row]}")
            printf "│%s│" "$left_text"
        else
            printf "│%-*s│" "$L_INNER" ""
        fi

        local r_idx=$(( row + 2 ))
        if (( row < r_content_rows - 1 )); then
            # Normal right panel content row
            printf " %-*s│\n" $(( R_INNER - 1 )) "${right_content[$r_idx]:-}"
        elif (( row == r_content_rows - 1 )); then
            # Last content row — print it then close the right box on the next line
            printf " %-*s│\n" $(( R_INNER - 1 )) "${right_content[$r_idx]:-}"
            # Right box bottom border (mid-table)
            printf "│%-*s└" "$L_INNER" ""
            repeat_char '─' $R_INNER
            printf "┘\n"
        else
            # Right panel closed, left column continues solo with no right border
            printf "\n"
        fi
    done

    # Bottom border — left column only (right already closed mid-table)
    printf "└"
    repeat_char '─' $L_INNER
    printf "┘\n"

    # Decode input line
    if [[ $decode_mode -eq 1 ]]; then
        printf "\e[K Decode flags: %s_" "$decode_input"
    elif [[ -n "$decode_error" ]]; then
        printf "\e[K \e[31m%s\e[0m" "$decode_error"
    else
        printf "\e[K\n"
    fi
}

# ---------------- CLEANUP ----------------

cleanup() {
    printf "\e[?25h"
    printf "\e[m"
    clear
    exit 0
}
trap cleanup SIGINT SIGTERM

# ---------------- MAIN LOOP ----------------

printf "\e[?25l"
clear

while true; do
    draw

    read -rsn1 key

    # Catch escape sequences (arrow keys)
    if [[ $key == $'\e' ]]; then
        read -rsn2 -t 0.1 key2
        key="$key$key2"
    fi

    if [[ $decode_mode -eq 1 ]]; then
        case "$key" in
            $'\n'|$'\r')
                if decode_hex "$decode_input"; then
                    decode_error=""
                else
                    decode_error="Invalid hex input."
                fi
                decode_input=""
                decode_mode=0
                ;;
            $'\x7f'|$'\b')
                decode_input="${decode_input%?}"
                ;;
            $'\e')
                decode_input=""
                decode_mode=0
                decode_error=""
                ;;
            *)
                if [[ "$key" =~ ^[0-9a-fA-FxX]$ ]]; then
                    decode_input="$decode_input$key"
                fi
                ;;
        esac
        continue
    fi

    case "$key" in
        $'\e[A')
            (( current_index > 0 )) && (( current_index-- ))
            decode_error=""
            ;;
        $'\e[B')
            (( current_index < total_flags - 1 )) && (( current_index++ ))
            decode_error=""
            ;;
        $'\n'|$'\r')
            if [[ ${gbb_states[$current_index]} -eq 1 ]]; then
                gbb_states[$current_index]=0
            else
                gbb_states[$current_index]=1
            fi
            ;;
        d|D)
            decode_mode=1
            decode_input=""
            decode_error=""
            ;;
        e|E)
            cleanup
            ;;
    esac
done
