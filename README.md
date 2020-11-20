# ArchLinux Repository Boilerplate

This is a boilerplate for creating your own **automated** ArchLinux package repository.
You can easily add any AUR packages you want.
GitHub Actions runs daily build on behalf of you.

## Features

- ⚙️ Works with GitHub Actions / GitHub Pages
	- You don't need to setup any server machines. This is _serverless_. 😎
- ⚡ Blazingly fast
	- Build packages parallelly.
	- Use ccache to reduce compilation time.
- 🔧 Easy to setup
	- Just a few steps. See instructions below!

## How to create your own repository?

1. Click the green `Use this template` button ↗ to create your own GitHub repository.
	- You can find detailed instruction [HERE](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template), or [fork](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo) this repository.
	- If you can't find the `Use this template` button, this repository may be copied one. Original repository is [HERE](https://github.com/kaz/archlinux-repository-boilerplate).
1. Specify packages you want to build [HERE](./.github/workflows/build.yaml#L27-L31). ✍
1. [Enable GitHub Pages](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) and select `gh-pages` branch as a publishing source.
	- Due to limitation of `GITHUB_TOKEN`, GitHub Actions cannot make GitHub Pages enable in workflow. So you have to activate it manually. 😥
1. That's all! 👏
	- Wait some minutes and visit newly-created your package repository 👉 `https://{{your_account}}.github.io/{{your_repository_name}}/`

## Tips

- Edit [.github/workflows/build.yaml](./.github/workflows/build.yaml) to modify build behavior.
