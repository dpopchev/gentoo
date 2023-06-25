# Gentoo

Installation commands and some notes.

## Installation outline

- [Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Quick Checklist](https://wiki.gentoo.org/wiki/Quick_Installation_Checklist)

Assuming `Gentoo` live usb for **amd64**.

### Preparation

```
sudo su
```

```
passwd # change root password on livecd
```

```
passwd gentoo # change active user password on livecd
```

```
# Force disable system beep
xset -b && xset b off && xset b 0 0 0
```

### Prepare the disks

Use `gparted`.

Assumptions: `GPT` partition table for `UEFI`.

| partition | filesystem | size             | description    | flags | label |
|-----------|------------|------------------|----------------|-------|-------|
| /dev/sda1 | fat32      | 256M             | Boot partition | boot, esp | boot |
| /dev/sda2 | linux-swap | ~ RAM size       | Linux swap     |       | swap |
| /dev/sda3 | ext4       | rest of the disk | Root           |       | gentoo |

```
swapon /dev/sda2
```

```
mkdir -p /mnt/gentoo && mount /dev/sda3 /mnt/gentoo
```

### Install stage tarball

```
cd /mnt/gentoo && \
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230604T170201Z/stage3-amd64-openrc-20230604T170201Z.tar.xz && \
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

### Gentoo ebuild repository

```
mkdir --parents /mnt/gentoo/etc/portage/repos.conf && \
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

### Copy DNS info

```
chronyd -q # sync time
```

```
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

### Change root

```
# mount the boot partition
mount /dev/sda1 /mnt/gentoo/boot
```

```
mount --types proc /proc /mnt/gentoo/proc && \
mount --rbind /sys /mnt/gentoo/sys && \
mount --make-rslave /mnt/gentoo/sys && \
mount --rbind /dev /mnt/gentoo/dev && \
mount --make-rslave /mnt/gentoo/dev && \
mount --bind /run /mnt/gentoo/run && \
mount --make-slave /mnt/gentoo/run
```

```
chroot /mnt/gentoo /bin/bash
```

```
source /etc/profile && export PS1="(chroot) ${PS1}"
```

_Next steps are assuming work into chroot_

### Portage configuration

```
emerge-webrsync
```

Config portage with mine sample [/etc/portage/make.conf](src/make.conf)

```
# for emerge --autounmask-write option
for d in /etc/portage/package.*; do touch $d/zzz_autounmask; done
```

```
emerge --oneshot app-portage/cpuid2cpuflags && \
cd /etc/portage && \
cpuid2cpuflags > cpu_flags # merge into make.conf
```

```
# cd /mnt/gentoo/etc/portage && mirrorselect -D -s5 -o > mirrors # merge into make.conf
```

```
eselect profile list
# eselect profile set $NUMBER
```

### Configuring the system

```
ls /usr/share/zoneinfo # find timezone
# echo $Region/$City > /etc/timezone
```

```
emerge --config sys-libs/timezone-data
```

```
# grep $TARGET_LANGS /usr/share/i18n/SUPPORTED >> /etc/locale.gen
```

```
locale-gen
```

```
eselect locale list
# eselect locale set $taget_locale
```

```
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

Edit `/etc/fstab`

```
LABEL=boot		/boot		vfat		noauto,noatime	1 2
LABEL=swap		none		swap		sw		0 0
LABEL=gentoo		/		ext4		noatime		0 1
```

```
# echo "HOSTNAME=${DESIRED_HOSTNAME}" > /etc/conf.d/hostname
```

### Kernel

```
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license && \
emerge -v sys-kernel/linux-firmware
```

```
emerge -v gentoo-sources
```

```
eselect kernel list
# eselect kernel set $CHOICE
```

```
cd /usr/src/linux && \
yes '' | make localmodconfig && \
make -j4 && make modules_install  && make install
```

### Bootloader

```
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf && \
emerge sys-boot/grub && \
grub-install --target=x86_64-efi --efi-directory=/boot && \
grub-mkconfig -o /boot/grub/grub.cfg
```

### Finishing touches

```
emerge -v gentoolkit
```

Fetch packages and run off the liveusb.

- [Logging system](src/logger.md)
- [Cron](src/cron.md)
- [Enable sudo](src/sudo.md)
- [Network management software](src/networkmanager.md)
- [Pulseaudio](src/pulseaudio.md)
- [X](src/x.md)
- [Automatic mount of drivers](src/udisks.md)
- [Laptop mode](src/laptop_mode.md)


Check out password policies in `/etc/security/passwdc.conf`

```
passwd # set root password
```

```
# useradd -g users -G portage,wheel,plugdev,cron,audio,video,usb -m ${USERNAME}
# passwd ${USERNAME}
```

### Clean up

```
exit # from chroot
```

```
cd && umount -R /mnt/gentoo
```

```
reboot
```
