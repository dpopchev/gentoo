```
euse -E logrotate -p app-admin/sysklogd
```

```
emerge -v sysklogd
```

```
rc-update add sysklogd default
```

When cron is installed schedule weekly `logrotate` execution, e.g. script `/etc/cron.weekly/logrotate.sh`:

```
#!/bin/sh
/usr/sbin/logrotate -f /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```

Do not forget to give it execution rights, e.g. `chmod u+x /etc/cron.weekly/logrotate.sh`.
