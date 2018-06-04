ARCH=`uname -a | sed -E 's/.+ (.+) .+/\1/'`

.PHONY: commit
commit: database
	git branch -D gh-pages || true
	git checkout --orphan gh-pages
	git rm -r --force --cached --ignore-unmatch * .gitignore
	git add --all --force $(ARCH)/*
	git config user.email "12085646+kaz@users.noreply.github.com"
	git config user.name "Kazuki Sawada (buildsystem)"
	git commit -m "built at `date +'%Y/%m/%d %H:%M:%S'`"

.PHONY: database
database: package
	repo-add $(ARCH)/kaz.db.tar.gz $(ARCH)/*.pkg.tar.xz

.PHONY: package
package: init
	./build.sh $(ARCH)

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
