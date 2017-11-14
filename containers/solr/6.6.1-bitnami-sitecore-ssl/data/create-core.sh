#!/bin/bash
#
# create solr cores for Sitecore
# exit immediatly if exit command exists with non-zero status
set -e
# show script with all parameters passed => $@
echo "Executing $0 $@"
# if VERBOSE output is set, expand commands before execution
if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi
# set core variables
CORE=${1:-gettingstarted}
CONFIG_SOURCE=${2:-'/opt/bitnami/solr/server/solr/configsets/basic_configs'}
coresdir="/bitnami/solr/data"

# create cores from /configsets/basic_configs
coredir="$coresdir/$CORE"
if [[ ! -d $coredir ]]; then
    cp -r $CONFIG_SOURCE/ $coredir
    touch "$coredir/core.properties"
    echo "dataDir=/bitnami/indexes/$CORE" > $coredir/core.properties
    echo created "$coredir"
else
    echo "core $CORE already exists"
fi