#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
    echo "How the fuck do you not have bash installed. HOW???"
    exit 1
fi

# IF WE PIPE BASH DO NOT FUCK SHIT UP
[[ ! -t 0 ]] && exec < /dev/tty

# so funny ik
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
    "still thinking"
    "terminal magic"
    "saub my daub"
    "check out Nikki-VT2!"
    "gubby this, gubby that"
    "gubby server gubby lan"
    "Nothing There!"
    "HAPPY BDAY DANIEL!"
    "aura monster"
    "bin/bash"
    "quicksilver!"
    "sh1mmer!"
    "protowrite!!"
    "br0ker!!"
    "quote."
    "can you ctrl+c already"
)

quote="${quotes[RANDOM % ${#quotes[@]}]}"

# functions that chatgpt wrote because i hate centering shit
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

# read that tty
tty_read() {
    local prompt="$1"
    local varname="$2"
    local val

    read -rp "$prompt" val < /dev/tty
    printf -v "$varname" '%s' "$val"
}

# why
tty_anykey() {
    local msg="${1:-Press enter to go back...}"
    echo "$msg"
    read -r _ < /dev/tty
}

# wrtie stupid header for the menu buh
draw_header() {
    local left="Simple AIO Script"
    local right="v1.0.6" #something like that probably lol
    local by="by wato"

    echo "┌─────────────────────┬──────┐"
    printf "│%s│%s│\n" "$(center "$left" 21)" "$right"
    printf "│%s├──────┤\n" "$(center "$by" 21)"
}

# enrololing
menu_enrollment() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│      Enrollment options      │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Temp-unenroll in devmode │"
        echo "│ (w) Cr3nroll                 │"
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
                curl -fsSL "https://raw.githubusercontent.com/CrOSmium/Cr3nroll/refs/heads/main/cr3nroll.sh" -o /tmp/cr3nroll.sh && sudo bash /tmp/cr3nroll.sh
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

# hot!
menu_firmware() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│       Firmware options       │"
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
                curl -fsSL "https://raw.githubusercontent.com/watodoto/aio/refs/heads/main/gbb.sh" -o /tmp/gbb.sh && bash /tmp/gbb.sh
                ;;
            w)
                clear
                curl -fsSL "https://mrchromebox.tech/firmware-util.sh" -o /tmp/firmware-util.sh && sudo bash /tmp/firmware-util.sh
                ;;
            e)
                clear
                curl -fsSL "https://raw.githubusercontent.com/watodoto/aio/refs/heads/main/wp.sh" -o /tmp/wp.sh && sudo bash /tmp/wp.sh
                ;;
        esac
    done
}

# ok its dead now
menu_fun() {
    while true; do
        clear

        echo "┌───────────────────────────────┐"
        echo "│          Fun options          │"
        echo "├───────────────────────────────┤"
        echo "│ (q) Tetris                    │"
        echo "│ (w) Minesweeper               │"
        echo "│ (e) whale                     │"
        echo "│ (r) Back                      │"
        echo "└───────────────────────────────┘"

        tty_read "Select an option: " w_choice

        case "$w_choice" in
            q)
                curl -fsSL "https://raw.githubusercontent.com/dkorolev/bash-tetris/refs/heads/master/tetris.sh" -o /tmp/tetris.sh && bash /tmp/tetris.sh
                ;;
            w)
                curl -fsSL "https://raw.githubusercontent.com/feherke/Bash-script/refs/heads/master/minesweeper/minesweeper.sh" -o /tmp/minesweeper.sh && bash /tmp/minesweeper.sh
                ;;
            e)
                curl -fsSL "https://raw.githubusercontent.com/crosbreaker/badsh1mmer/refs/heads/main/badsh1mmer/scripts/whale.txt" -o /tmp/whale.txt && cat /tmp/whale.txt
                tty_anykey
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

# soon(tm)
menu_misc() {
    while true; do
        clear

        echo "┌───────────────────────────────┐"
        echo "│     Miscellaneous options     │"
        echo "├───────────────────────────────┤"
        echo "│ (q) Coming soon...            │"
        echo "│ (w) Back                      │"
        echo "└───────────────────────────────┘"

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

# god DAMN that main menu looks nice
draw_menu() {
    clear

    draw_header

    echo "├────────────────────────────┤"
    printf "│%s│\n" "$(center "\"$quote\"" 28)"
    echo "├────────────────────────────┤"
    echo "│ (q) Enrollment             │"
    echo "│ (w) Firmware               │"
    echo "│ (e) Miscellaneous          │"
    echo "│ (r) Fun                    │"
    echo "│ (t) Credits                │"
    echo "│ (y) Exit                   │"
    echo "└────────────────────────────┘"
}

# you know the drill
while true; do
    draw_menu

    tty_read "Select an option: " choice

    case "$choice" in
        q) menu_enrollment ;;
        w) menu_firmware   ;;
        e) menu_misc       ;;
        r) menu_fun        ;;
        y)
            clear
            exit 0
            ;;
        *)
            echo "Invalid option."
            tty_anykey
            ;;
    esac
done
