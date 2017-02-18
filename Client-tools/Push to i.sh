#!/bin/bash

# Push files to the build directory

thisDir="${0%/*}"
srcDir="${thisDir}/../../express-xp/"
tgtDir="/Build/XP/jeff2"
system=S814JAZZ
user=JBERMAN

echo "Source directory: ${srcDir}"
echo "Target directory: ${system}:${tgtDir}"
rsync -avzh --dry-run --exclude .git  --exclude removed "${srcDir}" ${user}@${system}:"${tgtDir}"
