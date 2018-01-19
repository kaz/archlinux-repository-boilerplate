#!/bin/bash -xe

DIR=`pwd`

rm -f kaz.* *.pkg.tar.xz

sudo pacman -Sy --noconfirm --needed \
	openssl-1.0 \
	pcre \
	readline \
	perl \
	curl \
	unzip \
	zip \
	git \
	base-devel

for PKG in $(ls *.diff | sed 's/\.diff//g'); do
	cd $DIR
	rm -rf /tmp/$PKG

	git clone https://aur.archlinux.org/$PKG.git /tmp/$PKG
	patch /tmp/$PKG/PKGBUILD $DIR/$PKG.diff

	cd /tmp/$PKG
	makepkg --skippgpcheck
	sudo pacman -U --noconfirm *.pkg.tar.xz
	cp *.pkg.tar.xz $DIR

	cd $DIR
	rm -rf /tmp/$PKG
done

cd $DIR
repo-add kaz.db.tar.gz *.pkg.tar.xz
