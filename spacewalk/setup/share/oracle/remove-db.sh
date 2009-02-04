#!/bin/sh
#
# simply stop the oracle instance, nuke all the data associated with it,
# and then remove the daemon
#
# WARNING: mere mortals should not use this script!
#
# usage: /bin/bash remove-db.sh
#
#
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.


set -x

# shut down the instance; stop the listener
/sbin/service oracle stop

# wipeout the data directories
rm -rfv /rhnsat
find ~oracle/config/ -type f | grep -i rhnsat | xargs rm -rfv

# remove the service
/sbin/chkconfig --del oracle

# let's get violent! Kill all oracle processes!
/sbin/runuser - oracle -c 'kill -9 -1'
sleep 1

# removing any remaining Semaphore Arrays (see ipcs -s)
ipcs -s | perl -l -a -n -e 'print $F[1] if $F[2] =~ /oracle/ and $F[1] =~ /^[0-9]/ ' | xargs  -n 1 -r ipcrm -s

# removing any remaining Shared Memory Segments (see ipcs -m)
ipcs -m | perl -l -a -n -e 'print $F[1] if $F[2] =~ /oracle/ and $F[1] =~ /^[0-9]/' | xargs -n 1 -r ipcrm -m

set +x

echo
echo "WARNING: you may want to double check that shared memory and semaphore"
echo "         resources are cleared out for oracle via the ipcs and ipcrm"
echo "         commands"

