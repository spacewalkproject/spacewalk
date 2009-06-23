#!/bin/sh
# Upgrades RHN embedded database at mountpoint /rhnsat (10g ver 10.2.0.3 -> 10g ver. 10.2.0.4)
#
# Copyright (c) 2009 Red Hat, Inc.
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

# exit if anything fails
set -e

DB_NAME="rhnsat"
DB_USER="rhnsat"

if [ ${#} -gt 0 ]; then
   while [ -n "$1" ] ; do
       case $1 in
       -d | --db | --database )
           shift
           DB_NAME=$1
           ;;
       -u | --user* )
           shift
           DB_USER=$1
           ;;
       * )
           exit -1
           ;;
       esac
       shift
   done
fi

# set oracle environment to embedded server
ORAENV_ASK=NO
ORACLE_BASE=/opt/apps/oracle
ORACLE_ADMIN_DIR=$ORACLE_BASE/admin/10.2.0
ORACLE_CONFIG_DIR=$ORACLE_BASE/config/10.2.0

# change env to rhnsat instance
export ORACLE_SID=$DB_NAME
. oraenv

# If the record for satellite database exists, substitute it with new value.
# Otherwise create a new record.
if grep -q "^$ORACLE_SID:.*$" /etc/oratab; then
	sed -i "s;^$ORACLE_SID:.*$;$ORACLE_SID:$ORACLE_HOME:Y;" /etc/oratab
else
	echo "$ORACLE_SID:$ORACLE_HOME:Y" >> /etc/oratab
fi

# upgrade database
UPGRADE_TMPL=$ORACLE_ADMIN_DIR/embedded-upgradedb-10g.tmpl
m4 $UPGRADE_TMPL -I$ORACLE_ADMIN_DIR \
   --define RHNORA_DBNAME=$ORACLE_SID \
   --define RHNORA_LOG_PATH=/rhnsat/admin/rhnsat/logs \
   --define RHNORA_DATA_PATH=/rhnsat/data/rhnsat \
   --define RHNORA_DB_USER=$DB_USER \
   | $ORACLE_HOME/bin/sqlplus /nolog

set +x
