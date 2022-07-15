#!/bin/bash

echo "Deploy Source..."
sfdx force:source:push -f -w 30
echo "Deploy Source done."

echo "Configuring permission sets and plugins..."
#sfdx force:apex:execute -f scripts/setup/apex/eraseData.apex
#sfdx force:apex:execute -f scripts/setup/apex/permissionSets.apex
#sfdx force:apex:execute -f scripts/setup/apex/providers.apex
#sfdx force:apex:execute -f scripts/setup/apex/activatePlugins.apex
#sfdx force:apex:execute -f scripts/setup/apex/pushTopics.apex
echo "Configuring permission sets and plugins complete."

echo "Demo Data..."
#sfdx force:data:tree:import -p scripts/setup/data/Data-plan.json
echo "Demo Data done."

echo "Run All Tests..."
sfdx force:apex:test:run --testlevel RunLocalTests --wait 30 --resultformat human
echo "Run All Tests done."

echo "END"
