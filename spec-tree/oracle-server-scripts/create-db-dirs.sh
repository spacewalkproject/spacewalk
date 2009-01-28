#!/bin/bash
#
# Create directory structure from command line arguments

TOPDIR=$(dirname $0)

if [ "$(whoami)" != "root" ] ; then
	echo "ERROR: You need to be running this script as root"
	exit -1
fi

Usage() {
	echo "$0 --datadir DATADIR --admindir ADMINDIR"
	echo
	echo "Creates directory structure for new database instance"
	echo "Options:"
	echo "    --datadir  DIR      use specified directory for data files"
	echo "    --admindir DIR      use specified directory for admin files"
	echo "    --help              this usage screen"
}

# parse arguments
if [ ${#} -lt 4 ] ; then
	Usage
	exit -1
fi

while [ -n "$1" ] ; do
	case $1 in
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

[ "$DataDB" = "" ]  && {
    echo "Parameter --datadir was not specified."
    exit 1
}
[ "$AdminDB" = "" ] && {
    echo "Parameter --admindir was not specified."
    exit 1
}


# mkdir -p returns 1 if the dir exists, whether it made it or not.
# convenient.
mkdir -p $DataDB &> /dev/null || {
    echo "Unable to create data directory $DataDB.  Please create and ensure"
    echo "it can be read and written to by oracle:dba."
    exit 1
}

mkdir -p $AdminDB &> /dev/null || {
    echo "Unable to create admin directory $AdminDB.  Please create and ensure"
    echo "it can be read and written to by oracle:dba."
    exit 1
}

# Create the admin tree
echo "Creating: log dumping directories for various subsystems..."
install -d -m 755 --verbose $AdminDB/adump
install -d -m 755 --verbose $AdminDB/bdump
install -d -m 755 --verbose $AdminDB/cdump
install -d -m 755 --verbose $AdminDB/udump
install -d -m 755 --verbose $AdminDB/ldump

echo "Creating: administrative and management directories"
install -d -m 755 --verbose $AdminDB/archive
install -d -m 755 --verbose $AdminDB/backup
install -d -m 755 --verbose $AdminDB/logs
install -d -m 755 --verbose $AdminDB/import
install -d -m 755 --verbose $AdminDB/export
install -d -m 755 --verbose $AdminDB/perf
install -d -m 755 --verbose $AdminDB/tmp

echo "Creating: Database storage directory"
install -d -m 755 --verbose $DataDB

chown -R oracle:oracle $AdminDB $DataDB
restorecon -ri $AdminDB $DataDB
