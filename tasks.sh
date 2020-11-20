#!/bin/bash

ARCH=$(uname -m)

: ${COUNTRY:="Japan"}
: ${BUILD_USER:="builder"}

: ${REPO_DIR:="/tmp/repo"}
: ${BUILD_DIR:="/tmp/build"}
: ${CCACHE_DIR:="/tmp/ccache"}

: ${GIT_REMOTE:=""}
: ${GITHUB_ACTOR:=""}
GITHUB_REPO_OWNER=${GITHUB_REPOSITORY%/*}
GITHUB_REPO_NAME=${GITHUB_REPOSITORY#*/}

mirrorlist() {
	pacman -Sy --noconfirm --needed reflector
	reflector --country "${COUNTRY}" --protocol http --sort rate --save /etc/pacman.d/mirrorlist
}

setup() {
	pacman -Syu --noconfirm --needed base-devel git ccache
	printf "${BUILD_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${BUILD_USER}
	printf "cache_dir = ${CCACHE_DIR}" > /etc/ccache.conf
	sed -i "s/!ccache/ccache/g" /etc/makepkg.conf
	useradd -m ${BUILD_USER}
	chown -R ${BUILD_USER}:${BUILD_USER} .
	setup_yay
}
setup_git() {
	pacman -Sy --noconfirm --needed git
}
setup_yay() {
	if ( pacman -Sy --noconfirm --needed --config <(printf "[${GITHUB_REPO_OWNER}]\nSigLevel = Optional\nServer = https://${GITHUB_REPO_OWNER}.github.io/${GITHUB_REPO_NAME}/${ARCH}/") yay ); then
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
	ensure_env GITHUB_REPO_OWNER
	ensure_env GITHUB_REPO_NAME

	mkdir -p ${REPO_DIR}/${ARCH}
	render_template templates/README.md > "${REPO_DIR}/README.md"
	render_template templates/_config.yml > "${REPO_DIR}/_config.yml"

	cd ${REPO_DIR}/${ARCH}
	find ${BUILD_DIR} -name *.pkg.tar.zst -exec cp -f {} . \;
	repo-add "${GITHUB_REPO_OWNER}.db.tar.gz" *.pkg.tar.zst
}

render_template() {
	ensure_env GITHUB_REPO_OWNER
	ensure_env GITHUB_REPO_NAME

	sed -e "s/{{ARCH}}/${ARCH}/g" -e "s/{{GITHUB_REPO_OWNER}}/${GITHUB_REPO_OWNER}/g" -e "s/{{GITHUB_REPO_NAME}}/${GITHUB_REPO_NAME}/g" "${1}"
}

commit() {
	ensure_env GITHUB_ACTOR

	cd ${REPO_DIR}
	git init
	git checkout --orphan gh-pages
	git add -A
	git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
	git config user.name "${GITHUB_ACTOR} (github-actions)"
	git commit -m "$(date +'%Y/%m/%d %H:%M:%S')"
}

push() {
	ensure_env GIT_REMOTE

	cd ${REPO_DIR}
	git remote add origin "${GIT_REMOTE}"
	git push --force --set-upstream origin gh-pages
}

ensure_env() {
	: ${!1:?"env \$${1} is not set"}
}

set -xe
"$@"
