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
# "Cleans" a directory of recently-imported IBM i source files, or a single file, by removing the line number
# and date fields from the beginning of each line, as well as the spaces from the end of each line.
# $1 = The path to a directory or file to clean.
#

# If every line starts with 12 digits of numbers (sequence # plus date field) then strip them out,
# convert CRLF to LF, and remove trailing spaces.  Otherwise, convert CRLF to LF and remove trailing
# spaces, because RDi probably didn't do that.
function clean_file {
    local p="$1"
    local f=$(basename "$p")
    
    (( procTotal += 1 ))
    
    # Perhaps a random line of code starts with a bunch of numbers, so only remove them
    # if every line in the file starts with 12 numbers.
    if (( $(grep -E -c '^[0-9]{12}' "$p") == $(wc -l <"$p") )); then
        tr -d '\r' <"$p" | sed -r -e 's/^.{12}//' -e 's/ *$//' >"/tmp/$f"
    else
        tr -d '\r' <"$p" | sed -r -e 's/ *$//' >"/tmp/$f"
    fi
    
    # Only replace file with cleaned version if it contains text and something was changed.
    if [ -s "/tmp/$f" ]; then
        if ! cmp --quiet "$p" "/tmp/$f"; then
            mv "/tmp/$f" "$p"
            echo "${f} cleaned."
            (( cleanTotal += 1 ))
        else
            echo "${f} examined."
        fi
    else
        echo "${f} examined."
    fi
    rm "/tmp/$f" 2>/dev/null
}

# Number of files cleaned.
cleanTotal=0

# Number of files processed.
procTotal=0

# Path of file or directory to clean should have been passed in.
if (( $# != 0 )); then
    path="$1"
else
    echo 'A file or directory to clean was not specified. Exiting script.'
    exit 1
fi

# If using Windows, make path bash-friendly.
if [[ "$(uname -s)" == CYGWIN* ]]; then
    path=$(cygpath -u "${path}")
fi

# Clean file(s).  Ignore '.' files (like .project).  Ignore directories starting with '.' (like .git).  Ignore
# our own Logs directory.
find "${path}" -not \( -path '*/.*' -prune \) -not \( -path "${path}/Logs" -prune \) -not -name '.*' -type f -print |
{
    while read f; do
        clean_file "$f"
    done
    
    echo
    echo "${procTotal} files examined."
    echo "${cleanTotal} files cleaned."
}
