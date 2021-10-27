#!/bin/bash

echo " "
echo "Creating a package version..."

sfdx force:package:version:create -p 0Ho690000004CG4CAM -k 12345 -v asperii@admin.fssk -f config/project-scratch-def.json --json -w 40 --skipvalidation

# sh scripts/bash/createPackageVersion.sh

# Example:
# New package version is created:
# dev@0.2.0-21

# Installation link:https://login.salesforce.com/packaging/installPackage.apexp?p0=04t69000001hVY7AAM
# Password: 12345