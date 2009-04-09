#!/bin/sh
#
# Installs/creates the RHN embedded database at mountpoint /rhnsat
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

# exit if anything fails
set -e

DB_NAME="rhnsat"
DB_USER="rhnsat"
DB_PASSWORD="rhnsat"

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
       -p | --password )
           shift
           DB_PASSWORD=$1
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
ORACLE_SID=embedded
export ORAENV_ASK ORACLE_SID
. oraenv

mkdir -p /rhnsat/data /rhnsat/admin
chown -R oracle:dba /rhnsat
if selinuxenabled && semodule -l | grep '^oracle-rhnsat\b' ; then
	restorecon -rv /rhnsat
	RUNRESTORECON=--run-restorecon
fi

ORACLE_ADMIN_DIR=/opt/apps/oracle/admin/10.2.0
export ORACLE_ADMIN_DIR

/sbin/runuser - oracle -c "$ORACLE_ADMIN_DIR/create-db.sh --db $DB_NAME --user $DB_USER --password $DB_PASSWORD --datadir /rhnsat/data/rhnsat --admindir /rhnsat/admin/rhnsat --template $ORACLE_ADMIN_DIR/embedded-createdb.tmpl $RUNRESTORECON"

LISTFILE=$ORACLE_HOME/network/admin/listener.ora

cat > $LISTFILE <<EOF
LISTENER=
  (DESCRIPTION=
    (ADDRESS_LIST=
      (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))
      ))
SID_LIST_LISTENER=
  (SID_LIST=
    (SID_DESC=
      (GLOBAL_DBNAME=$DB_NAME.world)
      (ORACLE_HOME=$ORACLE_HOME)
      (SID_NAME=$DB_NAME))
  )
EOF

chown oracle:dba $LISTFILE

# add the service
chkconfig --add oracle

service oracle restart

set +x

