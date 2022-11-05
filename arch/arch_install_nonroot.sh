#!/bin/bash

sudo sed -i '/ParallelDownloads=/c\ParallelDownloads=10' /etc/pacman.conf
sudo pacman -S --needed base-devel gnome gdb xdg-user-dirs \
pipewire wireplumber pipewire-pulse firefox nftables firewalld \
zram-generator fwupd gnome-firmware git obsidian htop vlc vim \
fprintd

sudo pacman -Rs gnome-books gnome-boxes gnome-calendar gnome-software gnome-maps gnome-weather

sudo systemctl enable nftables
sudo systemctl enable firewalld
sudo systemctl enable gdm

cat <<-EOF | sudo tee /etc/sysctl.d/99-swappiness.conf
vm.swappiness = 10
vm.vfs_cache_pressure=50
EOF

cat <<-EOF | sudo tee /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 4
EOF

sudo sed -i '2 i auth sufficient pam_fprintd.so' /etc/pam.d/system-auth

sudo systemctl daemon-reload
sudo systemctl start /dev/zram0

git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si
cd .. && rm -rf paru

paru visual-studio-code-bin
paru spotify
paru zotero-bin
paru insync

echo "Do you wish to configure additionally for laptops?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
        	pacman -S tlp mesa
        	systemctl enable tlp.service
        	break;;
        No ) break;;
    esac
done
