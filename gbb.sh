#!/bin/bash

# ---------------- DATA CONFIG ----------------
gbb_names=(
    "DEV_SCREEN_SHORT_DELAY" "FORCE_DEV_SWITCH_ON" "FORCE_DEV_BOOT_USB"
    "DISABLE_FW_ROLLBACK_CHECK" "ENTER_TRIGGERS_TONORM" "FORCE_DEV_BOOT_ALTFW"
    "DISABLE_EC_SOFTWARE_SYNC" "DEFAULT_DEV_BOOT_ALTFW" "DISABLE_AUXFW_SOFTWARE_SYNC"
    "DISABLE_LID_SHUTDOWN" "FORCE_UNLOCK_FASTBOOT" "FORCE_MANUAL_RECOVERY"
    "DISABLE_FWMP" "ENABLE_UDC" "FORCE_CSE_SYNC"
)

gbb_descs=(
    "Reduce the dev screen delay to 2 sec from 30 sec. Beep is also removed."
    "Force dev switch on, regardless of physical/keyboard dev switch. Be careful; this does not bypass FWMP."
    "Allow booting from external disk even if dev_boot_usb=0."
    "Disable firmware rollback protection."
    "Allow Enter key to trigger dev->tonorm screen transition."
    "Allow booting altfw OSes even if dev_boot_altfw=0."
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

# Parallel state array (0 = empty, 1 = checked)
gbb_states=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
total_flags=${#gbb_names[@]}
current_index=0

# ---------------- BITWISE MATH FUNCTIONS ----------------
calc_gbb_hex() {
    local hex_val=0
    for i in "${!gbb_names[@]}"; do
        if [[ ${gbb_states[$i]} -eq 1 ]]; then
            (( hex_val |= (1 << i) ))
        fi
    done
    printf "0x%X" "$hex_val"
}

decode_gbb_hex() {
    local input_val="${1#0x}"
    [[ -z "$input_val" ]] && return
    
    # Base-16 hexadecimal conversion evaluation
    local dec_val=$((16#$input_val))
    for i in "${!gbb_names[@]}"; do
        if (( (dec_val & (1 << i)) != 0 )); then
            gbb_states[$i]=1
        else
            gbb_states[$i]=0
        fi
    done
}

# ---------------- DRAW ENGINE ----------------
draw_interface() {
    # Send cursor to home positions (0,0) instead of clear to prevent layout flicker
    printf "\e[H"
    
    local current_hex=$(calc_gbb_hex)
    
    # Pre-wrap descriptions cleanly inside boundary limit (49 characters)
    local desc_lines=()
    while read -r line; do
        desc_lines+=("$line")
    done < <(echo "${gbb_descs[$current_index]}" | fold -s -w 49)

    # Top Headers
    echo "┌───────────────────────────────────┬───────────────────────────────────────────────────┐"
    echo "│      GBB-flaginator in Bash!      │ Press I over the selected flag to view more info. │"
    echo "├───────────────────────────────────┤ Press E to exit the editor.                       │"

    # Main Grid Mapping Loop
    for i in "${!gbb_names[@]}"; do
        local marker=" "
        [[ $i -eq $current_index ]] && marker=">"
        
        local box="[ ]"
        [[ ${gbb_states[$i]} -eq 1 ]] && box="[x]"
        
        local left_content=$(printf "%s %s %-27s" "$marker" "$box" "${gbb_names[$i]}")
        local right_content=""

        case "$i" in
            0) right_content=$(printf " Press D to decode flags.                          │") ;;
            1) right_content=$(printf "───────────────────────────────────────────────────┤") ;;
            2) right_content=$(printf " Flags: %-43s │" "$current_hex") ;;
            3) right_content=$(printf "───────────────────────────────────────────────────┤") ;;
            4) right_content=$(printf " %-49s │" "${gbb_names[$current_index]:0:49}") ;;
            5) right_content=$(printf " %-49s │" "${desc_lines[0]:-}") ;;
            6) right_content=$(printf " %-49s │" "${desc_lines[1]:-}") ;;
            7) right_content=$(printf " %-49s ┘" "${desc_lines[2]:-}") ;;
            *) right_content="" ;;
        esac

        # Render combined screen borders safely based on row position indices
        if (( i <= 6 )); then
            echo "│ $left_content │$right_content"
        elif (( i == 7 )); then
            echo "│ $left_content │$right_content"
        else
            echo "│ $left_content │"
        fi
    done
    echo "└───────────────────────────────────┘"
}

# ---------------- TERMINAL CLEANUP TRAP ----------------
# Force cleanup even if the user breaks the terminal execution with Ctrl+C
cleanup() {
    printf "\e[?25h" # Re-enable standard terminal cursor state
    clear
    exit 0
}
trap cleanup SIGINT SIGTERM

# ---------------- APPLICATION START ----------------
printf "\e[?25l" # Hide terminal blinking cursor asset during list browsing
clear

while true; do
    draw_interface
    
    printf "\e[KEnter flags to decode: "
    read -rsn1 input_key

    case "$input_key" in
        s|S)
            (( current_index < total_flags - 1 )) && (( current_index++ ))
            ;;
        w|W)
            (( current_index > 0 )) && (( current_index-- ))
            ;;
        " ")
            if [[ ${gbb_states[$current_index]} -eq 1 ]]; then
                gbb_states[$current_index]=0
            else
                gbb_states[$current_index]=1
            fi
            ;;
        d|D)
            printf "\e[?25h" # Re-enable cursor so they can see what they type
            printf "\n\e[K➔ Enter hex string (e.g., 0x18019): "
            read -r user_input
            
            if [[ "$user_input" =~ ^(0x)?[0-9a-fA-F]+$ ]]; then
                decode_gbb_hex "$user_input"
            fi
            
            printf "\e[?25l" # Re-hide cursor
            clear
            ;;
        e|E)
            cleanup
            ;;
    esac
done
