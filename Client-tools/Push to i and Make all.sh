#!/bin/bash

#
# Calls other scripts to effectively push files to the build directory and then perform a `make all`.
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

# Push code to i
"./Push to i.sh" "${buildSettingsDir}" "${buildSettingsFile}"
echo
"./Make all.sh" "${buildSettingsDir}" "${buildSettingsFile}"
