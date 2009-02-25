#!/bin/sh
# Installs/creates the RHN embedded database at mountpoint /rhnsat
#
# Copyright (c) 2002-2004, Red Hat, Inc.
# All rights reserved.
#
# $Id: inst-rhnsat-db.sh,v 1.14 2008-03-17 10:54:36 mmraka Exp $

set -x

# exit if anything fails
set -e


# set oracle environment to embedded server
ORAENV_ASK=NO
ORACLE_SID=embedded
ORACLE_BASE=/opt/apps/oracle
. oraenv

ORACLE_9I_HOME=$(echo $ORACLE_HOME | sed 's|10\.2\.0/db_1|9.2.0|')
ORACLE_ADMIN_DIR=$ORACLE_BASE/admin/10.2.0
ORACLE_ADMIN_9I_DIR=$ORACLE_BASE/admin/9.2.0
ORACLE_CONFIG_DIR=$ORACLE_BASE/config/10.2.0
ORACLE_CONFIG_9I_DIR=$ORACLE_BASE/config/9.2.0


# add rhnsat entry to oratab
echo "rhnsat:$ORACLE_HOME:Y" >>/etc/oratab

# change env to rhnsat instance
ORACLE_SID=rhnsat
export ORACLE_SID
. oraenv


# modify listener
LISTENER_ORA=network/admin/listener.ora
sed "s|\(ORACLE_HOME=.*\)|(ORACLE_HOME=$ORACLE_HOME)|" \
    $ORACLE_9I_HOME/$LISTENER_ORA >$ORACLE_HOME/$LISTENER_ORA


# modify db init files
cp -a $ORACLE_CONFIG_9I_DIR/* $ORACLE_CONFIG_DIR/
UPGRADE_PFILE=$ORACLE_CONFIG_DIR/upgrade-init$ORACLE_SID.ora
cat $ORACLE_ADMIN_DIR/init-params.ora  >$UPGRADE_PFILE
grep --text -E -f - $ORACLE_CONFIG_9I_DIR/spfile$ORACLE_SID.ora \
    >>$UPGRADE_PFILE <<EOPATTERNS
audit_file_dest
background_dump_dest
control_files
core_dump_dest
db_domain
db_name
instance_name
log_archive_dest
log_archive_format
user_dump_dest
EOPATTERNS
echo "compatible=9.2.0.4.0" >>$UPGRADE_PFILE


# upgrade database
UPGRADE_TMPL=$ORACLE_ADMIN_DIR/embedded-upgradedb.tmpl
m4 $UPGRADE_TMPL -I$ORACLE_ADMIN_DIR \
   --define RHNORA_DBNAME=$ORACLE_SID \
   --define RHNORA_LOG_PATH=/rhnsat/admin/rhnsat/logs \
   --define RHNORA_DATA_PATH=/rhnsat/data/rhnsat \
   --define RHNORA_DB_USER=rhnsat \
   | $ORACLE_HOME/bin/sqlplus /nolog

set +x

