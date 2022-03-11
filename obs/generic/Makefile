
all: build distrib_files obs
clean: clean_build clean_distrib_files clean_obs

build: build_tree compilation_templates bootstrap_buildout
clean_build: clean_build_tree clean_compilation_templates clean_bootstrap_buildout

no-obs: build distrib_files
clean_no-obs: clean_build clean_distrib_files

build_tree:
	build-scripts/build_tree.sh
clean_build_tree:
	build-scripts/clean_build_tree.sh

compilation_templates:
	build-scripts/compilation_templates.sh
clean_compilation_templates:
	build-scripts/clean_compilation_templates.sh

bootstrap_buildout:
	build-scripts/bootstrap_buildout.sh
clean_bootstrap_buildout:
	build-scripts/clean_bootstrap_buildout.sh

distrib_files:
	build-scripts/distrib_files.sh
clean_distrib_files:
	build-scripts/clean_distrib_files.sh

obs:
	build-scripts/obs.sh
clean_obs:
	build-scripts/clean_obs.sh

.PHONY: all clean build clean_build build_tree clean_build_tree compilation_templates clean_compilation_templates bootstrap_buildout clean_bootstrap_buildout distrib_files clean_distrib_files obs clean_obs
