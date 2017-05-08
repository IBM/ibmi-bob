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
# This script exists as a way to get the macOS Terminal window to close after the build settings file is edited
# and nano is exited.  Its parent script causes this script to execute in a new Terminal window.
# The AppleScript code below causes the Terminal window to close when nano exits.
#
# Due to system limitations, a temporary version of this script is created with the path to the build settings
# file hard coded.
#

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
