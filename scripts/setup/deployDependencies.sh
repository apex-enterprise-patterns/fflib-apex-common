#!/bin/bash

echo "Deploying dependencies... This can take some time and terminal will wait!"
echo "Installing Apex Mocks..."
sfdx force:package:install -p 04t3a000000PmYgAAK -k keaper -w 20

./scripts/setup/configureScratchOrg.sh
