#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
### Fix the go/ directory.

# For some reason the user does not have the "write" permission on some directories within $RUN_BUILDOUT_DIR/go/. As it is
# needed on a directory to delete a file in it, the if block adds the permissions to every
# directories in go/.
# This is performed before copying the directory tree elsewhere so that every copy is fixed.
# It also allows the cleaning script to delete the result of the current script.
if [ -d "$RUN_BUILDOUT_DIR"/go ]; then
	find "$RUN_BUILDOUT_DIR"/go -name "*" -type d -exec chmod u+xw {} +
fi

cd "$INITIAL_DIR"
### Backup $TARBALL_DIR for debugging or other purpose

# add "backup." before the directory name pointed to by $TARBALL_DIR
BACKUP_DIR="$TARBALL_DIR"/../backup."$SOFTWARE_AND_VERSION"
BACKUP_DIR=$(realpath -m "$BACKUP_DIR")
# Delete the potential previous backup and backup the newly created build tree instead.
rm -rf "$BACKUP_DIR"
cp -r "$TARBALL_DIR" "$BACKUP_DIR"
