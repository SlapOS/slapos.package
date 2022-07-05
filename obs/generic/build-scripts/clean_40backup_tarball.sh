#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
# Nothing is done here, as 04backup_tarball.sh only modifies permissions in "$RUN_BUILDOUT_DIR"/go/ and backs up the "$TARBALL_DIR" (one do not want to delete the backup if it's not to create a new one).
