# Gentoo

Installation nodtes. 

**work in progress**
 
## Installation outline

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) steps with in detail view. 

Assuming `Gentoo` live usb for **amd64**.

```
sudo su
passwd # change root password
passwd gentoo # change active user password
```

Disable system beep
```
xset -b
xset b off
xset b 0 0 0
```

**work in progress**

### Prepare the disks

Use `gparted`.

Assumptions: `GPT` partition table for `UEFI`.

| partition | filesystem | size             | description    | flags |
|-----------|------------|------------------|----------------|-------|
| /dev/sda1 | fat32      | 256M             | Boot partition | boot, esp |
| /dev/sda2 | linux-swap | ~ RAM size       | Linux swap     |       |
| /dev/sda3 | ext4       | rest of the disk | Root           |       |

Activate swap 

```
swapon /dev/sda2
```

Mount root partition

```
mkdir -p /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
```

### Install stage tarball

```
chronyd -q # sync time
```

```
cd /mnt/gentoo
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230604T170201Z/stage3-amd64-openrc-20230604T170201Z.tar.xz
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

### Find mirrors

```
cd /mnt/gentoo/etc/portage
mirrorselect -D -s5 -o > mirrors # verify and copy into make.conf
```

### Gentoo ebuild repository

```
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

### Copy DNS info

```
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

### Mount file systems

```
mount --types proc /proc /mnt/gentoo/proc 
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev 
mount --bind /run /mnt/gentoo/run 
mount --make-slave /mnt/gentoo/run 
```

### Change root

```
chroot /mnt/gentoo /bin/bash 
```

```
source /etc/profile
export PS1="(chroot) ${PS1}"
```

**Assumming we are into new root from now one**

### Mount boot

```
mount /dev/sda1 /boot
```

### Portage configuration

Get ebuild repository

```
emerge-webrsync
```

Check variable values aginst `emerge --info`

Select a profile

```
eselect profile list
eselect profile set 5 # current generic desktop
```

```
emerge --oneshot app-portage/cpuid2cpuflags
cd /etc/portage
cpuid2cpuflags > cpu_flags # merge into make.conf
```

Sample `make.conf`

```
# example setup: /usr/share/portage/config/make.conf.example
# online resource: https://wiki.gentoo.org/wiki//etc/portage/make.conf

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

GENTOO_MIRRORS="http://tux.rainside.sk/gentoo/ http://ftp-stud.hs-esslingen.de/pub/Mirrors/gentoo/ http://ftp.belnet.be/pub/rsync.gentoo.org/gentoo/ http://ftp.gwdg.de/pub/linux/gentoo/ http://mirror.bytemark.co.uk/gentoo/"

# see lspu or nproc
MAKEOPTS="--jobs 4 --load-average 3.75"

# each emerge job starts an makeopts job, hence jobs load increases; hopefully it balacnes trough load-avg opt
# TODO in tandme with buildpkg feature, see usepkg=y, binpkg-changed-deps=y, binpkg-respect-use=y
EMERGE_DEFAULT_OPTS="--jobs 4 --load-average 3.75 --quiet y --verbose y --keep-going y --tree --autounmask-write"

USE="bash-completion -bluetooth branding -dvd -dvdr -emacs -gnome -gnome-keyring -kde -wayland -zsh-completion"

ACCEPT_LICENSE="-* @FREE"

# LINGUAS
# USE_EXPAND

# CPU_FLAGS_*
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3"

# INPUT_DEVICES
# L10N
# VIDEO_CARDS

# lscpu cpu count or nproc

# NOTE: This stage was built with the bindist Use flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8
```

```
# for emerge --autounmask-write option
for d in /etc/portage/package.*; do touch $d/zzz_autounmask; done 
```

Update word set

```
emerge --ask --verbose --update --deep --newuse @world
```

### Localization

```
ls /usr/share/zoneinfo # check timzones
echo "$Region/$City > /etc/timezone # choose timezone
```

```
emerge --config sys-libs/timezone-data
```

```
grep $TARGET_LANGS /usr/share/i18n/SUPPORTED >> /etc/locale.gen
```

```
locale-gen
```

```
eselect locale list
eselect locale set $taget_locale
```

```
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### Kernel

```
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.licence
emerge --ask sys-kernel/linux-firmware
```

```
emerge -av gentoo-sources
```

```
eselect kernel list
eselect kernel set $N
```

```
cd /usr/src/linux
# make localyesconfig
make localmodconfig
make -j4 && make modules_install  && make install
```

### Configuring the system

```
# sample content of fstab
/dev/sda1		/boot		vfat		noauto,noatime	1 2
/dev/sda3		/		ext4		noatime		0 1
/dev/sda2		none		swap		sw		0 0
```

### Some software

- vim
- neovim
- bash-completion
