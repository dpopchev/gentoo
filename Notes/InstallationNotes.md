# Gentoo installation
### my notes for thinkpad E440

For the most part detailed info is obtained from [Gentoo handbook amd64](https://wiki.gentoo.org/wiki/Handbook:AMD64), but generally following the shortlist [from here](https://wiki.gentoo.org/wiki/Quick_Installation_Checklist)

My goal is to have nice resource on howtos and links in one place.  

## Thinkpad spcifications

TODO

## Prepare disks

* [Detailed info in the handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks)
* [Fastest way](https://wiki.gentoo.org/wiki/Quick_Installation_Checklist#UEFI.2FGPT) and [this](https://wiki.gentoo.org/wiki/Quick_Installation_Checklist#UEFI.2FGPT_2)

1. Here is done with Gparted, TODO:include command line alternative

1. Create partition table (GPT recommend)

1. Create partitions (since UEFI recommend, something like this)
   * fat32 for /boot/efi
   * ext4 for /
   * do not forget for the swap, recommend ~RAM

1. After partitions are created and formatted, mount the root
   * mkdir -p /mnt/gentoo 
   * list partitions with either *blkid* or *lsblk -f*
   * mount root / at /mnt/gentoo

1. Lets get the tarball and extract it
   * cd /mnt/gentoo
   * from the nearest [mirror](https://www.gentoo.org/downloads/mirrors/) get stage3-amd64 /releases/amd64/current-stage3-amd64
   * wget _full link_
   * verify *sha512sum stage3.tar.* is the same as in *.DIGESTS* from mirror
   * tar xpvf stage3-.tar.bz2 --xattrs-include='*.*' --numeric-owner 

1. If other partitions, mount them now
   * in our case mkdir -p /mnt/gentoo/efi
   * mount the parititon to /mnt/gentoo/efi
   * if other parititons, mount them now, most popular is /home

1. Edit the *make.conf*
   * TODO: add example
   * TODO: more info can be added of which is what

1. Lets just toggle the fstab, so leave our mind in peace
  * [nice discussion for uefi, also the choice of fstab options](https://forums.gentoo.org/viewtopic-t-1088630-highlight-.html)
  * [nice discussion on fstab](https://wiki.debian.org/fstab)
  * TODO: include the fstab as example
  * nice command to list the partitions is *blkid* or *lsblk -f*

## Configure the system

1. the hearth of gentoo --  /etc/make.conf
  * [general on make.conf](https://dev.gentoo.org/~zmedico/portage/doc/man/make.conf.5.html)
  * [general discussion about gentoo profiles](https://wiki.gentoo.org/wiki/Profile_%28Portage%29)
  * gcc optimization flags
    * smoe notes gcc optimization flags [here](https://wiki.gentoo.org/wiki/GCC_optimization), 
    * more info in */usr/share/portage/config/make.conf.example* in the extracted stage.
    * in old make.conf *CHOST* variable was present, but apperantly now comes from the profile you choose -- [source](https://wiki.gentoo.org/wiki/CHOST)
  * [some info on makeopts](https://wiki.gentoo.org/wiki/MAKEOPTS) and [discussion](https://blogs.gentoo.org/ago/2013/01/14/makeopts-jcore-1-is-not-the-best-optimization/)
  * *accept_keywords* seems to be defined vie the profie, will check
  * [some info on emerge opts](https://wiki.gentoo.org/wiki/EMERGE_DEFAULT_OPTS)
  * considering the *--jobs* it is best to include some *--load_average* or cpu is doomed
  * portage *features* TODO
  * *autoclean* TODO
  * *cpu_flags_x86* [is cpu specific and be obtained from](https://wiki.gentoo.org/wiki//etc/portage/make.conf#CPU_FLAGS_X86)

1. [create gentoo.conf](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Gentoo_ebuild_repository) or simply 
  * cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

1. cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

1. mount necessary filesystems
  * mount -t proc none proc
  * mount --rbind /sys sys 
  * mount --make-rslave sys
  * mount --rbind /dev dev
  * mount --make-rslave dev
  * if using non gentoo live medium
    * test -L /dev/shm && rm /dev/shm && mkdir /dev/shm 
    * mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
    * chmod 1777 /dev/shm
1. chroot /mnt/gentoo /bin/bash
1. source /etc/profile
1. emerge-webrsync, complaining about portage dir should be ignored
1. emerge --sync
1. eselect profile list
1. emerge -va bash-completion vim && source /etc/profile && emerge -va mirrorselect && mirrorselect -i -o >> /etc/portage/make.conf TODO CHECK THE MIRROSELECT
1. eventually if now there is time: emerge -uDNva @world
1. ls /usr/share/zoneinfo && echo "Bulgaria/Sofia" > /etc/timezone && emerge --config sys-libs/timezone-data
1. edit /edit/locale.gen to add desired locales TODO there was some discussion somewhere
1. edit /etc/conf.d/hostname to desired hostname
1. edit /etc/conf.d/hwclock to local
1. if no domain name is to be configured (/etc/conf.d/net) to not get "hostname.(none)" edit /etc/issue by deleting string ".\0"
1. time to do the kernel TODO, now will use old kernel config, but should make more notes
  * TODO: option make localyesconfig
  * emerge -av gentoo-sources linux-firmware
  * emerge -va pciutils && lspic -nnk || lspci -nnk | grep "Kernel driver in use:"
  * make -j4 && make modules\_install && make install
1. configure the bootloader
  * emerge -av grub os-prober
  * echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
  * grub-install --target=x86_64-efi --efi-directory=/boot/efi/path
  * grub-mkconfig -o /boot/grub/grub.cfg
1. [networkmanager](https://wiki.gentoo.org/wiki/NetworkManager)

# TODO
## edit out the previous
* ACPI
* latop_tools
* i3
* xorg
* intel drivers
* dbus
* pulseaudio (consolekit)
* alsa
* suspend and hibernation
* logrotate
* recommend software
