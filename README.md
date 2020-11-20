# ArchLinux Repository Boilerplate

This is a boilerplate for creating your own **automated** ArchLinux package repository.
You can easily add any AUR packages you want.
GitHub Actions runs daily build on behalf of you.

## Features

- ⚙️ Works with Github Actions / Github Pages
	- You don't need to setup any server machines. This is _serverless_. 😎
- ⚡ Blazingly fast
	- Build packages parallelly.
	- Use ccache to reduce compilation time.
- 🔧 Easy to setup
	- Just a few steps. See instructions below!

## How to create your own repository?

1. Click the green `Use this template` button ↗ to create your own github repository.
	- You can find detailed instruction [here](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).
	- or [fork](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo) this repository.
2. Specify packages you want to build [here](https://github.com/kaz/arch-repo/blob/master/.github/workflows/build.yaml#L25-L27).
3. That's all! 👏
	- Wait some minutes and visit newly-created your package repository 👉 [https://github.com/{{your_account}}/{{your_name}}/tree/gh-pages](../../tree/gh-pages)

## Tips

- Edit [.github/workflows/build.yaml](https://github.com/kaz/arch-repo/blob/master/.github/workflows/build.yaml) to modify build behavior.
