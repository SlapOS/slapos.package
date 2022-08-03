
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


dep--mca--static: dep--mca--static_tarball_directory dep--mca--static_obs 
clean_dep--mca--static: dep--mca--static_clean_obs dep--mca--static_clean_tarball_directory

dep--mca--static_tarball_directory:
	NAME=dep--mca--static build-scripts/10tarball_directory.sh
dep--mca--static_clean_tarball_directory:
	rm -rf tarballs/dep--mca--static_*

dep--mca--static_obs:
	NAME=dep--mca--static build-scripts/20obs.sh
dep--mca--static_clean_obs:
	rm -rf home:oph.nxd/dep--mca--static/*


dep--fluent-bit: dep--fluent-bit_tarball_directory dep--fluent-bit_obs 
clean_dep--fluent-bit: dep--fluent-bit_clean_obs dep--fluent-bit_clean_tarball_directory

dep--fluent-bit_tarball_directory:
	NAME=dep--fluent-bit build-scripts/10tarball_directory.sh
dep--fluent-bit_clean_tarball_directory:
	rm -rf tarballs/dep--fluent-bit_*

dep--fluent-bit_obs:
	NAME=dep--fluent-bit build-scripts/20obs.sh
dep--fluent-bit_clean_obs:
	rm -rf home:oph.nxd/dep--fluent-bit/*


clean_all:
	rm -rf tarballs
	rm -rf home:oph.nxd

.PHONY: lunzip clean_lunzip dep--mca--static clean_dep--mca--static dep--fluent-bit clean_dep--fluent-bit
