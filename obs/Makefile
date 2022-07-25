# lunzip is the default and used as an example
ifeq ($(NAME),)
	NAME := lunzip
endif

generic:
	NAME=$(NAME) _generic/build-scripts/10tarball_directory.sh
	NAME=$(NAME) _generic/build-scripts/20obs.sh
clean:
	rm -rf tarballs/$(NAME)_*

lunzip:
	NAME=lunzip make
clean_lunzip:
	NAME=lunzip make clean
	
clean_all:
	rm -rf tarballs
	rm -rf home:*

.PHONY: generic clean clean_all lunzip clean_lunzip
