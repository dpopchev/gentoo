# OpenNTPD

Lightweigh server to clock sync

## Quickstart

```
emerge --ask net-misc/openntpd
```

Attempt clock sync on startup, might slow boot if server unreachable

```
# /etc/conf.d/ntpd
NTPD_OPTS="-s"
```

```
/etc/init.d/ntpd start
```

```
rc-update add ntpd default
```
