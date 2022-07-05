
all: build after_build
clean: clean_build clean_after_build

build: build_tree compilation_templates bootstrap_and_compile
clean_build: clean_build_tree clean_compilation_templates clean_bootstrap_and_compile

after_build: backup_tarball distrib_files obs
clean_after_build: clean_backup_tarball clean_distrib_files clean_obs

no-obs: build backup_tarball distrib_files
clean_no-obs: clean_build clean_backup_tarball clean_distrib_files

build_tree: 10build_tree
10build_tree:
	build-scripts/10build_tree.sh
clean_build_tree:
	build-scripts/clean_10build_tree.sh

compilation_templates: 20compilation_templates
20compilation_templates:
	build-scripts/20compilation_templates.sh
clean_compilation_templates:
	build-scripts/clean_20compilation_templates.sh

bootstrap_and_compile: 30bootstrap_and_compile
30bootstrap_and_compile:
	build-scripts/30bootstrap_and_compile.sh
clean_bootstrap_and_compile:
	build-scripts/clean_30bootstrap_and_compile.sh

backup_tarball: 40backup_tarball
40backup_tarball:
	build-scripts/40backup_tarball.sh
clean_backup_tarball:
	build-scripts/clean_40backup_tarball.sh

distrib_files: 50distrib_files
50distrib_files:
	build-scripts/50distrib_files.sh
clean_distrib_files:
	build-scripts/clean_50distrib_files.sh

obs: 60obs
60obs:
	build-scripts/60obs.sh
clean_obs:
	build-scripts/clean_60obs.sh

.PHONY: all clean no-obs clean_no-obs build clean_build after_build clean_after_build 10build_tree build_tree clean_build_tree 20compilation_templates compilation_templates clean_compilation_templates 30bootstrap_and_compile bootstrap_and_compile clean_bootstrap_buildout 40backup_tarball backup_tarball clean_backup_tarball 50distrib_files distrib_files clean_distrib_files 60obs obs clean_obs
