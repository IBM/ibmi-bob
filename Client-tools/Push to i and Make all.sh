#!/bin/bash

#
# Calls other scripts to effectively push files to the build directory and then perform a `make all`.
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

# Push code to i
"./Push to i.sh" "${buildSettings}"
echo
"./Make all.sh" "${buildSettings}"