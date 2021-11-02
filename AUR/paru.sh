sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru-bin.git
cd paru
makepkg -si

# SOME OPTIONS
#pikaur -S --noconfirm system76-power
#sudo systemctl enable --now system76-power
#sudo system76-power graphics integrated
#pikaur -S --noconfirm auto-cpufreq
#sudo systemctl enable --now auto-cpufreq
