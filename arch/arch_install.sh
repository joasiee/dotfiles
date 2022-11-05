#!/bin/bash

useradd -m joasiee
gpasswd -a joasiee wheel
pacman -S sudo
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#*\s*//g' /etc/sudoers

echo "set password for user joasiee":
passwd joasiee

echo "logout and back in as joasiee, then run non root script"

