# Gentoo

Installation nodtes. 

**work in progress**
 
## Installation outline

[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) steps with in detail view. 

Assuming `Gentoo` live usb for **amd64**.

```bash
sudo su
passwd # change root password
passwd gentoo # change active user password
```

**work in progress**

### Prepare the disks

Use `gparted`.

Assumptions: `GPT` partition table for `UEFI`.

| partition | filesystem | size             | description    | flags |
|-----------|------------|------------------|----------------|-------|
| /dev/sda1 | fat32      | 256M             | Boot partition |       |
| /dev/sda2 | linux-swap | 2 * RAM size     | Linux swap     |       |
| /dev/sda3 | ext4       | rest of the disk | Root           |       |

