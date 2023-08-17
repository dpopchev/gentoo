# X

## Quickstart

```
euse -E X xinerama
```

```
# detect the graphics card and follow corresponding wiki;
# likely just modify VIDEO_CARDS make.conf variable
lspci | grep -i VGA
```

```
# make.conf INPUT_DEVICES is predefined, change if needed
# INPUT_DEVICES="libinput synaptics"
```

```
emerge xorg-server display-manager-init lightdm
```

```
# etc/conf.d/display-manager
DISPLAYMANAGER="lightdm"
```

```
rc-update add dbus default && \
rc-update add display-manager default
```

## Usage

Grant trusted users acceess by adding them into `video` group.
