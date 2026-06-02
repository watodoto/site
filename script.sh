#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
    echo "How the fuck do you not have bash installed. HOW???"
    exit 1
fi

# ---------------- CONFIG ----------------

wifi_tag="\e[36m(WI-FI!)\e[0m"

quotes=(
    "100% skidded"
    "furrychrome."
    "carbonbreaker!"
    "buzzword buzzword,"
    "please STOP!"
    "lol."
    "odd numbers suck"
    "hey that hurts! :("
    "unique text here"
    "son im crine"
    "modmium coming never"
    "modmium coming NOW"
    "battery_cutoff_request=1"
    "spooky scary didybluds"
    "unenrollment speedrun."
    "skid skid skid sahur"
    "mmm chezburger"
    "500 cigarettes"
    "i use pujjo btw."
    "speed kills a fan."
)

quote="${quotes[RANDOM % ${#quotes[@]}]}"

# ---------------- CENTER ----------------
center() {
    local text="$1"
    local width="$2"

    if (( ${#text} > width )); then
        text="${text:0:width}"
    fi

    local pad_left=$(( (width - ${#text}) / 2 ))
    local pad_right=$(( width - ${#text} - pad_left ))

    printf "%*s%s%*s" "$pad_left" "" "$text" "$pad_right" ""
}

# ---------------- HEADER ----------------
draw_header() {
    local left="Simple AIO Script"
    local right="v1.0.1"
    local by="by wato"

    local L=21

    echo "┌─────────────────────┬──────┐"
    echo "│$(center "$left" $L)│$right│"
    echo "│$(center "$by" $L)└──────┤"
}

# ---------------- ENROLLMENT SCREEN ----------------
menu_enrollment() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│      Enrollment options      │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Temp-unenroll in devmode │"
        echo -e "│ (w) Launch Cr3nroll $wifi_tag │"
        echo "│ (e) Back                     │"
        echo "└──────────────────────────────┘"

        read -rp "Select an option: " e_choice

        case "$e_choice" in
            q)
                read -rp "Are you sure? (y/n): " confirm

                case "$confirm" in
                    y|Y)
                        echo "mount --bind /dev/null /tmp/machine-info"
                        echo "initctl restart ui"
                        echo "Success!"
                        read -rp "Press enter to go back..."
                        ;;
                    *)
                        echo "Cancelled."
                        read -rp "Press enter to go back..."
                        ;;
                esac
                ;;

            w)
                clear
                curl -fsSL "https://raw.githubusercontent.com/CrOSmium/Cr3nroll/refs/heads/main/cr3nroll.sh" | sudo bash
                ;;  

            e)
                break
                ;;

            *)
                echo "Invalid option."
                read -rp "Press enter to continue..."
                ;;
        esac
    done
}

# ---------------- FIRMWARE SCREEN ----------------
menu_firmware() {
    while true; do
        clear

echo "┌──────────────────────────────────┐"
echo "│         Firmware options         │"
echo "├──────────────────────────────────┤"
echo -e "│ (q) GBB bash-inator $wifi_tag      │" 
echo -e "│ (w) MrChromebox Utility $wifi_tag │"
echo "│ (e) WP + GBB Information         │"
echo "│ (r) Back                         │"
echo "└──────────────────────────────────┘"

        read -rp "Select an option: " f_choice

        case "$f_choice" in
            q)
                clear
                curl -fsSL "https://raw.githubusercontent.com/watodoto/aio/refs/heads/main/gbb.sh" | bash
                ;;
            w)
                clear
                curl -fsSL "https://mrchromebox.tech/firmware-util.sh" | sudo bash
                ;;  
            e)

inner_w=24
label_w=12
value_w=$((inner_w - label_w - 3))

                gsc_output=$(gsctool -a -I 2>/dev/null)

                # ---- Software WP ----
                sw_wp=$(flashrom --wp-status 2>/dev/null | awk -F': ' '/Protection mode/ {print $2}')
                sw_wp=${sw_wp:-unset}

                # ---- crossystem WP ----
                cs_raw=$(crossystem wpsw_cur 2>/dev/null)
                if [[ "$cs_raw" == "1" ]]; then
                    cs_wp="enabled"
                elif [[ "$cs_raw" == "0" ]]; then
                    cs_wp="disabled"
                else
                    cs_wp="unset"
                fi

                # ---- gsctool ----
                if echo "$gsc_output" | grep -q "OverrideWP.*Y Always"; then
                    gsctool_wp="override"
                else
                    gsctool_wp=$(echo "$gsc_output" | awk '/State:/ {print $2}')
                    gsctool_wp=${gsctool_wp:-unset}
                fi

                # ---- GBB placeholders ----
                gbb_value="unset"
                gbb_modified="unset"

                # ---- BOX ----
                echo
                echo "┌────────────────────────┐"
                echo "│      WP/GBB info:      │"
                echo "├────────────────────────┤"
                echo "│ Write-protection:      │"
                printf "│ %-12s %*s │\n" "gsctool:" "$value_w" "$gsctool_wp"
                printf "│ %-12s %*s │\n" "crossystem:" "$value_w" "$cs_wp"
                printf "│ %-12s %*s │\n" "flashrom:" "$value_w" "$sw_wp"
                echo "├────────────────────────┤"
                echo "│ GBB Flags:             │"
                printf "│ %-12s %*s │\n" "Value:"    "$value_w" "$gbb_value"
                printf "│ %-12s %*s │\n" "Modified:" "$value_w" "$gbb_modified"
                echo "└────────────────────────┘"
                echo

                read -rp "Press enter to go back..."
                ;;

            r)
                break
                ;;

            *)
                echo "Invalid option."
                read -rp "Press enter to continue..."
                ;;
        esac
    done
}

# ---------------- MAIN MENU ----------------
draw_menu() {
    clear

    draw_header

    echo "├────────────────────────────┤"
    echo "│$(center "\"$quote\"" 28)│"
    echo "├────────────────────────────┤"
    echo "│ (q) Enrollment             │"
    echo "│ (w) Firmware               │"
    echo "│ (e) Wi-fi                  │"
    echo "│ (r) Miscellaneous          │"
    echo "│ (t) Exit                   │"
    echo "└────────────────────────────┘"
}

pause() {
    read -rp "Placeholder. You shouldn't be here. Get out."
}

# ---------------- MAIN LOOP ----------------
while true; do
    draw_menu

    read -rp "Select an option: " choice

    case "$choice" in
        q)
            menu_enrollment
            ;;
        w)
            menu_firmware
            ;;
        e|r)
            pause
            ;;
        t)
            clear
            exit 0
            ;;
        *)
            echo "Invalid option."
            pause
            ;;
    esac
done