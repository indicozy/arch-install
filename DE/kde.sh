#!/bin/bash

sudo pacman -S --noconfirm xorg wayland sddm plasma kde-applications firefox plasma-wayland-session 

sudo systemctl enable sddm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
