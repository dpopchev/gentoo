# Logger

## Quickstart

```
euse -E logrotate -p app-admin/sysklogd
```

```
emerge -v sysklogd
```

```
rc-update add sysklogd default
```

## Configs

### Schedule log rotation

```
logrotate_script=/etc/cron.weekly/logrotate.sh && \
touch $logrotate_script && \
chmod u+x $logrotate_script
```

[Sample script](src/logrotate.sh).
