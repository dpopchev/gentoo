```
emerge -a sudo
```

Edit so to allow members of wheel group execute any command with `visudo`

Allow more consecutive authentication failures before `faillock` kick you out by editing `/etc/security/faillock.conf`

```
# Deny access if the number of consecutive authentication failures
# for this user during the recent interval exceeds n tries.
# The default is 3.
deny = 10
``` 
