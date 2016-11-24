#!/bin/sh

if [ "$1" == "" ]; then
    echo "Usage: $0 file1.sh file2.sh file3.sh ..."
    exit 1
fi

# Iterate through all arguments
for scriptName in "$@"
do
    echo "scriptName: $scriptName"
    #/bin/sh $scriptName -pf  # Just for testing
    /bin/sh $scriptName -w
done
