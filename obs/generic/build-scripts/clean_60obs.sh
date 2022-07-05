#!/bin/bash
set -e

source build-scripts/00env.sh

# reverse the action of obsoleting the potentially altered buildout and restoring the backed up one
if [ ! -e "$RUN_BUILDOUT_DIR"/bin/backup.buildout ]; then
	if [ -e "$RUN_BUILDOUT_DIR"/bin/buildout ]; then
		cp "$RUN_BUILDOUT_DIR"/bin/buildout "$RUN_BUILDOUT_DIR"/bin/backup.buildout
	fi
fi
if [ -e "$RUN_BUILDOUT_DIR"/bin/old.buildout ]; then
	mv "$RUN_BUILDOUT_DIR"/bin/old.buildout "$RUN_BUILDOUT_DIR"/bin/buildout
fi

TMP_TARGET="$INITIAL_DIR"/obs-tmp/"$SOFTWARE_NAME"
TMP_TARGET=$(realpath -m "$TMP_TARGET")
rm -rf "$TMP_TARGET"
