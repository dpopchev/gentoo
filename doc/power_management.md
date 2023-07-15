# Power management

## Quickstart

```
euse -E acpi
```

```
emerge -f laptop-mode-tools acpid acpitool acpilight
```

```
rc-update add acpid default && \
rc-update add laptope_mode default
```

## Configurations

Browse around `/etc/laptop-mode/conf.d`

ACPI configuration is located at `/etc/acpi`; see a [minimum example](../src/acpi/)

Note see available suspension modes `cat /sys/power/state`

## Userspace

ACPI handling is done system wide which may not be desirable, e.g. `pulseaudio`
is running a server per user, making it undesirable to mute/vol up/vol down; (it
is a global state of the system).

`acpilight` is providing `xbacklight` utility to change brightness with user
privileges.

The cited above minimum configuration is setting up a framework to handle
special events globally, if one wishes.

By default it will log all events both `syslog`, of current run and aggregate
into `/var/log/acpid.log`.

Nowadays some events are actually handled via `elogind`, those will not appear
into the logs.
