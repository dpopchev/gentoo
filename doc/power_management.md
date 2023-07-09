#### Laptop mode

```
euse -E acpi
```

```
emerge -f laptop-mode-tools acpid
```

```
rc-update add acpid default && \
rc-update add laptope_mode default
```

Browse around `/etc/laptop-mode/conf.d`

Acpi events can be handled via `/etc/acpi/default.sh`

Note see available suspension modes `cat /sys/power/state`
