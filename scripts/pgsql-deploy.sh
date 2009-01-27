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
cp -v ./spacewalk/setup/lib/Spacewalk/Setup.pm /usr/lib/perl5/vendor_perl/5.8.8/Spacewalk/Setup.pm
cp -v ./spacewalk/setup/bin/spacewalk-setup /usr/bin/spacewalk-setup

cp -v ./schema/spacewalk/postgresql/postgresql.universe.satellite.sql /etc/sysconfig/rhn/postgresql.universe.satellite.sql

cp -R -v ./backend/server/rhnSQL /usr/share/rhn/server/

cp -v ./spacewalk/admin/rhn-populate-database.pl /usr/bin/rhn-populate-database.pl

echo ""
echo "To undo these changes remove and re-install the following packages:"
echo "    rpm -e --nodeps spacewalk-setup spacewalk-admin spacewalk-backend-sql"
echo "    yum install spacewalk-setup spacewalk-admin spacewalk-backend-sql"
