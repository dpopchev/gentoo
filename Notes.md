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

| partition | filesystem | size             | description    | flags |
|-----------|------------|------------------|----------------|-------|
| /dev/sda1 | fat32      | 256M             | Boot partition | boot, esp |
| /dev/sda2 | linux-swap | ~ RAM size       | Linux swap     |       |
| /dev/sda3 | ext4       | rest of the disk | Root           |       |

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
mount --types proc /proc /mnt/gentoo/proc && \ 
mount --rbind /sys /mnt/gentoo/sys && \
mount --make-rslave /mnt/gentoo/sys && \
mount --rbind /dev /mnt/gentoo/dev && \
mount --make-rslave /mnt/gentoo/dev && \
mount --bind /run /mnt/gentoo/run && \
mount --make-slave /mnt/gentoo/run && \
mount /dev/sda1 /mnt/gentoo/boot
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

```
#emerge -av vim
```

Sample `/etc/portage/make.conf`

```
# example setup: /usr/share/portage/config/make.conf.example
# online resource: https://wiki.gentoo.org/wiki//etc/portage/make.conf

ACCEPTED_KEYWORDS='~amd64'

# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
# see march native flags: gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
COMMON_FLAGS="-O2 -pipe -march=native"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

# TODO see buildpkg
FEATURES="candy downgrade-backup unmerge-backup"

# GENTOO_MIRRORS

# get using lspu or nproc
NPROC=4
LOAD_AVG=3.75 # ~ 0.9 of NPROC

MAKEOPTS="--jobs ${NPROC} --load-average ${LOAD_AVG}"

# each emerge job starts an makeopts job, hence jobs load increases; hopefully it balacnes trough load-avg opt
# TODO idea to explore is buildpkg feature, see usepkg=y, binpkg-changed-deps=y, binpkg-respect-use=y
EMERGE_DEFAULT_OPTS="--jobs ${NPROC} --load-average ${LOAD_AVG} --quiet y --verbose y --keep-going y --tree --autounmask-write"

BASH_FLAGS="bash-completion -zsh-completion"
INTERFACE_FLAGS="-bluetooth -dvd -dvdr"
GENTOO_FLAGS="branding"
VIM_FLAGS="-emacs"
DE_FLAGS="-gnome -gnome-keyring -kde"
X_FLAGS="-wayland"
APPENDED_FLAGS=""

USE="${BASH_FLAGS} ${INTERFACE_FLAGS} ${GENTOO_FLAGS} ${VIM_FLAGS} ${D_FLAGSE} ${X_FLAGS} ${APPENDED_FLAGS}"

ACCEPT_LICENSE="-* @FREE"

# LINGUAS
# USE_EXPAND

# CPU_FLAGS_*

# INPUT_DEVICES
# L10N
# VIDEO_CARDS

# NOTE: This stage was built with the bindist Use flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8
```

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
cd /mnt/gentoo/etc/portage && mirrorselect -D -s5 -o > mirrors # merge into make.conf
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
/dev/sda1		/boot		vfat		noauto,noatime	1 2
/dev/sda3		/		ext4		noatime		0 1
/dev/sda2		none		swap		sw		0 0
```

```
# echo ${DESIRED_HOSTNAME} > /etc/hostname
```

Check out password policies in `/etc/security/passwdc.conf`

```
passwd # set root password
```

```
# useradd -g users -G wheel,portage,audio,video,usb -m ${USERNAME}
# passwd ${USERNAME} 
```

### Kernel

```
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license && \
emerge --ask sys-kernel/linux-firmware
```

```
emerge -av gentoo-sources
```

```
eselect kernel list
# eselect kernel set $CHOICE
```

```
cd /usr/src/linux && \
make localmodconfig && \
make -j4 && make modules_install  && make install
```

### Bootloader

```
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf && \
emerge sys-boot/grub && \
grub-install /dev/sda && \
grub-install --target=x86_64-efi --efi-directory=/boot/efi && \
grub-mkconfig -o /boot/grub/grub.cfg
```

### Finishing touches

```
emerge -av gentoolkit
```

```
euse -E networkmanager
emerge --ask net-misc/networkmanager
rc-update add NetworkManager default
```

```
gpasswd -a ${USER} plugdev
```

```
euse -E logrotate -p app-admin/sysklogd
emerge -a sysklogd
rc-update add sysklogd default
```
