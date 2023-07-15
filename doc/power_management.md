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

- Acpi handels events trough `/etc/acpi/`
- Browse around `/etc/laptop-mode/conf.d`

Note see available suspension modes `cat /sys/power/state`
