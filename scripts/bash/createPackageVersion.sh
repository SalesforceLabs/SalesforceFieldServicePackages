#!/bin/bash

echo " "
echo "Creating a package version..."

sfdx force:package:version:create -p 0Ho4W00000000FJSAY --installationkeybypass -v asperii@admin.fssk -f config/project-scratch-def.json --json -w 40

# sh scripts/bash/createPackageVersion.sh

# Example:
# New package version is created:
# Salesforce Field Service Starter Kit@4.4.0-1

# Installation link:https://login.salesforce.com/packaging/installPackage.apexp?p0=04t4W0000038XRgQAM