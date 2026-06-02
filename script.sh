#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
    echo "How the fuck do you not have bash installed. HOW???"
    exit 1
fi

# When run via curl | bash, stdin is the pipe not the terminal.
# Reattach stdin to the terminal so all reads work correctly.
exec < /dev/tty

# ---------------- CONFIG ----------------

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

# ---------------- HELPERS ----------------

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

info_row() {
    local label="$1"
    local value="$2"
    local inner_w="$3"
    local label_w="$4"
    local value_w=$(( inner_w - label_w - 3 ))
    if (( ${#value} > value_w )); then
        value="${value:0:value_w}"
    fi
    printf "│ %-${label_w}s %${value_w}s │\n" "$label" "$value"
}

# Wrapper: prompt then read from /dev/tty, skip empty
tty_read() {
    local prompt="$1"
    local varname="$2"
    local val=""
    echo -n "$prompt"
    exec 3< /dev/tty
    while IFS= read -r val <&3; do
        [[ -n "$val" ]] && break
    done
    exec 3<&-
    printf -v "$varname" '%s' "$val"
}

# Read any key (including empty/enter) from /dev/tty — for "press enter to continue"
tty_anykey() {
    local msg="${1:-Press enter to continue...}"
    echo "$msg"
    read -r _ < /dev/tty
}

# ---------------- HEADER ----------------

draw_header() {
    local left="Simple AIO Script"
    local right="v1.0.1"
    local by="by wato"

    echo "┌─────────────────────┬──────┐"
    printf "│%s│%s│\n" "$(center "$left" 21)" "$right"
    printf "│%s├──────┤\n" "$(center "$by" 21)"
}

# ---------------- ENROLLMENT MENU ----------------

menu_enrollment() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│      Enrollment options      │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Temp-unenroll in devmode │"
        echo "│ (w) Launch Cr3nroll          │"
        echo "│ (e) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " e_choice

        case "$e_choice" in
            q)
                tty_read "Are you sure? (y/n): " confirm
                case "$confirm" in
                    y|Y)
                        mount --bind /dev/null /tmp/machine-info
                        initctl restart ui
                        echo "Success!"
                        tty_anykey "Press enter to go back..."
                        ;;
                    *)
                        echo "Cancelled."
                        tty_anykey "Press enter to go back..."
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
                tty_anykey
                ;;
        esac
    done
}

# ---------------- FIRMWARE MENU ----------------

menu_firmware() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│        Firmware options      │"
        echo "├──────────────────────────────┤"
        echo "│ (q) GBB Bash-inator          │"
        echo "│ (w) MrChromebox Utility      │"
        echo "│ (e) WP + GBB Information     │"
        echo "│ (r) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " f_choice

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
                clear

                local inner_w=24
                local label_w=11

                sw_wp=$(flashrom --wp-status 2>/dev/null | awk -F': ' '/Protection mode/ {print $2}')
                sw_wp="${sw_wp:-unknown}"

                cs_raw=$(crossystem wpsw_cur 2>/dev/null)
                case "$cs_raw" in
                    1) cs_wp="enabled"  ;;
                    0) cs_wp="disabled" ;;
                    *) cs_wp="unknown"  ;;
                esac

                gsc_output=$(gsctool -a -I 2>/dev/null)
                if echo "$gsc_output" | grep -q "OverrideWP.*Y Always"; then
                    gsctool_wp="override"
                else
                    gsctool_wp=$(echo "$gsc_output" | awk '/State:/ {print $2}')
                    gsctool_wp="${gsctool_wp:-unknown}"
                fi

                gbb_raw=$(futility gbb --get --flags 2>/dev/null | awk '/flags:/ {print $2}')
                if [[ -n "$gbb_raw" ]]; then
                    gbb_value="$gbb_raw"
                    if [[ "$gbb_raw" == "0x00000000" || "$gbb_raw" == "0x0" ]]; then
                        gbb_modified="no"
                    else
                        gbb_modified="yes"
                    fi
                else
                    gbb_value="unknown"
                    gbb_modified="unknown"
                fi

                echo
                echo "┌────────────────────────┐"
                echo "│      WP/GBB Info       │"
                echo "├────────────────────────┤"
                echo "│ Write-protection:      │"
                info_row "gsctool:"    "$gsctool_wp" "$inner_w" "$label_w"
                info_row "crossystem:" "$cs_wp"      "$inner_w" "$label_w"
                info_row "flashrom:"   "$sw_wp"      "$inner_w" "$label_w"
                echo "├────────────────────────┤"
                echo "│ GBB Flags:             │"
                info_row "Value:"    "$gbb_value"    "$inner_w" "$label_w"
                info_row "Modified:" "$gbb_modified" "$inner_w" "$label_w"
                echo "└────────────────────────┘"
                echo

                tty_anykey "Press enter to go back..."
                ;;
            r)
                break
                ;;
            *)
                echo "Invalid option."
                tty_anykey
                ;;
        esac
    done
}

# ---------------- WIFI MENU (stub) ----------------

menu_wifi() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│          Wi-Fi options       │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Coming soon...           │"
        echo "│ (w) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " w_choice

        case "$w_choice" in
            w)
                break
                ;;
            *)
                echo "Invalid option."
                tty_anykey
                ;;
        esac
    done
}

# ---------------- MISC MENU (stub) ----------------

menu_misc() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│      Miscellaneous options   │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Coming soon...           │"
        echo "│ (w) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " m_choice

        case "$m_choice" in
            w)
                break
                ;;
            *)
                echo "Invalid option."
                tty_anykey
                ;;
        esac
    done
}

# ---------------- MAIN MENU ----------------

draw_menu() {
    clear

    draw_header

    echo "├────────────────────────────┤"
    printf "│%s│\n" "$(center "\"$quote\"" 28)"
    echo "├────────────────────────────┤"
    echo "│ (q) Enrollment             │"
    echo "│ (w) Firmware               │"
    echo "│ (e) Wi-Fi                  │"
    echo "│ (r) Miscellaneous          │"
    echo "│ (t) Exit                   │"
    echo "└────────────────────────────┘"
}

# ---------------- MAIN LOOP ----------------

while true; do
    draw_menu

    tty_read "Select an option: " choice

    case "$choice" in
        q) menu_enrollment ;;
        w) menu_firmware   ;;
        e) menu_wifi       ;;
        r) menu_misc       ;;
        t)
            clear
            exit 0
            ;;
        *)
            echo "Invalid option."
            tty_anykey
            ;;
    esac
done
