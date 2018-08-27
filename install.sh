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
if [[ `lsb_release -rs` == "16.04" ]]
then
    # The plymouth dir was moved in one update, therefore we have prepared for this one here
    plymouth_dir="/usr/share/plymouth"
    OS_VERSION="16.04"
    sleep 1
elif [[ `lsb_release -rs` == "16.10" ]]
    plymouth_dir="/usr/share/plymouth"
    OS_VERSION="16.10"
then
	plymouth_dir="/usr/share/plymouth"
else
	echo "Sorry! We haven't tried installing Tux4Ubuntu on your Linux distrubtion."
    echo "Make sure you have the latest version at http://tux4ubuntu.blogspot.com"	
    echo "(Or fork/edit our project/install-ubuntu.sh for your system, and then make a"
    echo "pull request/send it to us so that more people can use it)"
    echo ""
    echo "Want to go ahead anyway? (Can be a bumby ride, but it might work flawless)"
    echo ""
    echo "(Type 1 or 2, then press ENTER)"            
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) printf "\033c"
                echo "Ahh, a brave one! Tux salutes you!"
                echo "(If you get any error message, copy/paste on our website/stackoverflow"
                echo "and if it works, please write a comment on our start page and let us know)"
                echo ""
                read -n1 -r -p "Press any key to continue..." key
               	# We set the plymouth directory here 
                plymouth_dir="/usr/share/plymouth"
                break;;
            No ) printf "\033c"
                echo "Feel free to try when you're ready. Tux will be waiting."
                echo ""
                read -n1 -r -p "Press any key to continue..." key
                exit
                break;;
        esac
    done
fi

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
        echo "Successfully installed Chrome."
    fi

    if ask_install "Chromium"; then
        check_sudo
        install_if_not_found "chromium-browser"
        sudo update-alternatives --config x-www-browser

        echo "$package_name is installed."
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

        echo "$package_name is installed."
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

        echo "$package_name is installed."
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
        echo "$package_name is installed."
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
        echo "$package_name is installed."
    fi
    
    echo ""
    read -n1 -r -p "Press any key to continue..." key

}

function tux_installer {
    # Local/Github folder (comment out the other one if you're working locally)
    ../tux-install/tux4ubuntu-menu.sh
    #~/Projects/Tux4Ubuntu/src/tux-desktop-theme/install.sh $1
}

function uninstall {
    while :
    do
        clear
        printf "\033c"
        # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
        LIGHT_RED='\033[1;31m'
        NC='\033[0m' # No Color
        printf "╔══════════════════════════════════════════════════════════════════════════════╗\n"
        printf "║ ${LIGHT_RED}TUX 4 UBUNTU - Developer - UNINSTALL${NC}            © 2017 Tux4Ubuntu Initiative ║\n"                       
        printf "║ Let's Pause Tux a Bit                         http://tux4ubuntu.blogspot.com ║\n"
        printf "╠══════════════════════════════════════════════════════════════════════════════╣\n"
        cat<<EOF    
║                                                                              ║
║   What do you wanna uninstall? (Type in one of the following numbers)    ║
║                                                                              ║
║   1) All of it                                 - Uninstall all of the below  ║
║   ------------------------------------------------------------------------   ║
║   2) Chrome/Chromium                                                         ║
║   3) Visual Studio Code                                                      ║
║   4) GIMP Edge                                                               ║
║   5) GIT + SSH keys                                                          ║
║   6) Amazon CLI                                                              ║
║   7) Tilda                                                                   ║
║   ------------------------------------------------------------------------   ║
║   8) Back to installing                        - Go back to installer        ║
║   ------------------------------------------------------------------------   ║
║   Q) I'm done                                  - Quit the installer (Ctrl+C) ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
        read -n1 -s
        case "$REPLY" in
        "1")    # Uninstall everything
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
                uninstall_amazon_cli $i
                ((i++))
                uninstall_tilda $i
                ;;
        "2")    uninstall_chromium ;;
        "3")    uninstall_vsc ;;
        "4")    uninstall_gimp ;;
        "5")    uninstall_git_and_ssh_keys;;
        "6")    uninstall_amazon_cli ;;
        "7")    uninstall_tilda ;;
        "8")    break ;;
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
    header "Installing ${package_name^^}" "$1"
    if ask_uninstall "Chrome (Chromium is up next)"; then
        check_sudo               
        sudo apt-get remove google-chrome-stable || true
        sudo rm -r ~/.config/google-chrome || true
        echo ""
        echo "Chrome is no longer installed."
    fi
    if ask_uninstall "Chromium"; then
        check_sudo
        uninstall_if_found "chromium-browser"
        sudo rm -r ~/.config/chromium-browser || true
        echo ""
        echo "Chromium is no longer installed."
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
            echo "Installing $pkg."
            if sudo apt-get -qq --allow-unauthenticated install $pkg; then
                echo "Successfully installed $pkg"
            else
                echo "Error installing $pkg"
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
                echo "Successfully uninstalled $pkg"
            else
                echo "Error uninstalling $pkg"
            fi        
        else
            echo -e "$pkg is not installed"
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
    printf " $1"
    printf '%*s' "$len" | tr ' ' "$ch"
    if [ $STEPCOUNTER = true ]; then
        printf "Step "$2
        printf "/7 "
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

function tux_install {
    # Local/Github folder (comment out the other one if you're working locally)
    $TEMP_DIR/tux-install-master/install.sh $1
    #~/Projects/Tux4Ubuntu/src/tux-desktop-theme/install.sh $1
}

while :
do
    clear
    # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
    cat<<EOF    
╔══════════════════════════════════════════════════════════════════════════════╗
║ TUX 4 UBUNTU - Developer ver 1.2                © 2018 Tux4Ubuntu Initiative ║
║ Let's Bring Tux to Ubuntu                              http://tux4ubuntu.org ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   What TUX developer tools do you want installed? (Press its number)         ║
║                                                                              ║
║   1) All of it                                 - Install all of the below    ║
║   ------------------------------------------------------------------------   ║
║   2) Chrome/Chromium                           - Adds another browser        ║
║   3) Visual Studio Code                        - Great free editor           ║
║   4) GIMP Edge                                 - Newest version of GIMP      ║
║   5) GIT + SSH keys                            - Version handling            ║
║   6) Amazon CLI                                - AWS services in terminal    ║
║   7) Tilda                                     - Drop-down terminal (F1)     ║
║   ------------------------------------------------------------------------   ║
║   9) Uninstall                                 - Uninstall the above         ║
║   ------------------------------------------------------------------------   ║
║   T) Tux4Ubuntu installer                      - TUXedo up your Ubuntu       ║
║   ------------------------------------------------------------------------   ║
║   Q) I'm done                                  - Quit the installer (Ctrl+C) ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    read -n1 -s
    case "$REPLY" in
    "1")    # Install everything
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
            install_amazon_cli $i
            ((i++))
            install_tilda $i
            ((i++))
            get_the_tshirt $i
            ;;
    "2")    install_chromium ;;
    "3")    install_vsc ;;
    "4")    install_gimp ;;
    "5")    install_git_and_ssh_keys;;
    "6")    install_amazon_cli ;;
    "7")    install_tilda ;;
    "8")    get_the_tshirt ;;
    "9")    uninstall ;;
    "T")    tux_installer ;;
    "t")    tux_installer ;;
    "Q")    break ;;
    "q")    break ;;
     * )    echo "That's an invalid option. Try again." ;;
    esac
    sleep 1
done
