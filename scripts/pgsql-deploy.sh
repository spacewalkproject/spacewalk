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
scp ./spacewalk/setup/lib/Spacewalk/Setup.pm $SW_USER_HOST:/usr/lib/perl5/vendor_perl/5.8.8/Spacewalk/Setup.pm
scp ./spacewalk/setup/bin/spacewalk-setup $SW_USER_HOST:/usr/bin/spacewalk-setup

scp ./schema/spacewalk/postgresql/postgresql.universe.satellite.sql $SW_USER_HOST:/etc/sysconfig/rhn/postgresql.universe.satellite.sql

scp -r ./backend/server/rhnSQL $SW_USER_HOST:/usr/share/rhn/server/
scp -r ./backend/satellite_tools $SW_USER_HOST:/usr/share/rhn/

scp ./spacewalk/admin/rhn-populate-database.pl $SW_USER_HOST:/usr/bin/rhn-populate-database.pl

scp ./spacewalk/config/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf $SW_USER_HOST:/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf

echo ""
echo "To undo these changes remove and re-install the following packages:"
echo "    rpm -e --nodeps spacewalk-setup spacewalk-admin spacewalk-backend-sql spacewalk-backend-tools spacewalk-config"
echo "    yum install spacewalk-setup spacewalk-admin spacewalk-backend-sql spacewalk-backend-tools spacewalk-config"
