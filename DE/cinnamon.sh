#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Kazakhstan -a 6 --sort rate --save /etc/pacman.d/mirrorlist # TODO CHANGE TO YOUR COUNTRY

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

sudo pacman -S xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings cinnamon simplescreenrecorder arc-gtk-theme arc-icon-theme obs-studio xed xreader metacity gnome-shell firefox vlc

sudo systemctl enable lightdm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
