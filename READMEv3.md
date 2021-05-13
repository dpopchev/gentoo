# Introduction

Gentoo installation cheat sheet in form of code snippets and hyperlinks.

Main resources:
- [Handbook amd64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Gentoo downloads](https://www.gentoo.org/downloads/)
- [Gentoo mirrors](https://www.gentoo.org/downloads/mirrors)
- [Gentoo installation alternatives](https://wiki.gentoo.org/wiki/Installation_alternatives)

# Configuring the network 

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking)

Applicable if installation using minimal .

[Check for summary of methods](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking#Default:_Using_net-setup)

- Gentoo Live CD
  ```bash
  ip addr                     # see interface names
  net-setup ${NET_INTERFACE}  # try auto config
  ```

#  Preparing the disks 

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks)

## Partitioning 

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI)

Target partitioning
- GPT table
- EFI system, FAT32, ~256M
- Linux swap, ~ available RAM
- Root and others, ext4

Notes:
- [Alternative solutions for partitioning](https://wiki.gentoo.org/wiki/Partition)
- [Partition tool `parted`](https://wiki.archlinux.org/title/Parted)
- [On optimal partitioning](https://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/)
- [Swap disabaling line inspired by](https://stackoverflow.com/a/35165216/3169522)

List storage devices with their filesystem types.
```bash
lsblk -o +fstype,label   
```

Disable any swap partition that is active.
```bash 
test $(swapon --summary | head --bytes=1 | wc --bytes) -ne 0 \
  && swapoff $(swapon -s | grep --perl-regexp --only-matching '\/dev\/sd\w+')
```

Make sure you have booted with a UEFI machine if you choose ‘gpt’. 
```bash
ls /sys/firmware | grep --perl-regexp --quiet '\befi\b && echo 'Safe to poceed with GPT table'
```
If the command above does not say it safe, you should reserch more

Set gpt table on target disc.
```bash
parted /dev/${TARGET_DISC} mklabel gpt  # 
```
Subsequent commands will assume sda.

Partition
```bash
parted /dev/sda mkpart efi fat32 1MiB 512MiB set 1 esp on
parted /dev/sda mkpart swap linux-swap 512MiB 8GiB
parted /dev/sda mkpart gentoo ext4 8GiB 100%
```

## Create filesystems

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI)

`parted` does not create filesystems, only uses the info to optimize parttions. See handbook link above.

```bash
mkfs.vfat -F 32 /dev/sda1   # efi
mkfs.ext4 /dev/sda3         # / of gentoo
mkswap /dev/sda2            # swap
```

## Root and swap partition

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Activating_the_swap_partition)

Activate swap
```bash
swapon /dev/sda2    
```

Mount root partition
```bash
mkdir --parents /mnt/gentoo && mount /dev/sda3 /mnt/gentoo 
```

# Install stage tarball

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage)

## Update date and time

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Setting_the_date_and_time)

If the live medium is somehow off.

- Manual
  ```bash
  date 100313162016
  ```
- Automatic, assumes Gentoo Live CD
  ```bash
  ntpd -q -g
  ```

## Download tarball

- [Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Choosing_a_stage_tarball)
- [stage3 for amd64, openrc, multilib](https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20210509T214503Z/stage3-amd64-20210509T214503Z.tar.xz)
- [mirrors](https://www.gentoo.org/downloads/mirrors/)

```bash
wget ${LINK}
```

[Verify and validate](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Verifying_and_validating)

## Unpack tarball

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Setting_the_date_and_time)

- Gentoo live cd
  ```bash
  tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo 
  ```
- [non Gentoo medium](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)
  ```bash
  tar --numeric-owner --xattrs -xvJpf stage3-*.tar.xz -C /mnt/gentoo 
  ```
  
# Installing the Gentoo base system 

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base)

## Mounting the necessary filesystems

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Mounting_the_necessary_filesystems)

`/proc`
- Gentoo Live CD
  ```bash
  mount --types proc /proc /mnt/gentoo/proc 
  ```
- [non Gentoo medium](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)
  ```bash
  mount -o bind /proc /mnt/gentoo/proc
  ```
  
`/sys`
```bash
mount --rbind /sys /mnt/gentoo/sys 
mount --make-rslave /mnt/gentoo/sys 
```

`/dev`
```bash
mount --rbind /dev /mnt/gentoo/dev 
mount --make-rslave /mnt/gentoo/dev 
```

`/dev/shm` for non Gentoo Live CD 
```bash
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm 
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm 
chmod 1777 /dev/shm
```

`/dev/shm` for Ubuntu live cd [note here](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions) regarding [Python bug for broken `sem_open()`](https://bugs.gentoo.org/496328)
```bash
mount --rbind /run/shm /mnt/gentoo/run/shm
```

## Copy DNS info

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Copy_DNS_info)

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

## Entering the new environment

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Entering_the_new_environment)

- Gentoo Live CD
  ```bash
  chroot /mnt/gentoo /bin/bash 
  source /etc/profile 
  export PS1="(chroot) ${PS1}"
  ```
- [non Gentoo Live CD](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)
  ```bash
  chroot /mnt/gentoo /bin/env -i TERM=$TERM /bin/bash 
  env-update 
  source /etc/profile 
  export PS1="(chroot) $PS1" 
  ```

[Mounting partitions to end points](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Mounting_the_boot_partition)
```bash
mount /dev/sda1 /boot
```

**NOTE** Subsequent commands assume working in the chroot env, if not otherwise said.

## Configuring Portage

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Configuring_Portage)

### Ebuild repository

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Gentoo_ebuild_repository)
```bash
mkdir --parents /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
```

### Installing and updating a Gentoo ebuild repository snapshot 

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Installing_a_Gentoo_ebuild_repository_snapshot_from_the_web)
```bash
emerge-webrsync
emerge --sync --quiet
```

### Get faouvorite editor

```bash
emerge -av vim
```

# Make conf

- [Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Configuring_compile_options)
- [Gentoo wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf)
- [Gentoo dev manual](https://devmanual.gentoo.org/eclass-reference/make.conf/index.html)
- [man](https://dev.gentoo.org/~zmedico/portage/doc/man/make.conf.5.html)
- Local commented listing of all variables
  ```bash
  less /usr/share/portage/config/make.conf.example
  ```
- Local man
  ```bash
  man make.conf
  ```

## Optimization flags

- [Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#CFLAGS_and_CXXFLAGS)
- [Gentoo gcc optimization wiki](https://wiki.gentoo.org/wiki/GCC_optimization)
- [Gentoo safe cflags wiki](https://wiki.gentoo.org/wiki/Safe_CFLAGS)


