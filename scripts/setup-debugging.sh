#!/bin/bash

if [ "$1" == "--help" ]; then
    echo "Simple script for setting up remote debugging for Tomcat (port 8000) and Taskomatic (port 8001)"
    echo "Usage:"
    echo "Without parameters: setup Tomcat and Taskomatic"
    echo "--setup-tomcat -- sets up Tomcat"
    echo "--setup-taskomatic -- sets up Taskomatic"
    echo "--help -- shows this help"
    exit
fi

OK="\e[32m[[ \e[37mOK \e[32m]]\e[m"

function setup_taskomatic {
TASKOMATIC_TEMPLATE=/usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
cat $TASKOMATIC_TEMPLATE | grep "^wrapper.java.detect_debug_jvm=TRUE" > /dev/null
if [ $? -ne 0 ]; then
    echo "wrapper.java.additional.5=-Xdebug" >> $TASKOMATIC_TEMPLATE
    echo "wrapper.java.additional.6=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n" >> $TASKOMATIC_TEMPLATE
    echo "wrapper.java.detect_debug_jvm=TRUE" >> $TASKOMATIC_TEMPLATE
    echo -e "$OK Taskomatic debugging has been set successfully"
else
    echo "Taskomatic debugging seems to be already set. Skipping ..."
fi
}


function setup_tomcat {
TOMCAT_TEMPLATE=/etc/tomcat*/tomcat*.conf
TOMCAT_DEBUG_EL5='JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"'
TOMCAT_DEBUG_OTHER='CATALINA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"'
if [ -f $TOMCAT_TEMPLATE ]; then
    TOMCAT_VERSION=$(ls -d /etc/tomcat* | xargs -n1 basename)
    if [ $TOMCAT_VERSION == "tomcat5" ]; then
        #tomcat5 uses different option
        cat $TOMCAT_TEMPLATE | grep '^JAVA_OPTS=\"$JAVA_OPTS -Xdebug' > /dev/null
        if [ $? -eq 0 ]; then
            ALREADY_SET=true
        else
            TOMCAT_DEBUG=$TOMCAT_DEBUG_EL5
        fi
    else
        #tomcat6 and above
        cat $TOMCAT_TEMPLATE | grep '^CATALINA_OPTS=\"-Xdebug' > /dev/null
        if [ $? -eq 0 ]; then
            ALREADY_SET=true
        else
            TOMCAT_DEBUG=$TOMCAT_DEBUG_OTHER
        fi
    fi
    if [ "$ALREADY_SET" = true ]; then
        echo "Tomcat debugging seems to be already set. Skipping ..."
    else
        echo $TOMCAT_DEBUG >> $TOMCAT_TEMPLATE
        echo -e "$OK Tomcat remote debugging has been set successfully"
    fi
else
    echo "Tomcat configuration file not found by $TOMCAT_TEMPLATE"
fi
}

if [ "$#" == "0" ]; then
    setup_tomcat
    setup_taskomatic
else
    while [ "$#" != "0" ]; do
        if [ "$1" == "--setup-tomcat" ]; then
            setup_tomcat
        elif [ "$1" == "--setup-taskomatic" ]; then
            setup_taskomatic
        else
            echo "Unknown parameter $1"
        fi
        shift
    done
fi
