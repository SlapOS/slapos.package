
all: no_obs obs
clean: clean_no_obs clean_obs

no_obs: build_tree template_stage bootstrap_buildout
clean_no_obs: clean_build_tree clean_template_stage clean_bootstrap_buildout

build_tree:
	build-scripts/build_tree.sh
clean_build_tree:
	build-scripts/clean_build_tree.sh

template_stage:
	build-scripts/template_stage.sh
clean_template_stage:
	build-scripts/clean_template_stage.sh

bootstrap_buildout:
	build-scripts/bootstrap_buildout.sh
clean_bootstrap_buildout:
	build-scripts/clean_bootstrap_buildout.sh

obs:
	build-scripts/obs.sh
clean_obs:
	build-scripts/clean_obs.sh

.PHONY: all clean no_obs clean_no_obs build_tree clean_build_tree template_stage clean_template_stage bootstrap_buildout clean_bootstrap_buildout obs clean_obs
