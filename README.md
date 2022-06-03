# PantherX OS on Raspberry Pi

This is a early preview: **Work in progress!**

## Supported Boards

- Raspberry Pi 4
- Raspberry Compute Module 4 (coming soon)

## Setup

Tested on GUIX and PantherX

### Build system image

On aarch64 or x86_64 host

```bash
guix system image raspberry-pi.scm --skip-checks --verbosity=3
```

### Flash Image to sd card

I use either Balena Etcher or dd.

### Final steps

Insert SD card into Raspberry, enter user `pi` and password `123`. You will be asked to change it on first login. 

You may like to resize rootfs with resize2fs as default partition size doesn't fit much.

## Discuss / Get help

Checkout our forum at [community.pantherx.org](https://community.pantherx.org/)