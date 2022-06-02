# How to setup GUIX/Pantherx on raspberry
Tested on GUIX and PantherX

## Build system image
On aarch64 or x86_64 host
```
guix system image raspberry-pi.scm --skip-checks --verbosity=3```
```

## Flash Image to sd card
I use either Balena Etcher or dd.

# Final steps
Insert SD card into Raspberry, enter user `pi` and password `123`. You will be asked to change it on first login.
