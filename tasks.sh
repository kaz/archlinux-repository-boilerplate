#!/bin/sh

BUILD_USER=builder

CACHE_DIR=/tmp/ccache
BUILD_DIR=/tmp/build
REPO_DIR=/tmp/repository

ARCH=$(uname -m)

mirrorlist() {
	if [ -z "${COUNTRY}" ]; then
		COUNTRY=Japan
	fi
	pacman -Sy --noconfirm --needed reflector
	reflector --country "${COUNTRY}" --protocol http --sort rate --save /etc/pacman.d/mirrorlist
}

setup() {
	pacman -Syu --noconfirm --needed base-devel git ccache
	printf "ALL ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${BUILD_USER}
	printf "cache_dir = ${CACHE_DIR}" > /etc/ccache.conf
	sed -i "s/!ccache/ccache/g" /etc/makepkg.conf
	useradd -m ${BUILD_USER}
	chown -R ${BUILD_USER}:${BUILD_USER} .
	setup_yay
}
setup_git() {
	pacman -Sy --noconfirm --needed git
}
setup_yay() {
	FAILED=0
	if [ -z "${GITHUB_USER}" ]; then
		FAILED=1
	else
		printf "\n[${GITHUB_USER}]\nSigLevel = Optional\nServer = https://${GITHUB_USER}.github.io/arch-repo/\$arch/\n" >> /etc/pacman.conf
		pacman -Sy --noconfirm --needed yay || FAILED=1
		sed -i "/\[${GITHUB_USER}\]/,\$d" /etc/pacman.conf
	fi
	if (( $FAILED )); then
		sudo -u ${BUILD_USER} git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
		cd /tmp/yay-bin
		sudo -u ${BUILD_USER} makepkg --noconfirm --syncdeps --install
	fi
}

package() {
	sudo -u ${BUILD_USER} mkdir -p "${BUILD_DIR}"
	sudo -u ${BUILD_USER} yay -Sy --noconfirm --nopgpfetch --mflags "--skippgpcheck" --builddir "${BUILD_DIR}" "$@"
}

repository() {
	if [ -z "${GITHUB_USER}" ]; then
		echo 'env $GITHUB_USER is not set'
		return 1
	fi
	mkdir -p ${REPO_DIR}/${ARCH}
	sed "s/\$GITHUB_USER/$GITHUB_USER/g" template.md > ${REPO_DIR}/README.md
	cd ${REPO_DIR}/${ARCH}
	find ${BUILD_DIR} -name *.pkg.tar.zst -exec cp -f {} . \;
	repo-add "${GITHUB_USER}.db.tar.gz" *.pkg.tar.zst
}

commit() {
	if [ -z "${GITHUB_USER}" ]; then
		echo 'env $GITHUB_USER is not set'
		return 1
	fi
	cd ${REPO_DIR}
	git init
	git checkout --orphan gh-pages
	git add -A
	git config user.email "${GITHUB_USER}@users.noreply.github.com"
	git config user.name "${GITHUB_USER} (github-actions)"
	git commit -m "$(date +'%Y/%m/%d %H:%M:%S')"
}

push() {
	if [ -z "${UPSTREAM}" ]; then
		echo 'env $UPSTREAM is not set'
		return 1
	fi
	cd ${REPO_DIR}
	git remote add origin "${UPSTREAM}"
	git push --force --set-upstream origin gh-pages
}

set -xe
"$@"
