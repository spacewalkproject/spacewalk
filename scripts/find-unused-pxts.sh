#!/bin/bash

#GREP_TMPL="grep -rnl FILE ."
GREP_TMPL="git grep FILE"

echo "=== Looking for unused pxt files ==="
PXTS=`find -name \*.pxt | rev | cut --delim='/' -f-2 | rev`
for PXT in $PXTS; do
    pushd ../ > /dev/null
    output=`${GREP_TMPL//FILE/$PXT}`
    if ! [ -n "$output" ]; then
        echo $PXT
    fi;
    popd > /dev/null
done;

echo "=== Looking for unused pxi files ==="
PXIS=`find -name \*.pxi | rev | cut --delim='/' -f-2 | rev`
for PXI in $PXIS; do
    pushd ../ > /dev/null
    output=`${GREP_TMPL//FILE/$PXI}`
    if ! [ -n "$output" ]; then
        echo $PXI
    fi;
    popd > /dev/null
done;
