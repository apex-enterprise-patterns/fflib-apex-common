#!/bin/bash

echo "Creating new scratch org..."
sfdx force:org:create -d 30 -f config/project-scratch-def.json --setdefaultusername
echo "Creating new scratch org complete."

./scripts/setup/deployDependencies.sh
