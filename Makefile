.SILENT:
.PHONY: help

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Package
PACKAGE_NAME        = backup-manager
PACKAGE_DESCRIPTION = Versatile yet easy to use command line backup tool for GNU/Linux. Suitable for desktop and servers.
PACKAGE_VERSION     = 0.7.11
PACKAGE_RELEASE     = elao1
PACKAGE_GROUP       = admin
PACKAGE_PROVIDES    = backup-manager
PACKAGE_MAINTAINER  = infra@elao.com
PACKAGE_LICENSE     = GPL

## Package - Source
PACKAGE_SOURCE          = https://github.com/sukria/Backup-Manager.git
PACKAGE_SOURCE_REVISION = 7894744

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Build
build: build@debian-wheezy

build@debian-wheezy:
	docker run \
	    --rm \
	    --volume `pwd`:/srv \
	    --workdir /srv \
	    --tty \
	    debian:wheezy \
	    sh -c '\
	        apt-get update && \
	        apt-get install -y make && \
	        make build-package@debian-wheezy \
	    '

build-package@debian-wheezy:
	apt-get install -y git gettext checkinstall
	# Get sources
	git clone ${PACKAGE_SOURCE} ~/package
	cd ~/package && git checkout ${PACKAGE_SOURCE_REVISION}
	# Package description
	echo ${PACKAGE_DESCRIPTION} > ~/package/description-pak
	# Install
	cd ~/package && make install PREFIX=/usr PERL5DIR=/usr/share/perl5
	# Checkinstall
	cd ~/package && checkinstall \
	    -y \
	    --install=no \
	    --nodoc \
	    --pkgname=${PACKAGE_NAME} \
	    --pkgversion=${PACKAGE_VERSION} \
	    --pkgrelease=${PACKAGE_RELEASE} \
	    --pkggroup=${PACKAGE_GROUP} \
	    --provides=${PACKAGE_PROVIDES} \
	    --maintainer=${PACKAGE_MAINTAINER} \
	    --pkglicense=${PACKAGE_LICENSE} \
	    --pkgsource=${PACKAGE_SOURCE} \
	    make install PREFIX=/usr PERL5DIR=/usr/share/perl5
	# Move package files
	mv ~/package/*.deb /srv/files
