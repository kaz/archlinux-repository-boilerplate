#!/bin/bash

ARCH=$1
DIR=`pwd`

sed -i "s/EUID == 0/0/" /usr/bin/makepkg
mkdir -p $ARCH

for PKG in $(cat packages.yml | sed '/^$/d' | sed -E 's/^-\s+//'); do
	cd $DIR
	rm -rf /tmp/$PKG
	git clone https://aur.archlinux.org/$PKG.git /tmp/$PKG

	PATCH=$DIR/patch/$PKG.diff
	if [ -f $PATCH ]; then
		patch /tmp/$PKG/PKGBUILD $PATCH
	fi

	source /tmp/$PKG/PKGBUILD
	TARGET=$pkgname-$pkgver-$pkgrel
	PACKAGE=$DIR/$ARCH/$TARGET-*.pkg.tar.xz

	if [ -f $PACKAGE ]; then
		printf "\033[97;44m>>> [Exists] '$TARGET' already exists <<<\033[0m\n"
	else
		printf "\033[97;42m>>> [Start] building '$TARGET' <<<\033[0m\n"
		rm -rf $DIR/$ARCH/$pkgname-*.pkg.tar.xz

		cd /tmp/$PKG
		makepkg --skippgpcheck --syncdeps --noconfirm
		cp *.pkg.tar.xz $DIR/$ARCH
	fi

	rm -rf /tmp/$PKG
	sudo pacman -U --noconfirm --needed $DIR/$ARCH/*.pkg.tar.xz
done
