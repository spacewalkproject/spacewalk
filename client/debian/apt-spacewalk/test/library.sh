#!/bin/bash

# Workaround the bug 700525
touch /etc/redhat-release

. /usr/share/beakerlib/beakerlib.sh

function rlAssertDpkg(){
    local package=$1;
    dpkg -l $package > /dev/null
    __INTERNAL_ConditionalAssert "Checking for the presence of $package deb" $?;
}

function rlGetArch(){
    local arch=`uname -i`
    # Overrife architecture name to be compliant with debian packages
    case ${arch} in
        i486|i566|i686)
          arch=i386
          ;;
        x86_64)
         arch=amd64
         ;;
    esac
    echo $arch
}
