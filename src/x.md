```
euse -E X xinerama
```

```
# detect the graphics card and follow corresponding wiki;
# likely just modify VIDEO_CARDS make.conf variable
lspci | grep -i VGA
```

```
emerge --fetchonly xorg-server display-manager-init lightdm
```

```
# etc/conf.d/display-manager
DISPLAYMANAGER="lightdm"
```

```
rc-update add dbus default && \
rc-update add display-manager default
```

Do not forget to add users to `video` group.
