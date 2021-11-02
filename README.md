# Иерархия
## Что нужно знать о Arch
### Его преимущества
- Минимальность
- Последние обновления
- 
### Чего стоит ожидать от Arch
- Очень редко но иногда бывает проблемы с обновлением, когда идет конфликт библиотек. По большей части зависит лишь от прямоты ваших же рук
- Опять-таки все зависит от вашего опыта, если что то сломалось это скорее всего что вы что-то не так сделали
- 
### Чего Arch ожидает от вас
- Вы уже понимаете базовые вещи в Linux
- Вы будете читать документации

## Что нужно знать перед установкой
### Есть три разных метода установки
- `arch-install`
- Вручную + скрипт
- Полностью вручную

## О самой установке, почему именно этот стек
### Будем использовать 
- `btrfs`
- `wayland KDE`
- `pipewire`
- `snapper`

## Установка
1. Проверка интернета `ping google.com`
2. Работа с Разделами
  1. Посмотрите как у вас обозначены Жесткие Диски (ЖД) через `lsblk`
  2. Снос ЖД `gdisk /dev/vda`, есть также и старый добрый `fdisk`
    1. Обязательно смотрите заранее через `lsblk`
  3. Создание новой таблицы через `o` `y`
  4. Создание раздела для **EFI**
    1. `n` `ENTER` `+300M` `ef00`
    2. Посмотреть таблицу ЖД: `p`
  5. Создание раздела для **EF**
    1. `n` `ENTER` `ENTER` `ENTER`
  6. Сохранить изменения `w`, `y`
  7. Перепроверить разделы через `lsblk`
  8. Форматирование разделов
    1. `mkfs.vfat /dev/vda1`
    2. `mkfs.btrfs /dev/vda2`, Если будет предупреждение то соглашайтесь
3. Создание подразделов в `btrfs`, это нужно для того чтобы когда мы делали снимки диска то он менял лишь тот раздел который нам нужно менять (см. [1]). Делается через `btrfs subvolume create @`
  1. `mount /dev/vda2 /mnt`
  2. `cd /mnt`
  3. `@` для `/`
  4. `@home` для `/home`
  5. `@snapshots` для `/.snapshots`
  6. `@var_log` для `/var/log`
  7. `cd ~` -> выйти с папки перед его извлечением
4. Извлеките раздел `umount /mnt`
5. Подключите разделы снова но уже со включенным сжатием (см. [2])
  1. `mount -o compress=zstd:1,subvol=@ /dev/vda2 /mnt`
  2. `mkdir -p /mnt/{boot/efi,home,var,.snapshots,var/log}`
  3. `mount -o compress=zstd:1,subvol=@home /dev/vda2 /mnt/home`
  4. `mount -o compress=zstd:1,subvol=@var_log /dev/vda2 /mnt/var/log`
  5. `mount -o compress=zstd:1,subvol=@snapshots /dev/vda2 /mnt/.snapshots`
  6. `mount /dev/vda1 /mnt/boot/efi`
6. Установить ArchLinux на раздел `/mnt` и войти в него
  1. `pacstrap /mnt base base-devel linux linux-firmware git btrfs-progs {vim,nano} {intel-ucode,amd-ucode}` # в скобках  выбирайте под себя
  2. Сохранить таблицу установки разделов в `/mnt/etc/fstab`
    1. `genfstab -U /mnt >> /mnt/etc/fstab`
  3. Войти в новоустановленную систему
    1. `arch-chroot /mnt`
    2. Перепроверьте ваш fstab `cat /etc/fstab`
  4. Скачать, Настроить и Запустить скрипт
    1. Скачать скрипт по `git clone https://github.com/indicozy/arch-install`
    2. Настроить скрипт под себя, идите и читайте что делает каждая команда
    3. `base/base-uefi.sh` или `base/base-mbr.sh`
    4. `AUR/paru.sh` или `AUR/yay.sh`
    5. Добавляете группу `wheel` в `sudo` через комманду `visudo` и строку `%wheel ALL=(ALL) ALL`
    6. Один из Окружении в папке `DE`, после система сама перезагрузится
  5. Установка Zram
    1. Установить `paru` или `yay` для доступа к AUR
    2. Установить `zramd` из AUR
    3. Настроить его в `/etc/default/zramd`
    4. Запустить через `sudo systemctl enable --now zramd`
  6. Установка Snapper
    1. Установить `sudo pacman -S snapper`
    2. Создать новую конфигурацию для субраздела `/` `sudo snapper -c root create-config /`
    3. Изменить каждые обновления под себя: `TIMELINE_MIN_AGE="1800" TIMELINE_LIMIT_HOURLY="5" TIMELINE_LIMIT_DAILY="7" TIMELINE_LIMIT_WEEKLY="0" TIMELINE_LIMIT_MONTHLY="0" TIMELINE_LIMIT_YEARLY="0"`
    4. Установить `snap-pac` (pacman) и `snap-pac-grub` (paru/yay) для снимков до и после обновлении и вывода снимков в меню GRUB



[1] Альтернативные варианты разделов: 
- https://www.nishantnadkarni.tech/posts/arch_installation/
- https://wiki.archlinux.org/title/snapper

[2] Тесты разных типов и уровней сжатия: 
- https://docs.google.com/spreadsheets/d/1x9-3OQF4ev1fOCrYuYWt1QmxYRmPilw_nLik5H_2_qA/edit#gid=0
- https://github.com/facebook/zstd/blob/dev/contrib/linux-kernel/btrfs-benchmark.sh

# Заметки (мне лень их прятать)
https://wiki.archlinux.org/title/improving_performance
grub-btrfs

https://github.com/maximumadmin/zramd
https://wiki.archlinux.org/title/snapper#Installation

Добавить мультипоточную загрузку
