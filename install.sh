#!/bin/bash
#
# install-ubuntu-dev.sh - Tux4Ubuntu Installer
#
# Copyright (C) 2017 Tux4Ubuntu Initiative <http://tux4ubuntu.blogspot.com>
#
# Permission is hereby granted, free of charge,
# to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to
# deal in the Software without restriction, including
# without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom
# the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice
# shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
# ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Written and designed by: Tuxedo Joe <http://github.com/tuxedojoe>
# for The Tux4Ubuntu Initiative <http://tux4ubuntu.blogspot.com>
#
# For CREDITS AND ATTRIBUTION see README

# Change directory to same as script is running in
cd "$(dirname "$0")"
# Adds error handling by exiting at first error
set -e
# Cleans the screen
printf "\033c"
# Set global values
STEPCOUNTER=false # Sets to true if user choose to install Tux Everywhere
OS_VERSION="";
# Here we check if OS is supported
# More info on other OSes regarding plymouth: http://brej.org/blog/?p=158
YELLOW='\033[1;33m'
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

function install_chromium {
    printf "\033c"
    package_name="Chrome/Chromium"
    header "Installing ${package_name^^}" "$1"

    if ask_install "Chrome (Chromium is up next)"; then
        check_sudo
        sudo apt-get install libxss1 libappindicator1 libindicator7

        wget -P /tmp/chrome-install/ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i /tmp/chrome-install/google-chrome*.deb
        echo ""
        printf "${LIGHT_GREEN}Successfully installed Chrome${NC}\n"
    fi

    if ask_install "Chromium"; then
        check_sudo
        install_if_not_found "chromium-browser"
        sudo update-alternatives --config x-www-browser
        printf "${LIGHT_GREEN}Successfully installed $package_name${NC}\n"
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function install_vsc {

    printf "\033c"
    package_name="Visual Studio Code"
    header "Installing ${package_name^^}" "$1"
    if ask_install "$package_name"; then
        check_sudo
	install_if_not_found "curl"
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
        sudo mv /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt-get update || true
        sudo apt-get install code # or code-insiders

        printf "${LIGHT_GREEN}Successfully installed $package_name${NC}\n"
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function install_gimp {
    printf "\033c"
    package_name="GIMP Edge"
    header "Installing ${package_name^^}" "$1"
    if ask_install "$package_name"; then
        check_sudo
        sudo add-apt-repository ppa:otto-kesselgulasch/gimp-edge
        echo "Updating package list..."
        sudo apt update || true
        install_if_not_found "gimp gimp-gmic"

        printf "${LIGHT_GREEN}Successfully installed $package_name${NC}\n"
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function install_git_and_ssh_keys {
    printf "\033c"
    package_name="GIT + SSH keys"
    header "Installing ${package_name^^}" "$1"
    if ask_install "$package_name"; then
        check_sudo
        install_if_not_found "git xclip"

        echo "Enter your GIT username:"
        read username
        git config --global user.name "$username"

        echo "To set up GIT you need to enter a username and an email adress (preferably yours, but not necessarily)."
        echo "Enter your GIT e-mail:"
        read email_id
        git config --global user.email "$email_id"

        if [ ! -f ~/.ssh/id_rsa ]; then
            echo -ne '\n' | ssh-keygen || true
        else
            echo "~/.ssh/id_rsa already exists. Will use that one."
        fi

        ssh-add ~/.ssh/id_rsa || true

        ssh -T git@github.com || true

        xclip -sel clip < ~/.ssh/id_rsa.pub || true

        printf "${LIGHT_GREEN}Successfully installed $package_name${NC}\n"
        echo "Successfully installed GIT and ssh keys."
        echo ""
        echo "Your public ssh key is now copied to your clipboard."
        echo "Paste it (Ctrl + V) to your bitbucket/github account for ssh connection."
        echo ""
        echo "Once you done that, run: "
        echo "   - 'ssh -T git@github.com' to add github to known hosts"
        echo "   - 'ssh -T git@bitbucket.org' to add bitbucket to known hosts."

    fi
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function install_amazon_cli {
    printf "\033c"
    package_name="Amazon CLI"
    header "Installing ${package_name^^}" "$1"
    if ask_install "$package_name"; then
        check_sudo
        echo "Updating package list..."
        sudo apt-get update || true
        install_if_not_found "python3-pip"
        sudo pip3 install --upgrade pip

        sudo pip3 install --upgrade --user awscli
        echo ""
        printf "${LIGHT_GREEN}Successfully installed $package_name${NC}\n"
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function install_tilda {
   printf "\033c"
    package_name="Tilda (Drop-down terminal - F1)"
    header "Installing ${package_name^^}" "$1"
    if ask_install "$package_name"; then
        check_sudo
        sudo apt install tilda
        echo "Adding tilda to 'Startup applications'"
        if [ ! -f ~/.config/autostart/tilda.desktop ]; then
            mkdir ~/.config/autostart || true
            sudo cp tilda.desktop ~/.config/autostart/tilda.desktop
        else
            echo "~/.config/autostart/tilda.desktop already exists. It will autostart."
        fi
        /usr/bin/tilda &
        sleep 2
        echo ""
        printf "${LIGHT_GREEN}Successfully installed $package_name${NC}\n"
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key

}


function install_cursor {
    printf "\033c"
    echo "=========================================="
    echo "    Installing Cursor AI Editor on Linux"
    echo "=========================================="
    echo ""

    # Install required dependencies
    echo "📦 Installing required dependencies..."
    sudo apt update && sudo apt install -y libfuse2 ca-certificates

    # Search for the latest Cursor AppImage in ~/Downloads/
    latest_cursor_file=$(ls -t ~/Downloads/Cursor-*.AppImage 2>/dev/null | head -n 1)

    if [[ -n "$latest_cursor_file" ]]; then
        echo "🔍 Found a Cursor AppImage in Downloads:"
        echo "   👉 $latest_cursor_file"
        read -p "📂 Do you want to use this file? (Y/n): " use_found_file
        if [[ "$use_found_file" =~ ^[Nn]$ ]]; then
            latest_cursor_file=""
        fi
    fi

    # If no file was auto-detected or user rejected it, ask for input
    if [[ -z "$latest_cursor_file" ]]; then
        echo ""
        echo "⚠️  Cursor AI Editor does not provide a direct download link."
        echo "🔗  Please download the latest AppImage manually from: "
        echo "    👉  https://www.cursor.com/downloads"
        echo ""
        echo "💡 After downloading, locate the file path."
        echo "   You can use the command: pwd"
        echo "   If you downloaded to 'Downloads', the path is likely:"
        echo "   ~/Downloads/Cursor-<version>.AppImage"
        echo ""

        read -p "📂 Enter the full path to the Cursor AppImage file: " cursor_path
    else
        cursor_path="$latest_cursor_file"
    fi

    # Check if the file exists
    if [[ ! -f "$cursor_path" ]]; then
        echo "❌ Error: File not found at '$cursor_path'. Please try again."
        exit 1
    fi

    echo "✅ Found file at $cursor_path"

    # Create the /opt directory if it doesn't exist
    sudo mkdir -p /opt

    # Move the AppImage to /opt
    echo "🚚 Moving Cursor to /opt/cursor.appimage"
    sudo mv "$cursor_path" /opt/cursor.appimage
    sudo chmod +x /opt/cursor.appimage

    # Create desktop entry
    echo "🖥️  Creating desktop entry..."
    cat << EOF | sudo tee /usr/share/applications/cursor.desktop
[Desktop Entry]
Name=Cursor
Exec=/opt/cursor.appimage
Icon=/opt/cursor.png
Type=Application
Categories=Development;
EOF

    # Download icon
    echo "🎨 Downloading Cursor icon..."
    wget --tries=3 -O /tmp/cursor.png "https://raw.githubusercontent.com/getcursor/cursor/main/assets/icon.png"
    sudo mv /tmp/cursor.png /opt/cursor.png

    echo "🎉 Successfully installed Cursor AI Editor!"
    echo "🚀 You can now run Cursor from your Applications menu."
    echo "   Or start it manually with: /opt/cursor.appimage"
    echo ""
    echo "🔄 If you don't see the icon, log out and log back in."
}

function uninstall {
    while :
    do
        clear
        printf "\033c"
        # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
        printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
        printf "║ ${LIGHT_RED}TUX DEVTOOLS - UNINSTALLER${NC}                                 © 2018 Tux4Ubuntu ║\n"
        printf "║ Let's Pause Tux a Bit                                 https://tux4ubuntu.org ║\n"
        printf "╠══════════════════════════════════════════════════════════════════════════════╣\n"
        cat<<EOF
║                                                                              ║
║   What do you wanna uninstall? (Type in one of the following numbers)        ║
║                                                                              ║
║   A) All of it                                 - Uninstall all of the below  ║
║   ------------------------------------------------------------------------   ║
║   1) Chrome/Chromium                                                         ║
║   2) Visual Studio Code                                                      ║
║   3) GIMP Edge                                                               ║
║   4) GIT + SSH keys                                                          ║
║   5) Tilda                                                                   ║
║   6) Cursor                                                                  ║
║   ------------------------------------------------------------------------   ║
║   I) Back to installing                        - Go back to installer        ║
║   ------------------------------------------------------------------------   ║
║   Q) I'm done                                  - Quit the installer (Ctrl+C) ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
        read -n1 -s
        case "$REPLY" in
        "A")    # Uninstall everything
                STEPCOUNTER=true
                i=1
                uninstall_chromium $i
                ((i++))
                uninstall_vsc $i
                ((i++))
                uninstall_gimp $i
                ((i++))
                uninstall_git_and_ssh_keys $i
                ((i++))
                # uninstall_amazon_cli $i
                # ((i++))
                uninstall_tilda $i
                ((i++))
                uninstall_cursor $i
                ;;
        "a")    # Uninstall everything
                STEPCOUNTER=true
                i=1
                uninstall_chromium $i
                ((i++))
                uninstall_vsc $i
                ((i++))
                uninstall_gimp $i
                ((i++))
                uninstall_git_and_ssh_keys $i
                ((i++))
                # uninstall_amazon_cli $i
                # ((i++))
                uninstall_tilda $i
                ((i++))
                uninstall_cursor $i
                ;;
        "1")    uninstall_chromium ;;
        "2")    uninstall_vsc ;;
        "3")    uninstall_gimp ;;
        "4")    uninstall_git_and_ssh_keys;;
        "5")    uninstall_tilda ;;
        "6")    uninstall_cursor ;;
        "I")    break ;;
        "i")    break ;;
        "Q")    exit ;;
        "q")    exit ;;
         * )    echo "That's an invalid option. Try again." ;;
        esac
        sleep 1
    done
}

