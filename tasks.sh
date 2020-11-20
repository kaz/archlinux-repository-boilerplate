#!/bin/bash

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
	printf "${BUILD_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${BUILD_USER}
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
	parse_env
	if ( pacman -Sy --noconfirm --needed --config <(printf "[${GIT_USER}]\nSigLevel = Optional\nServer = https://${GIT_USER}.github.io/${GIT_REPO}/${ARCH}/") yay ); then
		:
	else
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
	parse_env --must
	mkdir -p ${REPO_DIR}/${ARCH}
	sed -e "s/{{ARCH}}/${ARCH}/g" -e "s/{{GIT_USER}}/${GIT_USER}/g" -e "s/{{GIT_REPO}}/${GIT_REPO}/g" template.md > "${REPO_DIR}/README.md"
	cd ${REPO_DIR}/${ARCH}
	find ${BUILD_DIR} -name *.pkg.tar.zst -exec cp -f {} . \;
	repo-add "${GIT_USER}.db.tar.gz" *.pkg.tar.zst
}

commit() {
	parse_env --must
	cd ${REPO_DIR}
	git init
	git checkout --orphan gh-pages
	git add -A
	git config user.email "${GIT_USER}@users.noreply.github.com"
	git config user.name "${GIT_USER} (github-actions)"
	git commit -m "$(date +'%Y/%m/%d %H:%M:%S')"
}

push() {
	if [ -z "${GIT_REMOTE}" ]; then
		echo 'env $GIT_REMOTE is not set'
		return 1
	fi
	cd ${REPO_DIR}
	git remote add origin "${GIT_REMOTE}"
	git push --force --set-upstream origin gh-pages
}

parse_env() {
	if [ "${1}" = "--must" ] && [ -z "${GITHUB_REPOSITORY}" ]; then
		echo 'env $GITHUB_REPOSITORY is not set'
		return 1
	fi
	GIT_USER=$(awk -F '/' '{print $1}' <<< "${GITHUB_REPOSITORY}")
	GIT_REPO=$(awk -F '/' '{print $2}' <<< "${GITHUB_REPOSITORY}")
}

set -xe
"$@"
