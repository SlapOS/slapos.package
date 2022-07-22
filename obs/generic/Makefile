
all: tarball_directory obs

tarball_directory:
	build-scripts/10tarball_directory.sh
clean_tarball_directory:
	rm -rf tarballs/lunzip_1-1/

obs:
	build-scripts/20obs.sh
clean_obs:
	rm -rf home:oph.nxd/lunzip/*

clean_all:
	rm -rf tarballs
	rm -rf home:oph.nxd

.PHONY: all
