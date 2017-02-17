#!/bin/bash

# Push files to the build directory

srcDir=“~/s4i/Source/express-xp/”
tgtDir=“/Build/XP/jeff2”
user=JBERMAN

rsync -avzh —-dry-run —-exclude .git “${srcDir}” ${user}@s814jazz:”${tgtDir}”