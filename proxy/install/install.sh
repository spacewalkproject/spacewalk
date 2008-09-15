#!/bin/bash
#
# Start up the RHN Proxy Server Installer

PWD=$(pwd)

# for now play it safe...
LANG=C
export LANG

if [ -n "$(which python 2>/dev/null)" ] ; then
    PYTHON="$(which python 2>/dev/null)"
else
    PYTHON=/usr/bin/python
fi

if [ ! -x $PYTHON ] ; then
    echo
    echo "ERROR: Could not find Python executable (looking for $PYTHON)"
    echo
    exit -1
fi

BaseDir=$(cd $(dirname $0) && pwd)
if [ -z "$BaseDir" ] ; then
    echo
    echo "ERROR: Could not find base directory for RHN Proxy Server install"
    echo
    exit -1
fi

echo
echo
echo "**Pre-installation**"
echo

# Now attempt to kick the updates script to prepare for installation...
if [ -d $BaseDir/updates -a -x $BaseDir/updates/update.sh ] ; then
    $BaseDir/updates/update.sh
    rc=$?
    if [ $rc -ne 0 ] ; then
	echo
	echo "ERROR: Could not apply required updates to your system."
	echo "This problem, together with the output of the failed attempt"
	echo "should be reported to Red Hat at rhn-feedback@redhat.com"
	echo
	exit -1
    fi
fi

# Now attempt to kick the "populate the www/html/pub/" script...
if [ -d $BaseDir/updates -a -x $BaseDir/updates/populate-pub.sh ] ; then
    $BaseDir/updates/populate-pub.sh
fi

if [ ! -d $BaseDir/install ] ; then
    echo
    echo "ERROR: Base installation directory '$BaseDir/install' is missing"
    echo
    exit -1
fi

cd $BaseDir/install

if [ ! -f gui.py ] ; then
    echo
    echo "ERROR: Can not find installer main program $BaseDir/install/gui.py"
    echo
    exit -1
fi

if [ -z "$DISPLAY" ] ; then
    echo
    echo "ERROR: This installer needs to be run under X Windows"
    echo "       Please make sure that the DISPLAY environment variable is set"
    echo
    exit -1
fi

echo
echo
echo "Starting up the RHN Proxy Server installer..."
echo

$PYTHON -u gui.py $@ || {
    echo "Process cancelled."
    exit -1
}

echo
echo
echo "**Post-installation**"
echo "Starting up the up2date process. Machine assumed to be registered..."
echo

echo
echo
echo "1. up2date up2date:"
echo
/usr/sbin/up2date up2date

echo
echo
echo "2. up2date -p:"
echo
/usr/sbin/up2date -p

echo
echo
echo "3. up2date rhns-proxy:"
echo
/usr/sbin/up2date rhns-proxy

echo
echo
echo "4. up2date -uf (i.e. a complete update of the system):"
echo "NOTE: this may be a lengthy process:"
echo
/usr/sbin/up2date -uf

echo
echo
echo "5. bounce the services one more time and fixing up squid"
echo
cd /
/sbin/service httpd stop
#/sbin/service rhn_auth_cache stop
/sbin/service squid stop
sleep 1
rm -rf /var/spool/squid/*
squid -z
sleep 1
/sbin/service squid start
#/sbin/service rhn_auth_cache start
/sbin/service httpd start
cd $PWD
echo
echo
echo "**** Installation process should now be complete."
echo "**** It it HIGHLY recommended that a complete reboot is performed"