function uninstall_chromium {
    printf "\033c"
    package_name="Chrome/Chromium"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "Chrome (Chromium is up next)"; then
        check_sudo
        sudo apt-get remove google-chrome-stable || true
        sudo rm -r ~/.config/google-chrome || true
        echo ""
        printf "${LIGHT_GREEN}Successfully uninstalled Chrome${NC}\n"
    fi
    if ask_uninstall "Chromium"; then
        check_sudo
        uninstall_if_found "chromium-browser"
        sudo rm -r ~/.config/chromium-browser || true
        echo ""
        printf "${LIGHT_GREEN}Successfully uninstalled Chromium${NC}\n"
        sudo update-alternatives --config x-www-browser
    fi
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function uninstall_vsc {
    printf "\033c"
    package_name="Visual Studio Code"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "$package_name"; then
        check_sudo
        sudo apt-get purge code || true
        echo ""
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function uninstall_gimp {
    printf "\033c"
    package_name="GIMP Edge"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "$package_name"; then
        check_sudo
        install_if_not_found "ppa-purge"
        sudo ppa-purge ppa:otto-kesselgulasch/gimp-edge || true
        uninstall_if_found "gimp gimp-gmic"
    fi
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function uninstall_git_and_ssh_keys {
    printf "\033c"
    package_name="GIT + SSH keys"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "GIT (SSH keys is up next)"; then
        uninstall_if_found "git"
    fi
    if ask_uninstall "SSH keys"; then
        sudo rm ~/.ssh/id_rsa
        sudo rm ~/.ssh/id_rsa.pub
    fi
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}
function uninstall_amazon_cli {
    printf "\033c"
    package_name="Amazon CLI"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "$package_name"; then
        sudo pip3 uninstall awscli
    fi
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function uninstall_tilda {
    printf "\033c"
    package_name="Tilda (Drop-down terminal)"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "$package_name"; then
        uninstall_if_found "tilda"
        echo "Removing Tilda from 'Startup applications'"
        sudo rm ~/.config/autostart/tilda.desktop || true
    fi
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function uninstall_cursor {
    printf "\033c"
    package_name="Cursor AI Editor"
    header "Uninstalling ${package_name^^}" "$1"
    if ask_uninstall "$package_name"; then
        check_sudo

        # Remove application files
        sudo rm -f /opt/cursor.appimage
        sudo rm -f /opt/cursor.png
        sudo rm -f /usr/share/applications/cursor.desktop

        printf "${LIGHT_GREEN}Successfully uninstalled $package_name${NC}\n"
    fi

    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function check_sudo {
    if sudo -n true 2>/dev/null; then
        :
    else
        echo "Oh, and Tux will need sudo rights to copy and install everything, so he'll ask"
        echo "about that below."
        echo ""
    fi
}
function install_if_not_found {
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo -e "$pkg is already installed"
        else
            printf "${YELLOW}Installing $pkg.${NC}\n"
            if sudo apt-get -qq --allow-unauthenticated install $pkg; then
                printf "${YELLOW}Successfully installed $pkg${NC}\n"
            else
                printf "${LIGHT_RED}Error installing $pkg${NC}\n"
            fi
        fi
    done
}

function uninstall_if_found {
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo "Uninstalling $pkg."
            if sudo apt-get remove $pkg; then
                printf "${YELLOW}Successfully uninstalled $pkg${NC}\n"
            else
                printf "${LIGHT_RED}Error uninstalling $pkg${NC}\n"
            fi
        else
            printf "${LIGHT_RED}$pkg is not installed${NC}\n"
        fi
    done
}

function header {
    var_size=${#1}
    # 80 is a full width set by us (to work in the smallest standard terminal window)
    if [ $STEPCOUNTER = false ]; then
        # 80 - 2 - 1 = 77 to allow space for side lines and the first space after border.
        len=$(expr 77 - $var_size)
    else
        # "Step X/X " is 9
        # 80 - 2 - 1 - 9 = 68 to allow space for side lines and the first space after border.
        len=$(expr 68 - $var_size)
    fi
    ch=' '
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    printf "║"
    printf " ${YELLOW}$1${NC}"
    printf '%*s' "$len" | tr ' ' "$ch"
    if [ $STEPCOUNTER = true ]; then
        printf "Step "${LIGHT_GREEN}$2${NC}
        printf "/6 "
    fi
    printf "║\n"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

function ask_install {
    printf "Just double checking, you want to install $1?\n\n"
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                return 0
                break;;
            No )
                echo "Okay, skipping $1."
                return 1
                break;;
        esac
    done
}
function ask_uninstall {
    printf "Do you really want to uninstall $1?\n\n"
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                return 0
                break;;
            No )
                echo "Okay, leaving $1 as it is."
                return 1
                break;;
        esac
    done
}

while :
do
    clear
    # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
    printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
    printf "║ ${YELLOW}TUX DEVTOOLS ver 1.2${NC}                                       © 2018 Tux4Ubuntu ║\n"
    printf "║ Let's Bring TUX's Tools to Ubuntu                     https://tux4ubuntu.org ║\n"
    printf "╠══════════════════════════════════════════════════════════════════════════════╣\n"

    cat<<EOF
║                                                                              ║
║   What TUX developer tools do you want installed? (Press its number)         ║
║                                                                              ║
║   A) All of it                                 - Install all of the below    ║
║   ------------------------------------------------------------------------   ║
║   1) Chrome/Chromium                           - Adds another browser        ║
║   2) Visual Studio Code                        - Great free editor           ║
║   3) GIMP Edge                                 - Newest version of GIMP      ║
║   4) GIT + SSH keys                            - Version handling            ║
║   5) Tilda                                     - Drop-down terminal (F1)     ║
║   6) Cursor                                    - AI-powered code editor       ║
║   ------------------------------------------------------------------------   ║
║   U) Uninstall                                 - Uninstall the above         ║
║   ------------------------------------------------------------------------   ║
║   Q) I'm done                                  - Quit the installer (Ctrl+C) ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    read -n1 -s
    case "$REPLY" in
    "A")    # Install everything
            STEPCOUNTER=true
            i=1
            install_chromium $i
            ((i++))
            install_vsc $i
            ((i++))
            install_gimp $i
            ((i++))
            install_git_and_ssh_keys $i
            ((i++))
            # install_amazon_cli $i
            # ((i++))
            install_tilda $i
            ((i++))
            install_cursor $i
            ;;
    "a")    # Install everything
            STEPCOUNTER=true
            i=1
            install_chromium $i
            ((i++))
            install_vsc $i
            ((i++))
            install_gimp $i
            ((i++))
            install_git_and_ssh_keys $i
            ((i++))
            # install_amazon_cli $i
            # ((i++))
            install_tilda $i
            ((i++))
            install_cursor $i
            ;;
    "1")    install_chromium ;;
    "2")    install_vsc ;;
    "3")    install_gimp ;;
    "4")    install_git_and_ssh_keys;;
    # "5")    install_amazon_cli ;;
    "5")    install_tilda ;;
    "6")    install_cursor ;;
    "7")    get_the_tshirt ;;
    "U")    uninstall ;;
    "u")    uninstall ;;
    "Q")    break ;;
    "q")    break ;;
     * )    echo "That's an invalid option. Try again." ;;
    esac
    sleep 1
done
