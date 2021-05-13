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

Flags:
- [`-O`](https://wiki.gentoo.org/wiki/GCC_optimization#-O)  
  
  `-O` controls the overall level of optimization, `-O2` is *recommended* level of optimization unless the system has special needs

- [`-pipe`](https://wiki.gentoo.org/wiki/GCC_optimization#-pipe)
  
  Incraces compilation process by telling the compiler to use pipes instead of temporary files 
  
- [`-march=native`](https://wiki.gentoo.org/wiki/Safe_CFLAGS#Automatic_CPU_detection_by_the_compiler)

  Enables auto-detection of the CPU's architecture
  
  Check what GCC "native" know about your CPU: 
  ```bash
  gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
  ```
  
End result:
```bash
grep -iP flags /etc/portage/make.conf
COMMON_FLAGS="-O2"
COMMON_FLAGS="${COMMON_FLAGS} -pipe"
COMMON_FLAGS="${COMMON_FLAGS} -march=native"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
```

## CPU feature flags

- [Make conf wiki](https://wiki.gentoo.org/wiki//etc/portage/make.conf#CPU_FLAGS_X86)
- [Gentoo wiki](https://wiki.gentoo.org/wiki/CPU_FLAGS_X86)

The `CPU_FLAGS_X86` variable informs Portage about the CPU flags (features) permitted by the CPU
```bash
emerge --ask --oneshot app-portage/cpuid2cpuflags
perl -ni -e 'print unless /^[[:blank:]]*CPU_FLAGS_X86/' /etc/portage/make.conf                        # rm if present
cpuid2cpuflags | perl -pe 's/(?<=[:]\ )([\w[:blank:]]+)/"$1"/; s/[:]/\ =/;' >> /etc/portage/make.conf # append detected flags
```

## Portage features

- [make conf wiki](https://devmanual.gentoo.org/eclass-reference/make.conf/index.html#index)

Features:
- `candy`

  Enable a special progress indicator when emerge.
  
- `downgrade-backup`

  Create a backup of the installed version before it is unmerged (if a binary package of the same version does not already exist)
  
- `unmerge-backup`

  Create a backup of each package before it is unmerged (if a binary package of the same version does not already exist)
  
[A note on build package emerge counterpart: enabling feature will prevent emerge **--ignore-default-opts** take effect](https://forums.gentoo.org/viewtopic-t-1075024-start-0.html)

End result:
```bash
grep -P FEATURE /etc/make.conf
FEATURE="${FEATURE} candy"
FEATURE="${FEATURE} downgrade-backup"
FEATURE="${FEATURE} unmerge-backup"
```

**NOTE:** interesting to implement `buildpkg` or `buildsyspkg`

## Emerge default options

- [Gentoo wiki](https://wiki.gentoo.org/wiki/EMERGE_DEFAULT_OPTS)
- [man emerge](https://dev.gentoo.org/~zmedico/portage/doc/man/emerge.1.html)

Default options

- `--usepkg=y` 

  tells emerge to use binary packages (from $PKGDIR) if they are available

- `--binpkg-changed-deps=y`

  Tells emerge to ignore binary packages for which the corresponding ebuild dependencies have changed since the packages were built
  
- `--binpkg-respect-use=y`
  
  Tells emerge to ignore binary packages if their USE flags don't match the current configuration.
  
- `--quiet=y`
  
  Results may vary, but the general outcome is a reduced or condensed output from portage's displays
  
- `--verbose=y`

  Currently this flag causes emerge to print out GNU info errors, if any, and to show the USE flags that will be used for each package when pretending

- `--keep-going=y`

  Continue as much as possible after an error. See also `--resume` and `--skipfirst`

- `--jobs=${NPROC} --load-average=${NPROC}`

   emerge runs NPROC jobs at a time and try to keep the load average of the system less than ${NPROC}
  
End result:
```bash
grep -P EMERGE_DEFAULT_OPTS /etc/make.conf
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --usepkg=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --binpkg-changed-deps=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --binpkg-respect-use=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --quiet=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --verbose=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --keep-going=y"
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=${NPROC} --load-average=${NPROC}"
```

## Makeopts

- [Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#MAKEOPTS)
- [Gentoo wiki](https://wiki.gentoo.org/wiki/MAKEOPTS)
- [Optimal value makeopts](https://blogs.gentoo.org/ago/2013/01/14/makeopts-jcore-1-is-not-the-best-optimization/)
- [Optimal value makeopts and emerge paralllels](https://www.preney.ca/paul/archives/341)

- `MAKEOPTS`

  defines how many parallel compilations should occur when installing a package
  
End result:
```
grep -P MAKEOPTS /etc/make.conf
MAKEOPTS="--jobs=${NPROC} --load-average=${NPROC}"
```
