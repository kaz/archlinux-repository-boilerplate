ARCH=`uname -a | sed -E 's/.+ (.+) .+/\1/'`

.PHONY: database
database: package
	repo-add $(ARCH)/kaz.db.tar.gz $(ARCH)/*.pkg.tar.xz

.PHONY: package
package: init
	./build.sh `pwd` $(ARCH)

.PHONY: init
init:
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

.PHONY: clean
clean:
	rm -rf $(ARCH)

.PHONY: commit
commit: database
	git config user.email "build-system@6715.jp"
	git config user.name "arch-repository"
	git checkout master
	git reset --hard
	rm .gitignore
	git checkout -B gh-pages
	git add -A
	git commit -m "built at `date +'%Y/%m/%d %H:%M:%S'`"
