# Network configuration

## Quickstart

```
euse -E networkmanager
```

```
emerge networkmanager
```

```
rc-update add NetworkManager default
```

## Usage

Grant trusted users to manage network connections, without elevated rights, by adding them into `plugdev` group.

### Migrate connections

Connections are found at `/etc/NetworkManager/system-connections` in file per Wifi Network. 

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
