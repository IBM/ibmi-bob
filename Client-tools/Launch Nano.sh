#!/bin/bash

# This script exists as a way to get the macOS Terminal window to close after the build settings file is edited
# and nano is exited.  Its parent script causes this script to execute in a new Terminal window.
# The AppleScript code below causes the Terminal window to close when nano exits.
#
# Due to system limitations, a temporary version of this script is created with the path to the build settings
# file hard coded.

# Will be populated by the calling script at runtime.
buildSettings=

# Clean up the temporary file. This is set up as a handler for the usual
# termination signals.
function cleanup {
    if [[ -f "/tmp/Launch Nano.sh" ]]; then
        rm "/tmp/Launch Nano.sh"
    fi
}

# Remove the temporary file (this script) on exit.
trap cleanup SIGINT SIGTERM EXIT

# Launch `nano` editor
nano "${buildSettings}"

# Change Terminal window's title to something unique and then use that to close the window.
echo -n -e "\033]0;killme\007"
osascript -e 'tell application "Terminal" to close (every window whose name contains "killme")' &
