#!/bin/bash

DIFF=$(dirname $0)/patch/$(basename $PWD).diff
if [ -f $DIFF ]; then
	patch -f PKGBUILD $DIFF > /dev/null
	makepkg --syncdeps --noconfirm --nobuild
fi

makepkg $@
