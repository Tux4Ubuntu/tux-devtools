# tux-devtools

## TODO:
### Add FlatPacks to Software
sudo apt update
sudo apt install --reinstall gnome-software gnome-software-plugin-flatpak
killall gnome-software && gnome-software

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo nano /etc/xdg/gnome-software/gnome-software.conf
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo


And make sure that this ecists somewhere:
[Sources]
Order=apt,flatpak



### Add mouse dynamic mouse pointer for trackpad


### Add rust build tools:
curl https://sh.rustup.rs -sSf | sh

### Add nvm build tools:

### Add build essetials
sudo apt update
sudo apt install -y build-essential gcc

### Ratio scaloing
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

