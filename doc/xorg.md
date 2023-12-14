# X

## Installation

### Requirements

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

### Install

```
emerge xorg-server display-manager-init lightdm libinput
```

## Usage

### Setup

```
# etc/conf.d/display-manager
DISPLAYMANAGER="lightdm"
```

```
rc-update add dbus default
```

```
rc-update add display-manager default
```

Add trusted users into `input` and `video` groups. The former allows direct
device access.

`LightDM` executes users `~/.xprofile` at login.

```
# ~/.xprofile
# disable system beep in X windows
xset -b
# keyboard layout
setxkbmap -layout us,bg -option grp:alt_shift_toggle
```
