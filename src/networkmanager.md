#### Networkmanager

```
euse -E networkmanager
```

```
emerge --ask --fetchonly networkmanager
```

```
rc-update add NetworkManager default
```

Network manager cli cheat sheet

```
# save current wifi connection to reuse
# sudo cat /etc/NetworkManager/system-connections/YOUR-SSID
# nmcli dev status
# nmcli radio wifi
nmcli dev wifi list # see wifi networks
# sudo nmcli dev wifi connect network-ssid password "network-password"
```
