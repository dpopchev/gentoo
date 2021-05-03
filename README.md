# Introduction

Since my favourite Linux distribution, thanks to my father, is Gentoo
for long I was relaying on

# Step by step config

Follows the official guidance of the [hadbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) with side notes and code snippets

1. Preparing the disks

    ```bash
    gparted
    ```
    
    Format to **GPT** with **UEFI**. 
    
    - linux-swap with sizing ~ PC RAM
    - uefi in fat32 sizing ~ 256 MB
    - other partitions for Gentoo

    ```bash
    swapon /dev/sd${hdd letter}${swap partition}
    ```
    
    Mount the root partition
    
    ```bash
    mkdir -p /mnt/gentoo
    mount /dev/sd${hdd letter}${root parttion}
    ```

3. Get the stage tarball

    I use **amd64 openrc stage 3**, find it [here](https://www.gentoo.org/downloads/#other-arches)
    
    ```bash
    cd /mnt/gentoo
    wget ${stage3 tarball link}
    tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
    ```

4. Make.conf

    1. [general info](https://wiki.gentoo.org/wiki//etc/portage/make.conf)
    2. `CHOST` -- [set by the profile later](https://wiki.gentoo.org/wiki//etc/portage/make.conf#CHOST)
    3. `CFLAGS/CXXFLAGS` -- [used for C and C++ compilation](https://wiki.gentoo.org/wiki//etc/portage/make.conf#CFLAGS_and_CXXFLAGS); [quick read](https://wiki.gentoo.org/wiki/Safe_CFLAGS)
        
        Check what GCC "native" know about your CPU: 
        ```bash
        gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
        ```
    
    4. `CPU_FLAGS_X86` -- [info](https://wiki.gentoo.org/wiki/CPU_FLAGS_X86)
    
    5. `MAKEOPTS` -- [info](https://wiki.gentoo.org/wiki/MAKEOPTS)
    6. `EMERGE_DEFAULT_OPTS` -- [info](https://wiki.gentoo.org/wiki/EMERGE_DEFAULT_OPTS)

        Gentoo allows to fine tune the build process parallelisum of the packages with the above variables. In most places one can see upper limitations set by the 
        maximum allowed jobs via `--jobs`, but there is additional option avaialbe `--load-average`, [as described in depth](https://www.preney.ca/paul/archives/341)

    7. `FEATURES` -- [info](https://wiki.gentoo.org/wiki/FEATURES)
        
        Incremental variable to enable/disable Portage features. Defautls are set via profile. See what you have with
        
        ```bash
        portageq envvar FEATURES | xargs -n 1
        ```
        
        or
        
        ```bash
        emerge --info | grep ^FEATURES=
        ```
        
        - 'userfetch' -- `chown --recursive --verbose portage:portage /var/db/repos/gentoo`

        [some faq](https://wiki.gentoo.org/wiki/Project:Portage/FAQ)
        
    8. `GENTOO_MIRRORS` -- [info](https://wiki.gentoo.org/wiki/GENTOO_MIRRORS)

    9. `USE` -- [info](https://wiki.gentoo.org/wiki/USE_flag)

    10. `ACCEPT_LICENSE` -- [info](https://wiki.gentoo.org/wiki//etc/portage/make.conf#ACCEPT_LICENSE)

    11. `L10N` -- [info](https://wiki.gentoo.org/wiki/Localization/Guide#LINGUAS)

    12. `INPUT_DEVICES` -- [info](https://packages.gentoo.org/useflags/input_devices_libinput)

    13. `VIDEO_CARDS` -- [info](https://packages.gentoo.org/useflags/video_cards_vesa)

5. Chrooting

    1. [repos](https://wiki.gentoo.org/wiki//etc/portage/repos.conf)
    
        ```bash
        mkdir --parents /mnt/gentoo/etc/portage/repos.conf
        cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
        ```
    
    2. copy dns info from live cd
    
        ```bash
        cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
        ```
    
    3. mount necessary filesystems

        ```bash
        mount --types proc /proc /mnt/gentoo/proc
        mount --rbind /sys /mnt/gentoo/sys 
        mount --make-rslave /mnt/gentoo/sys
        mount --rbind /dev /mnt/gentoo/dev
        mount --make-rslave /mnt/gentoo/dev
        ```
    
        when using non-Gentoo instalation media
    
        ```bash 
        test -L /dev/shm && rm /dev/shm && mkdir /dev/shm 
        mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm 
        chmod 1777 /dev/shm
        ```
    
    4. We are redy to dive in
    
        ```bash
        chroot /mnt/gentoo /bin/env -i TERM=$TERM /bin/bash 
        env-update 
        source /etc/profile 
        export PS1="(chroot) $PS1" 
        ```
        
        and mount boot and other partitions
        
        ```bash
        mount /dev/sd${hdd letter}${partition num} /${destination}
        ```

6. Ebuild repository
    
    ```bash
    emerge-webrsync
    emerge --sync
    ```
    
    [Mirro selection tool](https://wiki.gentoo.org/wiki/Mirrorselect)
    
    ```bash
    emerge --ask --oneshot mirrorselect
    mirrorselect --servers 3 --blocksize 10 -deep # get top most 3 
    mirrorselect -i -r -o >> /etc/portage/repos.conf/gentoo.conf # rsync mirrors manual
    ```

7. Profile select and update
    
    ```bash
    eselect profile list
    eselect profile set 5 # generic desktop, no KDE or GTK affilation
    emerge --ask --verbose --update --deep --newuse @world
    ```

8. Localization
    
    1. Timezone
    
        ```bash
        ls /usr/share/zoneinfo
        echo "${Region}/${City} >> /etc/timezone
        emerge --config sys-libs/timezone-data
        ```

    2. Locals -- [info](https://wiki.gentoo.org/wiki/Localization/Guide)

        ```bash
        grep ${TARGET LANGS} /usr/share/i18n/SUPPORTED >> /etc/locale.gen
        local-gen
        eselect locale list
        eselect locale set ${taget locale}
        ```
    
    3. Env update
        
        ```bash
        env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
        ```
        
9. Kernel -- [info](https://wiki.gentoo.org/wiki/Kernel/Gentoo_Kernel_Configuration_Guide)
    
    ```bash
    emerge --ask sys-kernel/gentoo-sources sys-apps/pciutils
    cd /usr/src/linux 
    make menuconfig
    ```
    
    Every driver vital to the booting should be built in
    
    1. Gentoo Linux --> Generic Driver Options
    - CONFIG_GENTOO_LINUX
    - CONFIG_GENTOO_LINUX_UDEV
    - CONFIG_GENTOO_LINUX_PORTAGE
    - CONFIG_GENTOO_LINUX_INIT_SCRIPT
    3. Processor type
    - CONFIG_SMP 
    - CPU family use `cat /proc/cpuinfo | grep family`
    - CONFIG_X86_MCE
    - CONFIG_X86_MCE_INTEL
    - [microcode](https://wiki.gentoo.org/wiki/Intel_microcode)  
    - CONFIG_IA32_EMULATION
    - CONFIG_ACPI
    5. Disk support
    - CONFIG_BLK_DEV_SD
    - CONFIG_BLK_DEV_SR
    - CONFIG_CHR_DEV_SG
    - CONFIG_ATA
    6. Filesystems
    - CONFIG_EXT4_FS 
    - CONFIG_EXT4_USE_FOR_EXT2 
    - CONFIG_VFAT_FS
    - CONFIG_PROC_FS
    - CONFIG_TMPFS
    - CONFIG_DEVTMPFS
    - CONFIG_DEVTMPFS_MOUNT
    - CONFIG_PARTITION_ADVANCED
    - CONFIG_EFI_PARTITION
    - CONFIG_EFI
    - CONFIG_EFI_STUB
    - CONFIG_EFI_MIXED
    - CONFIG_EFI_VARS
    - [NTFS](https://wiki.gentoo.org/wiki/NTFS)
    8. Drivers
    
    ```bash
    lshw | grep -i driver | perl -pe 's/^.*driver=(\S+).*$/$1/g;' | sort -u
    ```

    - [Ethernet](https://wiki.gentoo.org/wiki/Ethernet)
    - [Wireless](https://wiki.gentoo.org/wiki/Wifi)
    - [USB support](https://wiki.gentoo.org/wiki/USB/Guide)
    - [Bluetooth](https://wiki.gentoo.org/wiki/Bluetoothge)
    
      
ahci                        
ehci-pci
hub
i801_smbus
i915
iwlwifi
lpc_ich
mei_me
pcieport
r8169
rtsx_pci
snd_hda_intel
usb-storage
usbhid
uvcvideo
xhci_hcd

    6. ALSA -- [info](https://wiki.gentoo.org/wiki/ALSA)
    
      ```bash
      lspci | grep -i audio
      ```
      
      [also sound matrix](https://www.alsa-project.org/wiki/SoundCard-Matrix)
      
    7.  Power management/Guide -- [info](https://wiki.gentoo.org/wiki/Power_management/Guide)
    8.  Priniting guide -- [info](https://wiki.gentoo.org/wiki/Printing)

[some source](https://en.terminalroot.com.br/10-fundamental-tips-for-your-gentoo-linux/)

[another to check out](https://github.com/graysky2/kernel_gcc_patch)

[consider tmpfs for temp files](https://wiki.gentoo.org/wiki/Portage_TMPDIR_on_tmpfs)

[also provided packages](https://wiki.gentoo.org/wiki//etc/portage/profile/package.provided)

[consider zram or zswap as shown here](https://wiki.gentoo.org/wiki/Zram)

if non Gentoo Live is used adjust [enviroment](https://wiki.gentoo.org/wiki/Installation_alternatives#Installation_instructions)
 
NOTES:
- [info click](https://devmanual.gentoo.org/eclass-reference/make.conf/index.html)
- Running Gentoo on a VM, use a stage 4 install for setup speed instead of a stage 3.
- random advice
    Really handy feature: keep your packages tidy by using sets.
    
    ```bash
    mkdir /etc/portage/sets
    nano /etc/portage/sets/set-name
    add package atoms to it
    emerge @set-name
    ```
- [add basically anything to portage](https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds)
