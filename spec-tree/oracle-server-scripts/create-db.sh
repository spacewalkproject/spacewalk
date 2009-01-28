#!/bin/bash
#
# Create a new database instance from command line arguments

DB_NAME=
DB_USER=
DB_PASSWORD=
FORCE=no
TOPDIR=$(dirname $0)
TEMPLATE=$TOPDIR/default-createdb.tmpl

if [ "$(whoami)" != "oracle" ] ; then
	echo "ERROR: You need to be running this script as oracle"
	exit -1
fi

Usage() {
	echo "$0 --db NAME --user USER --password PASSWORD"
	echo
	echo "Creates a new database instance"
	echo "Options:"
	echo "    --db NAME           creates a new database SID names NAME"
	echo "    --user USER         username that owns the database"
	echo "    --password PASSWORD the password for USER"
	echo
	echo "    --datadir  DIR      use specified directory for data files"
	echo "    --admindir DIR      use specified directory for admin files"
	echo "    --template TEMPLATE create db using specified template"
	echo "    --help              this usage screen"
}

# parse arguments
if [ ${#} -lt 6 ] ; then
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
	-p | --password )
		shift
		DB_PASSWORD=$1
		;;
	-f | --force )
		FORCE="yes"
		;;
	-t | --template )
	        shift
                TEMPLATE=$1
                ;;
	--datadir )
	        shift
                DataDB=$1
                ;;
	--admindir )
	        shift
                AdminDB=$1
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
	echo "ERROR: Need a database SID name to create"
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
if [ ! -e "$TEMPLATE" ] ; then
        echo "Cannot find template '$TEMPLATE'"
	exit -1
fi

echo "Attempting to create Oracle instance $DB_NAME ..."
echo "Username/Password access for this database will be $DB_USER/$DB_PASSWORD"
echo

# set work environment
. $TOPDIR/oracle-home.sh
echo

[ "$DataDB" = "" ]  && DataDB=$Oracle/data/$OracleVersionShort/$DB_NAME
[ "$AdminDB" = "" ] && AdminDB=$Oracle/admin/$OracleVersionShort/$DB_NAME


# Check that DataDB and AdminDB dirs were already created
if [ ! -d "$DataDB" ] ; then
    echo "Data file directory [$DataDB] does not exist."
    echo "Please run create-db-dirs.sh to create it."
    exit 1
fi
if [ ! -d "$AdminDB" ] ; then
    echo "Admin file directory [$AdminDB] does not exist."
    echo "Please run create-db-dirs.sh to create it."
    exit 1
fi


function CheckSetup() {
    echo -n "Checking your setup... "
    err=
    for sd in admin config data; do
        d=$Oracle/$sd/$OracleVersionShort
        if [ ! -d $d ] ; then
	    if [ -n "$err" ] ; then echo "FAILED" ; fi
	    echo -e "\t ERROR: Directory $d directory does not exist..."
	    err="$err $d"
        fi
    done
    if [ -n "$err" ] ; then exit -1 ; else echo "OK" ; fi
    echo
}

function CheckSpace() {
        template=$1
	# use m4 magic to determine how much space we will need...
	ReqFactor=$(m4 -DRHNORA_CALC_SPACE $(m4_macros $DB_NAME) $template)
	AvailSpace=$(df -P $DataDB | grep ^/dev/ | awk '{ print $4 }')
	ReqSpace=$(($ReqFactor * 1024 * 120 / 100))
	if [ $ReqSpace -gt $AvailSpace ] ; then
		echo "ERROR: Not have enough free space on $DataDB"
		echo
		df $DataDB
		echo
		echo "A new database requires at least $ReqSpace KB free"
		printf "Available: %12d KB\n" $AvailSpace
		printf "Required:  %12d KB\n\n" $ReqSpace
		exit -1
	fi
}

function CheckListener() {
    echo -n "Checking if the listener is active... "
    $ORACLE_HOME/bin/lsnrctl status >/dev/null 2>&1 \
	&& echo "Listener active" \
	|| $ORACLE_HOME/bin/lsnrctl start
    echo
}

# returns a list of the files inside $Oracle/config associated with a
# database, as well as the top level admin and data dirs for the
# database

