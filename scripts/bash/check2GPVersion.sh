#!/bin/bash
echo " "
echo "Creating scratch org..."
sfdx force:org:create -s -f config/project-scratch-def.json -d 3 -v $1
echo " "
echo "Installing 2GP package version..."
sfdx force:package:install --package $2 -w 10 -s AllUsers -k 12345 -r
echo " "
echo "Openning scratch org..."
sfdx force:org:open