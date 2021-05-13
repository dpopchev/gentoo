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

`parted` does not create filesystems, only uses the info to optimize parttions. The later are covered by other [tools](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI)

Apply filesystems and activate swap.
```bash
mkfs.vfat -F 32 /dev/sda1   # efi
mkfs.ext4 /dev/sda3         # / of gentoo
mkswap /dev/sda2            # swap
swapon /dev/sda2            # activate 
```
