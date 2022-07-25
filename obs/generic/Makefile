
lunzip_tarball_directory:
	NAME=lunzip build-scripts/10tarball_directory.sh
lunzip_clean_tarball_directory:
	rm -rf tarballs/lunzip_1-1/
	rm -rf templates/compilation-templates/tmp/lunzip

lunzip_obs:
	NAME=lunzip build-scripts/20obs.sh
lunzip_clean_obs:
	rm -rf templates/distribution-templates/tmp/lunzip
	rm -rf distribution-specifics/lunzip
	rm -rf obs-tmp/lunzip

lunzip: lunzip_tarball_directory lunzip_obs 
clean_lunzip: lunzip_clean_obs lunzip_clean_tarball_directory

clean_all:
	rm -rf tarballs
	rm -rf templates/compilation-templates/tmp
