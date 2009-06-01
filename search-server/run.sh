#!/bin/bash
rpm -q tanukiwrapper > /dev/null
RETURN_VAL=$?
if [ ! "$RETURN_VAL" -eq "0" ]; then
    echo "Please install tanukiwrapper: up2date tanukiwrapper or yum install tanukiwrapper"
    exit 1;
fi

if [ ! -r "/etc/rhn/search/rhn_search.conf" ]; then
    echo "you need to symlink rhn_search.conf as /etc/rhn/search/rhn_search.conf"
    exit 2;
fi

echo "starting server"
export CLASSPATH=`pwd`/build
#java -Djava.library.path=/usr/lib -classpath `build-classpath-directory lib dist` com.redhat.satellite.search.Main
/usr/sbin/tanukiwrapper `pwd`/rhn_search_daemon_dev.conf wrapper.pidfile=`pwd`/rhn-search.pid wrapper.daemonize=FALSE
