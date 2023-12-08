# Power management

## Quickstart

```
# take advantage of Intel Linux thermal daemon
emerge thermald && rc-config add thermald
```

```
# prefer tlp
emerge sys-power/tlp && rc-update add tlp default && rc-service tlp start
```

```
emerge powertop && ppowertop --calibrate
```

```
# `xbacklight` utility to change brightness with user privileges
emerge acpilight
```

## Usage

Note see available suspension modes `cat /sys/power/state`
