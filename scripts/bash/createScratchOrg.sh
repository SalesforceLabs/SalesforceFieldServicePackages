#!/bin/bash
echo " "
echo "Creating scratch org..."
sfdx force:org:create -s -a $1 -f config/project-scratch-def.json -d 30 -v asperii@admin.fssk
echo " "
echo "Installing FSL Spring 2022 236.0.47 package version..."
sfdx force:package:install --package 04t3y000001Df7B -w 10 -s AllUsers -r
echo " "
echo "Pushing source to scratch org..."
sfdx config:set restDeploy=false
sfdx force:source:push
# echo " "
# echo "Assigning permission set..."
# sfdx force:user:permset:assign -n Developer
echo "Openning scratch org..."
sfdx force:org:open
sfdx force:user:password:generate --targetusername $1

# sh scripts/bash/createScratchOrg.sh FSSKRelX