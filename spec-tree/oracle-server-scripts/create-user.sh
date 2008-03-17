#!/bin/bash
#
# Create a new user in a database instance

DB_NAME=
DB_USER=
DB_PASSWORD=

if [ "$(whoami)" != "oracle" ] ; then
	echo "ERROR: You need to be running this script as oracle"
	exit -1
fi

Usage() {
	echo "$0 --db NAME --user USER --password PASSWORD"
	echo
	echo "Creates a new user in the named databse instance"
	echo "Options:"
	echo "    --db NAME           creates a new database SID names NAME"
	echo "    --user USER         username that owns the database"
	echo "    --password PASSWORD the password for USER"
	echo
	echo "    --help              this usage screen"
}

# parse arguments
if [ $# -lt 6 ] ; then
	Usage
	exit -1
fi

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
	-p | --pass* )
		shift
		DB_PASSWORD=$1
		;;
	-h | --help )
		Usage
		exit 0
		;;
	* )
		echo "ERROR: Unknown option: $1"
		echo
		Usage
		exit -1
		;;
	esac
	shift
done

# check arguments
if [ -z "$DB_NAME" ] ; then
	echo "ERROR: Need a database SID name to address the database"
	Usage
	exit -1
fi
if [ -z "$DB_USER" ] ; then
	echo "ERROR: Need a username for database '$DB_NAME' to create"
	Usage
	exit -1
fi
if [ -z "$DB_PASSWORD" ] ; then
	echo "ERROR: Need a password for username '$DB_USER' to create"
	Usage
	exit -1
fi

echo "Creating $DB_USER/$DB_NAME user in the $DB_NAME database... "

# set work environment
. $(dirname $0)/oracle-home.sh
echo

function CheckListener() {
    echo -n "Checking if the listener is active... "
    $ORACLE_HOME/bin/lsnrctl status >/dev/null 2>&1 \
	&& echo "Listener active" \
	|| $ORACLE_HOME/bin/lsnrctl start
    echo
}

function GetDBFiles() {
    db=$1
    if [ -z "$db" ] ; then return ; fi
    for d in $Oracle/admin/$db $Oracle/data/$db ; do
        if [ -d $d ] ; then echo $d ; fi
    done
    find $Oracle/config -name "*$db.ora" -o -iname lk$db 2>/dev/null
}

function CheckForDB() {
    db=$1
    if [ -z "$db" ] ; then return ; fi
    echo -n "Checking if this database exists... "
    Files=$(GetDBFiles $db)
    if [ -z "$Files" ] ; then
	echo "FAILED"
	echo "ERROR: Database $db does not seem to be set up properly"
	exit -1
    else
	echo "OK"
    fi
    echo
}

function CreateUser() {
cat <<EOF | $ORACLE_HOME/bin/sqlplus /nolog
set echo on
set pagesize 10000
set serveroutput on
whenever sqlerror exit failure
spool $AdminDB/logs/user_${DB_USER}.log

connect / as sysdba

select sysdate from dual;

create user $DB_USER identified by $DB_PASSWORD
        default tablespace users
	temporary tablespace temp_tbs
	quota unlimited on temp_tbs;

grant connect to $DB_USER;

alter user $DB_USER
	default tablespace data_tbs
	quota unlimited on data_tbs;

grant create table to $DB_USER;
grant create view to $DB_USER;
grant create type to $DB_USER;
grant create sequence to $DB_USER;
grant create procedure to $DB_USER;
grant create operator to $DB_USER;
grant create synonym to $DB_USER;
grant create trigger to $DB_USER;
grant create role to $DB_USER;

connect $DB_USER/$DB_PASSWORD

set echo off
select 'rdbms/admin/utlxplan.sql' script from dual;
@$ORACLE_HOME/rdbms/admin/utlxplan.sql
set echo on

disconnect
EOF
}

#### MAIN PROGRAM
CheckListener
CheckForDB $DB_NAME

echo "Checks passed, starting user $DB_USER creation in $DB_NAME"
ORACLE_SID=$DB_NAME
export ORACLE_SID

AdminDB=$Oracle/admin/$DB_NAME
CreateUser