function GetDBFiles() {
    db=$1
    if [ -z "$db" ] ; then return ; fi
    find $AdminDB $DataDB \! -type d -print
    find $Oracle/config/$OracleVersionShort -name "*$db.ora" -o -iname lk$db 2>/dev/null
}

function RemoveDB() {
    db=$1
    if [ -z "$db" ] ; then return ; fi
    echo "WARNING: Removing $db database files and configuration"
    Files=$(GetDBFiles $db)
    if [ -z "$Files" ] ; then
        echo "No database files to remove"
	echo
	return
    fi

    # remove the files associated with a database, leaving dir structure intact
    for i in $Files; do
        # Don't remove top-level directories - they may be symlinks to a
        # separate partition (test -d de-references symlinks)
	if [ -d $i ]; then
            rm -rfv $(ls -A $i)
	elif [ -f $i ]; then
	    rm -fv $i
	fi
    done

    echo "Done removing database files for $db"
    echo
}

function CheckForDB() {
    db=$1
    if [ -z "$db" ] ; then return ; fi
    echo -n "Checking if this is a new database... "
    Files=$(GetDBFiles $db)
    found=

    # Bail out if there are files in directories (empty dirs are fine)
    for i in $Files; do
	if [ -d $i ]; then
            fcount=$(ls -A $i | wc -l)
            [ $fcount -ne 0 ] && found="$found $i"
	elif [ -f $i ]; then
	    found="$found $i"
	fi
    done

    if [ -n "$found" ] ; then
	echo "FAILED"
	echo "ERROR: Database $db still has directory entries"
	for f in $found ; do echo -e "\tExisting $f will not be removed" ; done
	echo "Clean it up or change the database name..."
	exit -1
    else
	echo "OK"
    fi
    echo
}

function CreateDBConfig {
    db=$1
    if [ -z "$db" ] ; then return ; fi

    echo "Configuration file for $db is $CFile"
    cat >$CFile <<EOF
instance_name 		= $db
control_files           = ($DataDB/control_01.ctl,
			   $DataDB/control_02.ctl,
		           $DataDB/control_03.ctl)
background_dump_dest   	=  $AdminDB/bdump
core_dump_dest	       	=  $AdminDB/cdump
audit_file_dest		=  $AdminDB/logs
user_dump_dest	       	=  $AdminDB/udump
log_archive_dest      	=  $AdminDB/archive
log_archive_format	=  arch_%t_%s_%r.arc

db_domain 		= world
db_name                 = $db

ifile			=  $Oracle/admin/$OracleVersionShort/init-params.ora
EOF
}

function m4_macros() {
    db=$1
    if [ -z "$db" ] ; then return ; fi
    echo -I $Oracle/admin/$OracleVersionShort \
        --define RHNORA_ADMIN_PATH=$AdminDB \
	--define RHNORA_LOG_PATH=RHNORA_ADMIN_PATH/logs \
	--define RHNORA_DBNAME=$db \
	--define RHNORA_DATA_PATH=$DataDB \
	--define RHNORA_ORACLE_HOME=$ORACLE_HOME \
	--define RHNORA_DB_USER=$DB_USER \
	--define RHNORA_DB_PASSWORD=$DB_PASSWORD
}

function CreateDatabase() {
    template=$1
    db=$2
    if [ -z "$db" ] ; then return ; fi

    m4 $template $(m4_macros $db) | $ORACLE_HOME/bin/sqlplus /nolog \
      || exit $?
}

function OratabEntry() {
    db=$1
    if [ -z "$db" ] ; then return ; fi

    echo "Adding '$db' entry to $Oratab"
    echo "$db:$ORACLE_HOME:Y" >>$Oratab
}

#### MAIN PROGRAM
ORACLE_SID=$DB_NAME
export ORACLE_SID

CFile=$AdminDB/init.ora
Oratab=/etc/oratab

CheckSetup
CheckSpace $TEMPLATE
if [ "$FORCE" = "yes" ] ; then
    $TOPDIR/stop-db.sh $DB_NAME
    RemoveDB $DB_NAME
fi
CheckForDB $DB_NAME
CheckListener

echo "Checks passed, starting database $DB_NAME creation"

CreateDBConfig $DB_NAME

CreateDatabase $TEMPLATE $DB_NAME

OratabEntry $DB_NAME
