
all: build_tree template_stage bootstrap_buildout obs
clean: clean_build_tree clean_template_stage clean_bootstrap_buildout clean_obs

build_tree:
	./build_tree.sh
clean_build_tree:
	./clean_build_tree.sh

template_stage:
	./template_stage.sh
clean_template_stage:
	./clean_template_stage.sh

bootstrap_buildout:
	./bootstrap_buildout.sh
clean_bootstrap_buildout:
	./clean_bootstrap_buildout.sh

obs:
	./obs.sh
clean_obs:
	./clean_obs.sh

.PHONY: all clean build_tree clean_build_tree template_stage clean_template_stage bootstrap_buildout clean_bootstrap_buildout obs clean_obs
