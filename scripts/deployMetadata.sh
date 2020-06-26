#!/bin/bash
source `dirname $0`/config.sh

echo "converting packagable source to metadata"
sfdx force:source:convert -r ./force-app/main -d metadata -n=$PACKAGENAME

echo "deploy metadata to packaging org and run all tests"
sfdx force:mdapi:deploy -u=$PACKAGING_ORG_ALIAS -w 6 -d metadata -l RunAllTestsInOrg

echo "open packaging org"
sfdx force:org:open -u=$PACKAGING_ORG_ALIAS

echo "Packaging Org is ready"
