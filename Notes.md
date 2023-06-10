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

