# @{{GIT_USER}}'s ArchLinux package repository

[![release](https://github.com/{{GIT_USER}}/{{GIT_REPO}}/workflows/release/badge.svg)](https://github.com/{{GIT_USER}}/{{GIT_REPO}}/actions?query=workflow%3Arelease)

## List of packages

- [x86_64](https://github.com/{{GIT_USER}}/{{GIT_REPO}}/tree/gh-pages/{{ARCH}})

## Usage

Add following lines to your `/etc/pacman.conf`.

```
[{{GIT_USER}}]
SigLevel = Optional
Server = https://{{GIT_USER}}.github.io/{{GIT_REPO}}/$arch/
```
