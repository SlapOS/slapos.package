####################################################
# Use on script as source release_configuration.sh
####################################################

# Edit for release
VERSION=`grep ^slapos.core slapos_repository/stack/slapos.cfg | cut -f3 -d\ `
# Edit for release
RECIPE_VERSION=`cd slapos_repository && git describe --tags $(git rev-list --tags --max-count=1)`
# Edit for release
RELEASE=1

CURRENT_DIRECTORY="$(pwd)"
# Development Section
OBS_DIRECTORY=$CURRENT_DIRECTORY/home:VIFIBnexedi:branches:home:VIFIBnexedi/SlapOS-Node

TEMPLATES_DIRECTORY=$CURRENT_DIRECTORY/templates
SLAPOS_ORGINAL_DIRECTORY=slapos-node
SLAPOS_DIRECTORY_PREFIX=sn
SLAPOS_DIRECTORY=${SLAPOS_DIRECTORY_PREFIX}_$VERSION+$RECIPE_VERSION+$RELEASE

VERSION_REGEX="s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s/\%VERSION\%/$VERSION/g;s/\%RELEASE\%/$RELEASE/g;s/\%SLAPOS_DIRECTORY\%/$SLAPOS_DIRECTORY/g"
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
