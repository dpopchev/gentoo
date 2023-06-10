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
