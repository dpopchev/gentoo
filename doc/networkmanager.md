# Network configuration

## Quickstart

```
euse -E networkmanager
```

```
emerge --fetchonly networkmanager
```

```
rc-update add NetworkManager default
```

On Gentoo, NetworkManager uses the `plugdev` group to specify which non-root
users can manage system network connections (treated as pluggable devices).

## Configs


### Cheatsheet

Network manager cli cheat sheet

```
# save current wifi connection to reuse
# sudo cat /etc/NetworkManager/system-connections/YOUR-SSID
# nmcli dev status
# nmcli radio wifi
nmcli dev wifi list # see wifi networks
# sudo nmcli dev wifi connect network-ssid password "network-password"
```
