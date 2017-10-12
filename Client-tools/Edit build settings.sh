#!/bin/bash
#
# Copyright 2017 S4i Systems, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Determine platform and then open build settings file appropriately.
# $1 = The path to the project folder (Eclipse-formatted in OS-specific path nomenclature)
# $2 = Name of the build settings file
#

function realpath {
    local p=$(cd "$1" && echo "$PWD")
    
    echo "${p}"
}

localScriptDir="${0%/*}"

# Verify that path to project directory was passed in and is valid.
if (( $# != 2 )); then
    echo "Incorrect number of incoming parameters; expected path to project directory and name of build settings file."
    echo "Exiting script."
    exit 1
fi

buildSettingsDir="$1"
buildSettingsFile="$2"
ignoreItems=('/Logs/' "/$buildSettingsFile")
first=1

# If using Windows, generate Windows-friendly path name for display purposes and insure the actual path is in Cygwin format.
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

# Create a build settings file, if it doesn't already exist, defaulting the local source code path to the passed-in directory.
if [[ ! -f "${buildSettings}" ]]; then
    echo "No build settings file exists at '${buildSettingsDisplay}'."
    echo "(Perhaps this is the first run?)"
    echo "Created new settings file with default values."
    sed -e "s|^\(localSourceDir\)=.*|\1=\"${buildSettingsDir}/\"|" ./buildsettings.sh.dist > "${buildSettings}"
fi

# Add Bob items to .gitignore file, if Git is being used for this project.
if [[ -d "${buildSettingsDir}/.git" ]]; then
    if [[ ! -f "${buildSettingsDir}/.gitignore" ]]; then
        echo "File .gitignore created."
    fi
    
    for item in ${ignoreItems[@]}; do
        if ! grep -qs "^${item}$" "${buildSettingsDir}/.gitignore"; then
            if [ $first -eq 1 ]; then
                echo >> "${buildSettingsDir}/.gitignore"
                first=0
            fi
			echo "${item}" >> "${buildSettingsDir}/.gitignore"
			echo "'${item}' added to .gitignore."
		fi
    done
fi

# Record hash of settings file to later see if something changed.
settingsHash=$(openssl sha1 "${buildSettings}")

# Since we're likely called in the background from an editor, open the settings file in a new window (this part is OS-specific)
case "$(uname -s)" in
    Darwin)
        echo "Launching Build Settings editor.  Please set values to fit your environment, then press control-x, 'y', Enter to save and exit."
        sed -e "s|^buildSettings=.*|buildSettings=\"${buildSettings}\"|" "Launch Nano.sh" >"/tmp/Launch Nano.sh"
        chmod +x "/tmp/Launch Nano.sh"
        open -a Terminal.app "/tmp/Launch Nano.sh"
        while [[ -f "/tmp/Launch Nano.sh" ]]; do
            sleep .1
        done
        ;;
    
    CYGWIN*)
        nano="$(cygpath -w $(which nano))"        
        echo "Launching Build Settings editor.  Please set values to fit your environment, then press control-x, 'y', Enter to save and exit."
        cmd.exe /C "start /WAIT $nano '${buildSettingsDisplay}'"
        ;;
    *)
        echo "Support for this OS hasn't yet been implemented."
        ;;
esac

# Note if settings actually changed.
newSettingsHash=$(openssl sha1 "${buildSettings}")
echo
if [[ "${settingsHash}" != "${newSettingsHash}" ]]; then
    echo "New build settings detected!"
else
    echo "No build settings were changed."
fi
