#!/bin/bash

# Copyright (c) 2008--2013 Red Hat, Inc.
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

reportusage() {
   # both command produce percent as 5th field and first row is header, which is ignored
   if [ 0$(spacewalk-cfg-get db_backend) = "0postgresql" ]; then
      df -hP /var/lib/pgsql/data/
   else
      # don't report UNDO usage
       /sbin/runuser oracle -c "db-control report" | grep -E -v 'UNDO|TEMP'
   fi
}

mailitout() {
   local reportusage=$1

   #get Satellite email address
   MAILADDRESS=$(spacewalk-cfg-get traceback_mail)

   if [ 0$(spacewalk-cfg-get db_backend) = "0postgresql" ]; then
      SUBJECT="Warning - PostgreSQL database mount point is running out of space"
      BODY="This is a notice to let you know that you have gone over 90% usage of
the mount point where the PostgreSQL database resides. We recommend to be
proactive and increase the storage before getting to 100% usage."
   else
      SUBJECT="Warning - high tablespace usage on Satellite oracle DB"

      BODY="This is a notice to let you know that you have gone over 90% usage in
one of the Oracle Tablespaces. We recommend to be proactive and increase the
size of the tablespace  before getting to 100% usage. Please consult
the Satellite documentation on using db-control to increase the size or
contact Red Hat Support for assistance."
   fi

   echo -e "$BODY\n\n$reportusage" | mail -s "$SUBJECT" $MAILADDRESS
   exit 0
}
#grab the usage numbers from the db-control report output
REPORTUSAGE=$(reportusage)
NUMBERS=$(echo "$REPORTUSAGE" | awk '{if (FNR > 1) {sub("%",""); print $5}}')
# run db-control and then use awk and sed to get the % numbers
for num in $NUMBERS
   do
   # if number is over 90% then send warning email
   if [ $num -gt 90 ]
      then mailitout "$REPORTUSAGE"
   fi
done
exit 0
