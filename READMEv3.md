# Introduction

Gentoo installation cheat sheet in form of code snippets and hyperlinks.

Main resources:
- [Handbook amd64](https://wiki.gentoo.org/wiki/Handbook:AMD64)
- [Gentoo downloads](https://www.gentoo.org/downloads/)
- [Gentoo mirrors](https://www.gentoo.org/downloads/mirrors)

# Configuring the network 

Applicable if installation using minimal Gentoo Live CD.

[Check for summary of methods](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking#Default:_Using_net-setup)

```bash
ip addr                     # see interface names
net-setup ${NET_INTERFACE}  # try auto config
```

#  Preparing the disks 

## Partition

## Partitioning 

[GPT for UEFI](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI)

Target partitioning
- GPT table
- EFI system, FAT32, ~256M
- Linux swap, ~ available RAM
- Root and others, ext4

Notes:
- [Alternative solutions for partitioning](https://wiki.gentoo.org/wiki/Partition)
- [Partition tool `parted`](https://wiki.archlinux.org/title/Parted)
- [Interesting reading on optimal partitioning](https://rainbow.chard.org/2013/01/30/how-to-align-partitions-for-best-performance-using-parted/)
- [swap disabaling line inspired by](https://stackoverflow.com/a/35165216/3169522)\
- [apply filesystems](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI)

```bash
# list storage devices with their filesystem types
lsblk -o +fstype,label   
```
```bash
# disable any swap partition that is on
test $(swapon --summary | head --bytes=1 | wc --bytes) -ne 0 \
  && swapoff $(swapon -s | grep --perl-regexp --only-matching '\/dev\/sd\w+')
```
```bash
# Make sure you have booted with a UEFI machine if you choose ‘gpt’
# If the below command does not say it safe, you should reserch more
ls /sys/firmware | grep --perl-regexp --quiet '\befi\b && echo 'Safe to poceed with GPT table'
```
```bash
# NOTE: parted does not create filesystems, only uses the info to optimize parttions
parted /dev/${TARGET_DISC} mklabel gpt  # subsequent commands will assume sda
parted /dev/sda mkpart efi fat32 1MiB 512MiB set 1 esp on
parted /dev/sda mkpart swap linux-swap 512MiB 8GiB
parted /dev/sda mkpart gentoo ext4 8GiB 100%
mkfs.vfat -F 32 /dev/sda1
mkfs.ext4 /dev/sda3
mkswap /dev/sda2
swapon /dev/sda2
```
