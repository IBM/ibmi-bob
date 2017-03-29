#!/bin/bash

#
# Kick off a `make all` on the build directory to the target library.
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
