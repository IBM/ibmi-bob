#!/bin/bash

#
# Push files to the build directory
#

function realpath {
    local p="$(cd $1 && echo $PWD)"
    
    echo "${p}"
}


argError=0
localScriptDir="${0%/*}"

# Load in settings specific to this user. Path to settings file should have been passed in.
if (( $# != 0 )); then
    buildSettings="$1"
    . ${buildSettings}
else
    argError=1
fi

if (( argError )); then
    echo 'No build settings file was passed in. Exiting script.'
    exit ${argError}
fi

# Push code to i
echo "Source directory: $(realpath ${localSourceDir})"
echo "Target directory: ${system}:${remoteSourceDir}"
rsync -avzh --exclude .git --exclude .deps --exclude removed --exclude Logs --exclude temp --delete -e "ssh -i ${privateKey}" "${localSourceDir}" ${user}@${system}:"${remoteSourceDir}"
