#!/bin/sh
#
# Deploys required modified files in the pgsql git branch to live locations on the system. 
# Must be run from root of your git checkout. 
# i.e.
#    cd ~/src/spacewalk
#    scripts/pgsql-deploy.sh
#
# Be careful!

echo "Deploying pgsql modifications..."
echo ""

# Watchout for the vendor_perl dir here, this is ok for RHEL 5 and thus probably CentOS 5, 
# but this is beyond fragile:
scp ./spacewalk/setup/lib/Spacewalk/Setup.pm $SWHOST:/usr/lib/perl5/vendor_perl/5.8.8/Spacewalk/Setup.pm
scp ./spacewalk/setup/bin/spacewalk-setup $SWHOST:/usr/bin/spacewalk-setup

ssh $SWHOST mkdir /usr/share/spacewalk/schema/
scp -r ./schema/spacewalk/postgresql/ $SWHOST:/usr/share/spacewalk/schema/

scp -r ./backend/server $SWHOST:/usr/share/rhn/
scp -r ./backend/satellite_tools $SWHOST:/usr/share/rhn/

scp ./spacewalk/admin/rhn-populate-database.pl $SWHOST:/usr/bin/rhn-populate-database.pl

scp ./spacewalk/config/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf $SWHOST:/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf

echo ""
echo "To undo these changes remove and re-install the following packages:"
echo "    rpm -e --nodeps spacewalk-setup spacewalk-admin spacewalk-backend-sql spacewalk-backend-tools spacewalk-config"
echo "    yum install spacewalk-setup spacewalk-admin spacewalk-backend-sql spacewalk-backend-tools spacewalk-config"
