#!/bin/bash

ORATAB=/etc/oratab

if [ -r "$ORATAB" ] ; then
    ORACLE_HOME=`awk -F: '/^\*:/ {print $2}' $ORATAB`
fi

if [ -d "$ORACLE_HOME" ] ; then
    export ORACLE_HOME

    PATH=$ORACLE_HOME/bin:$PATH
    export PATH
fi

