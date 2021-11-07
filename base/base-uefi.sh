#!/bin/bash

ln -sf /usr/share/zoneinfo/Asia/Almaty /etc/localtime # TODO CHANGE TIME TO YOURS
hwclock --systohc

sed -i '177s/.//' /etc/locale.gen
sed -i '402s/.//' /etc/locale.gen

locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf # TODO CHANGE LANG TO YOURS
echo "arch" >> /etc/hostname # TODO CHANGE 'arch' TO ANY OF YOUR OWN
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts # TODO CHANGE both 'arch' TO THE LINE ABOVE
echo root:password | chpasswd # TODO SET HERE PASSWORD AT 'password'

pacman -S --needed grub networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools reflector base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack openssh rsync acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font efibootmgr cronie

# Add your drivers to your GPU
# pacman -S --noconfirm xf86-video-amdgpu 
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable cronie
systemctl enable avahi-daemon
systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

useradd -m username # TODO CHANGE USERNAME TO YOURS
echo username:password | chpasswd # TODO CHANGE USERNAME AND PASSWORD
usermod -aG libvirt,wheel username # TODO CHANGE USERNAME

echo "username ALL=(ALL) ALL" >> /etc/sudoers.d/username # TODO CHANGE USERNAME

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
