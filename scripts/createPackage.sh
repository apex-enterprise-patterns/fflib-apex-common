#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

if [ -z "$secrets.DEV_HUB_URL" ]; then
  echo "set default devhub user"
  execute sfdx force:config:set defaultdevhubusername=$DEV_HUB_ALIAS
fi

echo "List existing package versions"
sfdx force:package:version:list -p $PACKAGENAME --concise

echo "Create new package version"
PACKAGE_VERSION="$(execute sfdx force:package:version:create -p $PACKAGENAME -x -w 10 --json | jq '.result.SubscriberPackageVersionId' | tr -d '"')"
echo $PACKAGE_VERSION

if [ $QA_ORG_ALIAS ]; then
  if [ $secrets.QA_URL ]; then
    echo "Authenticate QA Org"
    echo $secrets.QA_URL > qaURLFile
    execute sfdx force:auth:sfdxurl:store -f qaURLFile -a $QA_ORG_ALIAS
    rm qaURLFile
  fi

  echo "Install in QA Org"
  execute sfdx force:package:install -p $PACKAGE_VERSION -u $QA_ORG_ALIAS -b 10 -w 10 -r
fi