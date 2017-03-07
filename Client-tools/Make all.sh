#!/bin/bash

#
# Kick off a `make all` on the build directory to the target library.
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

# Issue remote command to build everything
# Calling the `makelog` wrapper script in the ibm-i-make directory to log `make`s output.
echo "*** Building code on IBM i ***"
echo "Remote source code directory: (${system}) ${remoteSourceDir}"
echo "Target build library: ${buildLib}"
ssh -i ${privateKey} ${user}@${system} '. /QOpenSys/etc/profile && $(dirname "${IBMIMAKE:?Environment variable IBMIMAKE has not been set. Please set it to the location of the IBMiMake makefile. A good place to do this is in /QOpenSys/etc/profile, by including a line such as \`export IBMIMAKE=/Build/ibm-i-make/IBMiMake\`}")'"/makelog all OBJPATH:=/QSYS.LIB/${buildLib}.LIB -f ${remoteSourceDir}/${makefile}"

# Update our local Logs directory with the new stuff from the i.
echo
echo -n "Copying build logs back to ${localSourceDirDisplay}."
rsync -azh -e "ssh -i ${privateKey}" ${user}@${system}:"${remoteSourceDir}/Logs" "${localSourceDir}"
echo "..Done!"
echo "*** End of build process ***"