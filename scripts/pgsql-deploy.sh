#!/bin/sh
#
# Deploys required modified files in the pgsql git branch to live locations on the system. 
# Must be run from root of your git checkout. 
# i.e.
#    cd ~/src/spacewalk
#    SWHOST=root@192.168.1.45 scripts/pgsql-deploy.sh (el5|f10)
#
# Be careful! This script is *NOT* meant for production environments.

echo "Deploying pgsql modifications..."
echo ""

if [ $# -eq 0 ]
then
    echo "USAGE: SWHOST=root@localhost scripts/pgsql-deploy (el5|f10)"
    exit 1
fi

case $1 in
    "el5") 
        echo "EL5";;
    "f10") 
        echo "F10";;
    *) 
        echo "Unknown arch: $1"
        exit 1;;
esac


if [ $1 = "f10" ]
then
    scp ./spacewalk/setup/lib/Spacewalk/Setup.pm $SWHOST:/usr/lib/perl5/vendor_perl/5.10.0/Spacewalk/Setup.pm
    scp -r ./web/modules/rhn/RHN/ $SWHOST:/usr/lib/perl5/vendor_perl/5.10.0/
    scp -r ./web/modules/pxt/PXT/ $SWHOST:/usr/lib/perl5/vendor_perl/5.10.0/
fi

if [ $1 = "el5" ]
then
    scp ./spacewalk/setup/lib/Spacewalk/Setup.pm $SWHOST:/usr/lib/perl5/vendor_perl/5.8.8/Spacewalk/Setup.pm
    scp -r ./web/modules/rhn/RHN/ $SWHOST:/usr/lib/perl5/site_perl/5.8.8/
    scp -r ./web/modules/pxt/PXT/ $SWHOST:/usr/lib/perl5/site_perl/5.8.8/
fi

scp ./spacewalk/setup/bin/spacewalk-setup $SWHOST:/usr/bin/spacewalk-setup

scp -r ./backend/server $SWHOST:/usr/share/rhn/
scp -r ./backend/satellite_tools $SWHOST:/usr/share/rhn/

scp ./spacewalk/admin/rhn-populate-database.pl $SWHOST:/usr/bin/rhn-populate-database.pl

scp ./spacewalk/config/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf $SWHOST:/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf
scp ./web/conf/rhn_web.conf $SWHOST:/etc/rhn/default/rhn_web.conf

echo ""
echo "PostgreSQL modifications deployed."
echo "To undo these changes remove and re-install the following packages:"
echo "    rpm -e --nodeps spacewalk-setup spacewalk-admin spacewalk-backend-sql spacewalk-backend-tools spacewalk-config"
echo "    yum install spacewalk-setup spacewalk-admin spacewalk-backend-sql spacewalk-backend-tools spacewalk-config"
