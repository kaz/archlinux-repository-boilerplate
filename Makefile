.ONESHELL:

BUILD_DIR=/tmp/build
REPO_DIR=/tmp/repository

ARCH=`uname -a | sed -E 's/.+ (.+) .+/\1/'`

.PHONY: setup
setup:
	useradd -m build
	chown -R build:build .
	echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	cat mirrorlist > /etc/pacman.d/mirrorlist
	printf '\n[kaz]\nSigLevel = Optional\nServer = https://kaz.github.io/arch-repo/$$arch/\n' >> /etc/pacman.conf
	pacman -Sy --noconfirm yay git ccache base-devel
	sed -i '/\[kaz\]/,$$d' /etc/pacman.conf
	sed -i 's/!ccache/ccache/g' /etc/makepkg.conf
	printf 'cache_dir = /tmp/ccache' > /etc/ccache.conf

.PHONY: packages
packages:
	yay -Sy --noconfirm --nopgpfetch --makepkg $(CURDIR)/makepkg.sh --builddir $(BUILD_DIR) $$(sed '/^$$/d' packages.md | sed -E 's/^\s*-\s*//' | tr '\n' ' ')

.PHONY: repository
repository:
	rm -rf $(REPO_DIR)
	mkdir -p $(REPO_DIR)/$(ARCH)
	cp -r .circleci $(REPO_DIR)
	cd $(REPO_DIR)/$(ARCH)
	find $(BUILD_DIR) -name *.pkg.tar.xz -exec cp -f {} . \;
	repo-add kaz.db.tar.gz *.pkg.tar.xz

.PHONY: commit
commit:
	cd $(REPO_DIR)
	git init
	git checkout --orphan gh-pages
	git add -A
	git config user.email "12085646+kaz@users.noreply.github.com"
	git config user.name "Kazuki Sawada (CircleCI)"
	git commit -m "built at $$(date +'%Y/%m/%d %H:%M:%S')"

.PHONY: push
push:
	cd $(REPO_DIR)
	git remote add upstream https://$${GITHUB_ACCESS_TOKEN}@github.com/$${CIRCLE_PROJECT_USERNAME}/$${CIRCLE_PROJECT_REPONAME}
	git push --force --set-upstream upstream gh-pages
