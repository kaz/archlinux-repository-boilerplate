#!/bin/bash

ARCH=$(uname -m)

: ${BUILD_USER:="builder"}

: ${REPO_DIR:="/tmp/repo"}
: ${BUILD_DIR:="/tmp/build"}
: ${PKGS_DIR:="/tmp/_packages_"}
: ${CCACHE_DIR:="/tmp/ccache"}

: ${GIT_REMOTE:=""}
: ${GIT_BRANCH:="gh-pages"}
: ${GIT_COMMIT_SHA:=""}

: ${GITHUB_ACTOR:=""}
GITHUB_REPO_OWNER=${GITHUB_REPOSITORY%/*}
GITHUB_REPO_NAME=${GITHUB_REPOSITORY#*/}

# This is a workaround to fix pacman cannot run correctly.
# The problem will be fixed if GitHub Actions worker used runc 1.0.0-rc93, which is now rc92.
# ref. https://github.com/actions/virtual-environments/issues/2658
pacman() {
	if ! md5sum -c <(echo e151f7aac8d3411e49e697b5461c34f9 /usr/lib/libc-2.33.so); then
		curl -L https://repo.archlinuxcn.org/x86_64/glibc-linux4-2.33-4-x86_64.pkg.tar.zst | tar x --zstd -C /
	fi
	command pacman "$@"
}

initialize() {
	pacman -Syu --noconfirm --needed git ccache
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
	sudo -u ${BUILD_USER} mkdir -p "${BUILD_DIR}" "${PKGS_DIR}"
	sudo -u ${BUILD_USER} yay -Sy --noconfirm --nopgpfetch --mflags "--skippgpcheck" --builddir "${BUILD_DIR}" "$@"
 	# Move package to PKGS_DIR
	find "${BUILD_DIR}" -name "*.pkg.tar.zst"
	cp -rv "${BUILD_DIR}/$@/"*.pkg.tar.zst "${PKGS_DIR}/"
}

repository() {
	ensure_env GITHUB_REPO_OWNER

	mkdir -p ${REPO_DIR}/${ARCH}
	render_template templates/README.md > "${REPO_DIR}/README.md"
	render_template templates/_config.yml > "${REPO_DIR}/_config.yml"

	cd ${REPO_DIR}/${ARCH}
	find ${PKGS_DIR} -name *.pkg.tar.zst -exec cp -f {} . \;
	repo-add "${GITHUB_REPO_OWNER}.db.tar.gz" *.pkg.tar.zst
	rename '.tar.gz' '' *.tar.gz	# repo-add originally creates links, this basically replaces them with the actual db archives
}

render_template() {
	ensure_env GIT_BRANCH
	ensure_env GITHUB_REPO_OWNER
	ensure_env GITHUB_REPO_NAME

	sed \
		-e "s/{{ARCH}}/${ARCH}/g" \
		-e "s/{{GIT_BRANCH}}/${GIT_BRANCH}/g" \
		-e "s/{{GITHUB_REPO_OWNER}}/${GITHUB_REPO_OWNER}/g" \
		-e "s/{{GITHUB_REPO_NAME}}/${GITHUB_REPO_NAME}/g" \
		"${1}"
}

commit() {
	ensure_env GIT_BRANCH
	ensure_env GITHUB_ACTOR

	cd ${REPO_DIR}
	git init
	git checkout --orphan "${GIT_BRANCH}"
	git add --all
	git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
	git config user.name "${GITHUB_ACTOR}"

	if [ -z "${GIT_COMMIT_SHA}" ]; then
		git commit -m "built at $(date +'%Y/%m/%d %H:%M:%S')"
	else
		git commit -m "built from ${GIT_COMMIT_SHA}"
	fi
}

push() {
	ensure_env GIT_REMOTE
	ensure_env GIT_BRANCH

	cd ${REPO_DIR}
	git remote add origin "${GIT_REMOTE}"
	git push --force --set-upstream origin "${GIT_BRANCH}"
}

ensure_env() {
	: ${!1:?"env \$${1} is not set"}
}

set -xe
"$@"
