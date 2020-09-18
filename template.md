# @$GITHUB_USER's archlinux package repository

![release](https://github.com/$GITHUB_USER/arch-repo/workflows/release/badge.svg)

## List of packages

- [x86_64](https://github.com/$GITHUB_USER/arch-repo/tree/gh-pages/x86_64)

## Usage

Add following lines to your `/etc/pacman.conf`.

```
[$GITHUB_USER]
SigLevel = Optional
Server = https://$GITHUB_USER.github.io/arch-repo/$arch/
```
