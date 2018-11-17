# @kaz's archlinux package repository

[![CircleCI](https://circleci.com/gh/kaz/arch-repo.svg?style=svg)](https://circleci.com/gh/kaz/arch-repo)

## List of packages

- [x86_64](https://github.com/kaz/arch-repo/tree/gh-pages/x86_64)

## Usage

Add following lines to your `/etc/pacman.conf`

```
[kaz]
SigLevel = Optional
Server = https://kaz.github.io/arch-repo/$arch/
```
