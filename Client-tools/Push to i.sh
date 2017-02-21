#!/bin/bash

# Push files to the build directory

localScriptDir="${0%/*}"
privateKeyDir="/cygdrive/c/Users/$(whoami)/.ssh"  # Change this if not using Cygwin. It should point to user's .ssh directory

# Load in settings specific to this user.
. ${localScriptDir}/../../my_build_settings.sh

echo "Source directory: $(realpath ${localSourceDir})"
echo "Target directory: ${system}:${remoteSourceDir}"
rsync -avzh --exclude .git --exclude .deps --exclude removed --exclude Logs --exclude temp --delete -e "ssh -i ${privateKeyDir}/id_rsa" "${localSourceDir}" ${user}@${system}:"${remoteSourceDir}"
