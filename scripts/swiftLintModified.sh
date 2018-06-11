#!/bin/sh

#====================================================================================
# This script runs SwiftLint on the modified files
#====================================================================================

# Run for both staged and unstaged files
CURRENTDIR=`pwd`
echo "$CURRENTDIR"
#cd `git rev-parse --show-toplevel`
git diff --name-only | grep ".swift" | while read filename; do ./runSwiftLint.sh -w "${filename}"; done
git diff --cached --name-only | grep ".swift" | while read filename; do ./runSwiftLint.sh -w "${filename}"; done
cd $CURRENTDIR
