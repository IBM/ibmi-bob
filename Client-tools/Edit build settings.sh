#!/bin/bash

#
# Determine platform and then open build settings file appropriately.
#

function realpath {
    local p="$(cd $1 && echo $PWD)"
    
    echo "${p}"
}

argError=0
localScriptDir="${0%/*}"

# Verify that path to settings file was passed in.
if (( $# != 0 )); then
    buildSettings="$1"
else
    echo 'No build settings file was passed in. Exiting script.'
    exit 1
fi

# If using Windows, generate Windows-friendly path name for display purposes.
buildSettingsDisplay=$buildSettings
if [[ "$(uname -s)" == CYGWIN* ]]; then
    buildSettingsDisplay=$(cygpath -w "${buildSettings}")
fi

# Create a build settings file, if it doesn't already exist.
if [[ ! -f "${buildSettings}" ]]; then
    echo "No build settings file exists at '${buildSettingsDisplay}'."
    echo "(Perhaps this is the first run?)"
    echo "Created new settings file with default values."
    mkdir -p "${buildSettings%/*}"
    cp "./my_build_settings.sh.dist" "${buildSettings}"
fi

# Record hash of settings file to later see if something changed.
settingsHash=$(openssl sha1 "${buildSettings}")

# Since we're likely called in the background from an editor, open the settings file in a new window (this part is OS-specific)
case "$(uname -s)" in
    Darwin)
        osascript -e 'tell application \"Terminal\" to do script \"nano  ${buildSettings}; exit\"'
        osascript -e 'tell application "System Events" to set frontmost of process "Terminal" to true'
        ;;
    
    CYGWIN*)
        echo "Launching Build Settings editor.  Please set values to fit your environment, then press control-x, 'y', Enter to save and exit."
        /cygdrive/c/Windows/System32/cmd.exe /C "start /WAIT C:\cygwin64\bin\nano.exe ${buildSettings}"
        ;;
    *)
        echo "Support for this OS hasn't yet been implemented."
        ;;
esac

# Note if settings actually changed.
newSettingsHash=$(openssl sha1 "${buildSettings}")
if [[ "${settingsHash}" != "${newSettingsHash}" ]]; then
    echo "New settings detected!"
else
    echo "No settings were changed."
fi
