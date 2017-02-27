#!/bin/bash

#
# Calls other scripts to effectively push files to the build directory and then perform a `make all`.
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
"./Push to i.sh" "${buildSettings}"
echo
"./Make all.sh" "${buildSettings}"