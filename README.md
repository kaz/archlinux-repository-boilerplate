# kaz's archlinux package repository

Currently, only `x86_64` is supported.

## List of packages

- [x86_64](https://github.com/kaz/arch-repo/tree/gh-pages/x86_64)

## Usage

Add following lines to your `/etc/pacman.conf`

```
[kaz]
SigLevel = Optional
Server = https://kaz.github.io/arch-repo/$arch/
```
