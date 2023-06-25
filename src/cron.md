```
emerge -v fcron && \
emerge --config sys-process/fcron
```

```
rc-update add fcron default
```

Do not forget to give trusted users access by adding the to `cron` group.
