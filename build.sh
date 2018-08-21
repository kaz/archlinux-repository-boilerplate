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
	if [ -f $DIR/$ARCH/$TARGET-*.pkg.tar.xz ]; then
		printf "\033[97;44m>>> [Skipped] '$TARGET' already exists <<<\033[0m\n"
		continue
	fi
	rm -rf $DIR/$ARCH/$pkgname-*.pkg.tar.xz

	printf "\033[97;42m>>> [Start] building '$TARGET' <<<\033[0m\n"

	cd /tmp/$PKG
	makepkg --skippgpcheck --syncdeps --noconfirm
	sudo pacman -U --noconfirm *.pkg.tar.xz
	cp *.pkg.tar.xz $DIR/$ARCH

	cd $DIR
	rm -rf /tmp/$PKG
done
