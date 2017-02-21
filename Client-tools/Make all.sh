#!/bin/bash

# Kick off a `make all` on the build directory to the target library.

thisDir="${0%/*}"
privateKeyDir="/cygdrive/c/Users/$(whoami)/.ssh"  # Change this if not using Cygwin. It should point to user's .ssh directory

# Load in settings specific to this user.
. ${localScriptDir}/../../my_build_settings.sh

echo "Source code directory: ${system}:${remoteSourceDir}"
echo "Target build library: ${buildLib}"
ssh -i ${privateKeyDir}/id_rsa ${user}@${system} ". /QOpenSys/etc/profile && make all OBJPATH:=/QSYS.LIB/${buildLib}.LIB -f ${remoteSourceDir}/xpmake"
