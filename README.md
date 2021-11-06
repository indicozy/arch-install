# Руководство Установки Arch Linux
## Будем использовать 
- `btrfs`
- `wayland KDE`
- `pipewire`
- `snapper`

# Установка
## Проверка интернета
``` bash
ping google.com
```

## Работа с Разделами
Посмотрите как у вас обозначены Жесткие Диски (ЖД) через:
```
lsblk
```

##Снос ЖД
``` bash
gdisk /dev/vda1
```

**Дальнейшие команды нужно проводить в gdisk!**
1. Создание новой таблицы:
```
o
y
```

1. Создание раздела для **EFI**
```
n
ENTER
+300M
ef00
```

Посмотреть новую таблицу ЖД:
```
p
```

2. Создание раздела для **Linux**
```
n
ENTER
ENTER
ENTER
```

3. Сохранить изменения и перезаписать ЖД:

```
w
y
```

4. Перепроверить разделы через
```
lsblk
```

## Форматирование разделов
``` bash
mkfs.vfat /dev/vda1
mkfs.btrfs /dev/vda2
```
Если будет предупреждение, то соглашайтесь

## Создание подразделов в btrfs
Это нужно для того чтобы когда мы делали снимки диска то он менял лишь тот раздел который нам нужно менять (см. [1]).
``` bash
mount /dev/vda2 /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @var_log
cd ~
umount /mnt
```
Подраздел `@snapshots` будет создан автоматически при помощи `snapper`.

## Подключите разделы снова но уже со включенным сжатием (см. [2])
``` bash
mount -o compress=zstd:1,subvol=@ /dev/vda2 /mnt
mkdir -p /mnt/{boot/efi,home,var,.snapshots,var/log}
mount -o compress=zstd:1,subvol=@home /dev/vda2 /mnt/home
mount -o compress=zstd:1,subvol=@var_log /dev/vda2 /mnt/var/log
mount -o compress=zstd:1,subvol=@snapshots /dev/vda2 /mnt/.snapshots
mount /dev/vda1 /mnt/boot/efi
```

## Установить ArchLinux на раздел `/mnt` и войти в него
``` bash
pacstrap /mnt base base-devel linux linux-firmware git btrfs-progs {vim,nano} {intel-ucode,amd-ucode}`
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
cat /etc/fstab # Перепроверить fstab
```

## Заранее подготовьте конфиги
1. Добавляете группу `wheel` в `sudo` через комманду:
```
EDITOR=nano visudo
```
и убираете комментарий со строки `%wheel ALL=(ALL) ALL`
2. Установите многопоточность в `pacman`:
```
nano /etc/pacman.conf
```
Откомментируйте и поставьте свое значение в `ParallelDownloads = 10`

## Скачать, Настроить и Запустить скрипт
1. Скачайте данный скрипт и войдите в него
```
cd ~
git clone https://github.com/indicozy/arch-install
cd arch-install
```
**Настройте скрипт под себя, идите и читайте что делает каждая команда**
2. Запустите `base/base-uefi.sh` или `base/base-mbr.sh`, если у вас компьютер <2008 года то берите с `UEFI`
```
./base/base-uefi.sh
```
* Перезагрузите компьтер через:
```
exit
umount -a
reboot
```
3. Установите пакетный менеджер для AUR с помощью `AUR/paru.sh` или `AUR/yay.sh`, они особо не отличаются но для новичков рекомендую `yay`
```
./AUR/yay.sh
```
4. Установите один из Окружении в папке `DE`, после система сама перезагрузится
```
./DE/Все_что_угодно.sh
```

## Установка Zram
* Установите `paru` или `yay` для доступа к AUR
* Установите `zramd` из AUR:
```
sudo yay/paru -S zramd
```
* Настройте его в `/etc/default/zramd`, установите размер swap-раздела
* Запустите его daemon через:
``` bash
sudo systemctl enable --now zramd
```

## Установка Snapper
1. Установить `snapper`:
```
sudo pacman -S Snapper
```
2. Создать новую конфигурацию для субраздела `/`:
```
sudo snapper -c root create-config /
```
3. Изменить каждые обновления под себя в файле `/etc/snapper/configs/root`: 
```
TIMELINE_MIN_AGE="1800"
TIMELINE_LIMIT_HOURLY="3"
TIMELINE_LIMIT_DAILY="5"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"`
```
Данные обновления зависят от `cron` который будет установлен и запущен демон в скрипте `base`.
4. Установить `snap-pac` (pacman) и `snap-pac-grub` (paru/yay) для снимков до и после обновлении и вывода снимков в меню GRUB:
```
yay/paru -S snap-pac snap-pac-grub
```

## Опционально
- Установить flatpak:
```
sudo pacman -S flatpak
```

## К чтению:
- Улучшение производительности, лонгрид: https://wiki.archlinux.org/title/improving_performance

Хотите добавить свое? Пишите тут в Issues или лично по https://t.me/indicozy

# Ресурсы
[1] Альтернативные варианты разделов: 
- https://www.nishantnadkarni.tech/posts/arch_installation/
- https://wiki.archlinux.org/title/snapper

[2] Тесты разных типов и уровней сжатия: 
- https://docs.google.com/spreadsheets/d/1x9-3OQF4ev1fOCrYuYWt1QmxYRmPilw_nLik5H_2_qA/edit#gid=0
- https://github.com/facebook/zstd/blob/dev/contrib/linux-kernel/btrfs-benchmark.sh

