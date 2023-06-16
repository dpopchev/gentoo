#### X

```
euse -E X
```

```
emerge --ask --fetchonly xorg-server display-manager-init lightdm i3
```

```
# etc/conf.d/display-manager
DISPLAYMANAGER="lightdm"
```

```
rc-update add dbus default && \
rc-update add display-manager default
```
