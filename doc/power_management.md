# Power management

## Quickstart

```
# take advantage of Intel Linux thermal daemon
emerge thermald && rc-config add thermald
```

```
euse -E acpi
```

```
emerge tlp acpid acpitool acpilight powertop
```

NOTE: `tlp` is alternative to `laptop-mode-tools`, see [wiki](https://wiki.gentoo.org/wiki/Power_management).

```
rc-update add acpid default && \
rc-update add tlp default
```

## Usage

`powertop --calibrate`

ACPI configuration is located at `/etc/acpi`. Maybe not unwise to clean up the content of `default.sh` so all events are unhandled. 

Note see available suspension modes `cat /sys/power/state`

### Userspace

ACPI handling is done system wide which may not be desirable, e.g. `pulseaudio`
is running a server per user, making it unpractical to mute/vol up/vol down; (it
is a global state of the system).

`acpilight` is providing `xbacklight` utility to change brightness with user
privileges.

The cited above minimum configuration is setting up a framework to handle
special events globally, if one wishes.

By default it will log all events both `syslog`, of current run and aggregate
into `/var/log/acpid.log`.

Nowadays some events are actually handled via `elogind`, those will not appear
into the logs.
