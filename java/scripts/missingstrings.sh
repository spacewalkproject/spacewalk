#!/bin/bash

CWD=`pwd`
LIST=`ls ../code/src/com/redhat/rhn/frontend/strings/`
for j in $LIST ; do
cd ../code/src/com/redhat/rhn/frontend/strings/$j
echo -e "$j\n==============================================="
$CWD/findmissingstrings.py
cd $CWD
done
