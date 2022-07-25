####################################################
# Sourced in scripts from build-scripts/
####################################################

INITIAL_DIR=$(pwd)/
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")

SCRIPTS_DIR=build-scripts/
TMP_FILES_PATH="$SCRIPTS_DIR"/_tmp-files
ENV_BASE="$TMP_FILES_PATH"/base.env
ENV_AFTER_1ST_SOURCE="$TMP_FILES_PATH"/after-1st-source.env
ENV_AFTER_2ND_SOURCE="$TMP_FILES_PATH"/after-2nd-source.env
SOURCE_1="$SCRIPTS_DIR"/01env.sh
SOURCE_2="$SCRIPTS_DIR"/custom-env/"$NAME"_env.sh
DIFF_BASE_VS_1ST_SOURCE="$TMP_FILES_PATH"/base-vs-1st-source.diff
DIFF_1ST_SOURCE_VS_2ND_SOURCE="$TMP_FILES_PATH"/1st-source-vs-2nd-source.diff

if [ ! -f "$SOURCE_2" ]; then
	source "$SOURCE_1"
	return 0
fi

mkdir -p "$TMP_FILES_PATH"
set > "$ENV_BASE"
source "$SOURCE_1"
set > "$ENV_AFTER_1ST_SOURCE"
source "$SOURCE_2"
set > "$ENV_AFTER_2ND_SOURCE"

diff -e "$ENV_BASE" "$ENV_AFTER_1ST_SOURCE" | grep = | grep -v "^_=" | grep -v PIPESTATUS | cut -d"=" -f1 | sort > "$DIFF_BASE_VS_1ST_SOURCE"
diff -e "$ENV_AFTER_1ST_SOURCE" "$ENV_AFTER_2ND_SOURCE" | grep = | grep -v "^_=" | grep -v PIPESTATUS | cut -d"=" -f1 | sort > "$DIFF_1ST_SOURCE_VS_2ND_SOURCE"

variables_to_unset=$(comm -23 "$DIFF_BASE_VS_1ST_SOURCE" "$DIFF_1ST_SOURCE_VS_2ND_SOURCE")
for i in $variables_to_unset; do
	unset $i
done

source "$SOURCE_1"

rm -r "$TMP_FILES_PATH"
