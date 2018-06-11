#!/bin/sh

function show_usage
{
#====================================================================================
# Show correct usage of the script
#====================================================================================

program=$(basename $0)
echo
echo "This script runs SwiftLint on the specified file and must be run in the"
echo "repository containing the file (so that the SwiftLint configuration file"
echo "for the repository is used)."
echo
echo "If the warnings flag is specified, SwiftLint warnings are displayed, if"
echo "not, only errors are displayed."
echo
echo "Usage: $program [-w|--warnings] filename"
exit 1
}

# Default to not display warnings
WARNINGS=NO

if ! hash SwiftLint 2>/dev/null; then
echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
exit 1
fi

# Get options
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
-w|--warnings)
WARNINGS=YES
;;
*)
# unknown option
;;
esac
shift # past argument or value
done

# Define repos
SCRIPTSDIR=`pwd`
GITTOPLEVEL=`git rev-parse --show-toplevel`

# Make sure the destination filename is specified
[[ $# -eq 0 ]] && show_usage
cd "$GITTOPLEVEL"
if [ ! -f "$1" ]; then
echo "File not found - $1"
#exit 1
fi

# Make sure we're in a repository
git status >/dev/null 2>&1
if [ $? -ne 0 ]; then
echo "Not in a git repository"
exit 1
fi

# Run SwiftLint
if [ ${WARNINGS} == YES ]
then
swiftlint lint --config $SCRIPTSDIR/.swiftlint.yml --path $1
else
swiftlint lint --config $SCRIPTSDIR/.swiftlint.yml --path $1 | grep -v " warning: "
fi
