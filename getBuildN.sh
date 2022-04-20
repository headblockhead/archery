#!/bin/bash
export BUILD="$(curl https://increment.build/`cat sec_buildID`)"
re='^[0-9]+$'
    if ! [[ $BUILD =~ $re ]] ; then
    echo "error: Not a number" >&2; exit 1
else
echo "$BUILD"
fi