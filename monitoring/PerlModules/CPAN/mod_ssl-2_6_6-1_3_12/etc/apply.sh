#!/bin/sh
##
##  apply.sh -- Apply a patch
##  Copyright (c) 1998-2000 Ralf S. Engelschall, All Rights Reserved. 
##

#   parameters
cookiestr="$1"
cookiefile="$2"
patchprg="$3"
patchfile="$4"
applydir="$5"
prefix="$6"
display="$7"

if [ ".`grep $cookiestr $cookiefile`" = . ]; then
    cat $patchfile |\
    $patchprg --forward --directory $applydir 2>&1 |\
    tee config.log |\
    egrep '^.Index:' | sed -e "s/.*Index: /$prefix patching: [FILE] /" |\
    eval $display
    failed=0
    if [ ".`grep $cookiestr $cookiefile`" = . ]; then
        failed=1
    fi
    if [ ".`cd $applydir; find . -name '*.rej' -print`" != . ]; then
        failed=1
    fi
    if [ ".$failed" = .1 ]; then
        echo "Error: Application of patch failed:" 1>&2
        echo "-------------------------------------------------" 1>&2
        tail config.log 1>&2
        echo "-------------------------------------------------" 1>&2
        exit 1
    else
        rm -f config.log
    fi
else
    cat $patchfile |\
    egrep '^Index:' | sed -e "s/.*Index: /$prefix skipping: [FILE] /" |\
    eval $display
fi

