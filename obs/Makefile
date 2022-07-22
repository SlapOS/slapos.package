# lunzip is the default and used as an example
ifeq ($(SOFTWARE_NAME),)
$(error Please, source your env before calling make! -> source software_name/env.sh)
endif

generic:
	SOFTWARE_NAME=$(SOFTWARE_NAME) _generic/build-scripts/10tarball_directory.sh
	SOFTWARE_NAME=$(SOFTWARE_NAME) _generic/build-scripts/20obs.sh
clean:
	rm -rf tarballs/$(SOFTWARE_NAME)_*

clean_all:
	rm -rf tarballs
	rm -rf home:*

.PHONY: generic clean clean_all
