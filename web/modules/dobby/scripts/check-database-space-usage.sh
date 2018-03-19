#!/bin/bash

# Copyright (c) 2008--2018 Red Hat, Inc.
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
#

PATH=/usr/bin:/bin
export PATH

mailitout() {
   local reportusage=$1

   #get Satellite email address
   MAILADDRESS="root@localhost"
   if [ -e /usr/bin/spacewalk-cfg-get ]; then
      MAILADDRESS=$(spacewalk-cfg-get traceback_mail)
   fi

   SUBJECT="Warning - PostgreSQL database mount point is running out of space"
   BODY="This is a notice to let you know that you have gone over 90% usage of
the mount point where the PostgreSQL database resides. We recommend to be
proactive and increase the storage before getting to 100% usage."

   echo -e "$BODY\n\n$reportusage" | mail -s "$SUBJECT" $MAILADDRESS
   exit 0
}

DATADIR="/var/lib/pgsql/data/"
if rpm -q postgresql92-postgresql-server > /dev/null; then
   DATADIR="/opt/rh/postgresql92/root/var/lib/pgsql/data/"
fi

if rpm -q rh-postgresql95-postgresql > /dev/null; then
    DATADIR="/var/opt/rh/rh-postgresql95/lib/pgsql/data"
fi

if [ -f /usr/share/rhn/config-defaults/rhn_pgversion.conf ]; then
   if [ ! -z "$(grep pg_version /usr/share/rhn/config-defaults/rhn_pgversion.conf | sed 's/.*=\s*//')" ]; then
      DATADIR="$(grep pg_home /usr/share/rhn/config-defaults/rhn_pgversion.conf | sed 's/.*=\s*//')"
   fi
fi

# check if DATADIR is a directory
if [ ! -d $DATADIR ]; then
    exit 1
fi

REPORTUSAGE=$(df -hP $DATADIR)
NUMBERS=$(echo "$REPORTUSAGE" | awk '{if (FNR > 1) {sub("%",""); print $5}}')

for num in $NUMBERS
   do
   # if number is over 90% then send warning email
   if [ $num -gt 90 ]
      then mailitout "$REPORTUSAGE"
   fi
done
exit 0
