[![release](https://github.com/{{GITHUB_REPO_OWNER}}/{{GITHUB_REPO_NAME}}/workflows/release/badge.svg)](https://github.com/{{GITHUB_REPO_OWNER}}/{{GITHUB_REPO_NAME}}/actions?query=workflow%3Arelease)

## List of packages

- [{{ARCH}}](https://github.com/{{GITHUB_REPO_OWNER}}/{{GITHUB_REPO_NAME}}/tree/gh-pages/{{ARCH}})

## Usage

Add following lines to your `/etc/pacman.conf`.

```
[{{GITHUB_REPO_OWNER}}]
SigLevel = Optional
Server = https://{{GITHUB_REPO_OWNER}}.github.io/{{GITHUB_REPO_NAME}}/$arch/
```
