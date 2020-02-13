#!/bin/bash
function help {
    echo "Simple script for setting up remote debugging for Tomcat (port 8000) and Taskomatic (port 8001)"
    echo "Usage:"
    echo "-u -- Username"
    echo "-s -- Server"
    echo "-h -- shows this help"
    exit
}

function setup_taskomatic {
OK="\e[32m[[ \e[37mOK \e[32m]]\e[m"
TASKOMATIC_TEMPLATE=/usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf
ADDON_NUMBER=$(cat /usr/share/rhn/config-defaults/rhn_taskomatic_daemon.conf | grep -oP '^wrapper.java.additional.\K[0-9]+(?==)' | sort -n | tail -n 1)
let ADDON_NUMBER++
cat $TASKOMATIC_TEMPLATE | grep "^wrapper.java.detect_debug_jvm=TRUE" > /dev/null
if [ $? -ne 0 ]; then
    echo "wrapper.java.additional.$ADDON_NUMBER=-Xdebug" >> $TASKOMATIC_TEMPLATE
    let ADDON_NUMBER++
    echo "wrapper.java.additional.$ADDON_NUMBER=-Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n" >> $TASKOMATIC_TEMPLATE
    echo "wrapper.java.detect_debug_jvm=TRUE" >> $TASKOMATIC_TEMPLATE
    echo -e "$OK Taskomatic debugging has been set successfully on port 8001"
else
    echo "Taskomatic debugging seems to be already set. Skipping ..."
fi
}


function setup_tomcat {
OK="\e[32m[[ \e[37mOK \e[32m]]\e[m"
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
        echo -e "$OK Tomcat remote debugging has been set successfully on port 8000"
    fi
else
    echo "Tomcat configuration file not found by $TOMCAT_TEMPLATE"
fi
}

while getopts "h?u:s:" opt; do
    case "$opt" in
    h|\?)
        help
        ;;
    u)  USER_REMOTE=$OPTARG
        ;;
    s)  SERVER=$OPTARG
        ;;
    esac
done
if [ -z "$USER_REMOTE" ] || [ -z "$SERVER" ]; then
      help
else
      ssh $USER_REMOTE@$SERVER "$(typeset -f); setup_tomcat;setup_taskomatic";
fi
