# Introduction

Use as summary of commands to furllfil steps in installation process from:
- [Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Installation alternatives](https://wiki.gentoo.org/wiki/Installation_alternatives)

Reference to specific guides are included. 

Guide pressumes usage of non Gentoo live CD.

#  Configuring the network 

Automatic network configuration of regular ethernet in DHCP service:

```bash
ip addr # see interface names
dhcpcd ${NET_INTERFACE}
```

[Further notes on `ifconfig`, `net-setup`, etc](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking)

# Preparing the disks

## Partitioning 

[GPT for UEFI](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI)

Side note: gparted works fine.
- EFI system, FAT32, ~256M
- Linux swap, ~ available RAM
- Root and others, ext4, 

```bash
lsblk
fdisk /dev/sda
mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
swapon /dev/sda2
```

```bash
mkdir -p /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
```

# Stage tarball

## Types

[System configurations](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Choosing_a_stage_tarball)

Guide assumes:
- multilib 
- amd64
- OpenRC

## Download

Sources:
- [Downloads](https://www.gentoo.org/downloads)
- [Mirrors](https://www.gentoo.org/downloads/mirrors/)

```bash
cd /mnt/gentoo
wget ${TARBALL_LINK}
```

[Validate](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Verifying_and_validating)

## Unpack

[Untar from non Gentoo liveCD](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)

```bash
tar --numeric-owner --xattrs -xvJpf stage3-*.tar.xz -C /mnt/gentoo # installation alternative instruction
```

# Chroot

## Ebuild repository

```bash
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

## DNS info

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

## Mount filesystems

Sources:
- [Handbook notes on non Gentoo installation media](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Mounting_the_necessary_filesystems)
- [Additional note on proc mount](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)

```bash
mount -o bind /proc /mnt/gentoo/proc  # installation alternative instruction
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev 
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm 
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm 
```

## Entering environment

Source: 
- [Note on enviroment setup](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)

```bash
chroot /mnt/gentoo /bin/env -i TERM=$TERM /bin/bash
env-update 
source /etc/profile 
export PS1="(chroot) $PS1" 
```

## Mount boot partition

```bash
mount /dev/sda1 /boot
```

# Configure portage

## Ebuild repository 

```bash
emerge-webrsync
emerge --sync --quiet
```

## Choose profile

```bash
eselect profile list
eselect profile set 5
eselect profile show # expect amd64 generic multilib openrc desktop
```

# Make conf

Sources:
- [Official wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf)
- local documentation: `/mnt/gentoo/usr/share/portage/config/make.conf.example`
- [Online man](https://dev.gentoo.org/~zmedico/portage/doc/man/make.conf.5.html)

## Compiler flags

Sources:
- [GCC optimization](https://wiki.gentoo.org/wiki/GCC_optimization#-march)
- [Safe CFLAGS](https://wiki.gentoo.org/wiki/Safe_CFLAGS)

[Automatic CPU detection by the compiler](https://wiki.gentoo.org/wiki/Safe_CFLAGS#Automatic_CPU_detection_by_the_compiler). See what it will detect:

```bash
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
```

[CPU_FLAGS_X86 to set CPU specific instructions](https://wiki.gentoo.org/wiki/CPU_FLAGS_X86#Using_cpuid2cpuflags)

```bash
emerge --ask --oneshot app-portage/cpuid2cpuflags
perl -ni -e 'print unless /^[[:blank:]]*CPU_FLAGS_X86/' /etc/portage/make.conf
cpuid2cpuflags | perl -pe 's/(?<=[:]\ )([\w[:blank:]]+)/"$1"/; s/[:]/\ =/;' >> /etc/portage/make.conf
```

## Makeopts

Sources:
- [Official](https://wiki.gentoo.org/wiki/MAKEOPTS)
- [Note on parallel builds](https://www.preney.ca/paul/archives/341)

```bash
grep '^processor' /proc/cpuinfo | sort -u | wc -l
```

## Emerege deafault options

Sources:
- [Official](https://wiki.gentoo.org/wiki/EMERGE_DEFAULT_OPTS)
- [Note on parallel builds](https://www.preney.ca/paul/archives/341)

```bash
grep '^processor' /proc/cpuinfo | sort -u | wc -l
```

## Features

[Binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)
