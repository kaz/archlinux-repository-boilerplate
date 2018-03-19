#!/bin/bash -xe

DIR=$1
ARCH=$2

if [ -e $ARCH ]; then
	echo "directory $ARCH exists. package build was skipped."
	exit
fi

mkdir $ARCH

for PKG in $(cat packages.yml | sed '/^$/d' | sed -E 's/^-\s+//'); do
	cd $DIR
	rm -rf /tmp/$PKG
	git clone https://aur.archlinux.org/$PKG.git /tmp/$PKG

	PATCH=$DIR/patch/$PKG.diff
	if [ -f $PATCH ]; then
		patch /tmp/$PKG/PKGBUILD $PATCH
	fi

	cd /tmp/$PKG
	makepkg --skippgpcheck
	sudo pacman -U --noconfirm *.pkg.tar.xz
	cp *.pkg.tar.xz $DIR/$ARCH

	cd $DIR
	rm -rf /tmp/$PKG
done
