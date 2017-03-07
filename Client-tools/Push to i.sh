#!/bin/bash

#
# Push files to the build directory
#

function realpath {
    local p=$(cd "$1" && echo "$PWD")
    
    echo "${p}"
}

localScriptDir="${0%/*}"

# Load in settings specific to this project. Path to settings file should have been passed in.
if (( $# != 0 )); then
    buildSettings="$1"
    buildSettingsDir=$(dirname "$1")
else
    echo 'No build settings file was passed in. Exiting script.'
    exit 1
fi

if [[ ! -d "${buildSettingsDir}" ]]; then
    echo "The build settings (project) directory '${buildSettingsDir}' does not exist. Exiting script."
    exit 1
fi

if [[ ! -f "${buildSettings}" ]]; then
    echo "The build settings file '${buildSettings}' does not exist. Has it been set up yet? Exiting script."
    exit 1
fi

source "${buildSettings}"

# If using Windows, generate Windows-friendly path name for display purposes.
if [[ "$(uname -s)" == CYGWIN* ]]; then
    localSourceDirDisplay=$(cygpath -wa "${localSourceDir}")
else
    localSourceDirDisplay=$(realpath "${localSourceDir}")
fi

# Push code to i
echo "*** Pushing source code to IBM i ***"
echo "Source directory: ${localSourceDirDisplay}"
echo "Target directory: ${system}:${remoteSourceDir}"
rsync -avzh --exclude .git --exclude .deps --exclude removed --exclude Logs --exclude temp --exclude .project --delete -e "ssh -i ${privateKey}" "${localSourceDir}" ${user}@${system}:"${remoteSourceDir}"
echo "*** End of source code push ***"
