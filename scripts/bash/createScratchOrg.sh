#!/bin/bash
echo " "
echo "Creating scratch org..."
sfdx force:org:create -s -a $1 -f config/project-scratch-def.json -d 30 -v $2
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

# sh scripts/bash/createScratchOrg.sh FSSKSprint1_2 FSSKDevHub