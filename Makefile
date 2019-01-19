.phony: all
all: build-deb

build-deb:      ## Build DEB package for Ubuntu Bionic
	exec ./build-deb-docker.sh

build-deb-trusty:      ## Build DEB package for Ubuntu Trusty
	exec ./build-deb-docker.sh trusty

clean:
	rm -rf deb-package

help:           ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
