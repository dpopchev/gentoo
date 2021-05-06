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
tar --numeric-owner --xattrs -xvJpf stage3-*.tar.xz -C /mnt/gentoo 
```
