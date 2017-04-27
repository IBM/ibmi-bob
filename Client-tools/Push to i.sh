#!/bin/bash

#
# Push files to the build directory
# $1 = The path to the project folder (Eclipse-formatted in OS-specific path nomenclature)
# $2 = Name of the build settings file
#

function realpath {
    local p=$(cd "$1" && echo "$PWD")
    
    echo "${p}"
}

localScriptDir="${0%/*}"

# Validate arguments
if (( $# != 2 )); then
    echo "Incorrect number of incoming parameters; expected path to project directory and name of build settings file."
    echo "Exiting script."
    exit 1
fi

buildSettingsDir="$1"
buildSettingsFile="$2"

# If using Windows, generate Windows-friendly .buildsettings path for display purposes and insure the actual path is in Cygwin format.
if [[ "$(uname -s)" == CYGWIN* ]]; then
    buildSettingsDir=$(cygpath -u "${buildSettingsDir}")
    buildSettings="${buildSettingsDir}/${buildSettingsFile}"
    buildSettingsDisplay=$(cygpath -w "${buildSettings}")
else
    buildSettings="${buildSettingsDir}/${buildSettingsFile}"
    buildSettingsDisplay=$buildSettings
fi

if [[ ! -d "${buildSettingsDir}" ]]; then
    echo "The build settings (project) directory '${buildSettingsDir}' does not exist. Exiting script."
    exit 1
fi

if [[ ! -f "${buildSettings}" ]]; then
    echo "The build settings file '${buildSettingsDisplay}' does not exist. Has it been set up yet? Exiting script."
    exit 1
fi

source "${buildSettings}"

# If using Windows, generate Windows-friendly localSourceDir path for display purposes.
if [[ "$(uname -s)" == CYGWIN* ]]; then
    localSourceDirDisplay=$(cygpath -wa "${localSourceDir}")
else
    localSourceDirDisplay=$(realpath "${localSourceDir}")
fi

# Push code to i
echo "*** Pushing source code to IBM i ***"
echo "Source directory: ${localSourceDirDisplay}"
echo "Target directory: ${system}:${remoteSourceDir}"
rsync -avzh --exclude .git --exclude .deps --exclude removed --exclude Logs --exclude temp --exclude .project --exclude .DS_Store --delete -e "ssh -i '${privateKey}'" "${localSourceDir}" ${user}@${system}:"${remoteSourceDir}"
echo "*** End of source code push ***"
