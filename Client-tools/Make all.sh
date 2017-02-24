#!/bin/bash


#
# Kick off a `make all` on the build directory to the target library.
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

# Issue remote command to build everything
echo "Source code directory: ${system}:${remoteSourceDir}"
echo "Target build library: ${buildLib}"
ssh -i ${privateKey} ${user}@${system} ". /QOpenSys/etc/profile && make all OBJPATH:=/QSYS.LIB/${buildLib}.LIB -f ${remoteSourceDir}/xpmake"

# Update our local Logs directory with the new stuff from the i.
echo
echo -n "Copying build logs back to $(realpath ${localSourceDir})."
rsync -azh -e "ssh -i ${privateKey}" ${user}@${system}:"${remoteSourceDir}/Logs" "${localSourceDir}"
echo "..Done!"
