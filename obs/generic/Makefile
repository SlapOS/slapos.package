
lunzip: lunzip_tarball_directory lunzip_obs 
clean_lunzip: lunzip_clean_obs lunzip_clean_tarball_directory

lunzip_tarball_directory:
	NAME=lunzip build-scripts/10tarball_directory.sh
lunzip_clean_tarball_directory:
	rm -rf tarballs/lunzip_*

lunzip_obs:
	NAME=lunzip build-scripts/20obs.sh
lunzip_clean_obs:
	rm -rf home:oph.nxd/lunzip/*


clean_all:
	rm -rf tarballs
	rm -rf home:oph.nxd

.PHONY: all lunzip clean_lunzip
