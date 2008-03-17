#!/bin/bash
#
# Start a database that has been created by the create-db script

if [ -z "$1" ] ; then
	echo "Usage: $0 <database>"
	exit -1
else
	ORACLE_SID=$1
	export ORACLE_SID
fi

# set work environment
. $(dirname $0)/oracle-home.sh
echo

echo -n "Checking if the listener is active... "
$ORACLE_HOME/bin/lsnrctl status >/dev/null 2>&1 \
	&& echo "Listener active" \
	|| $ORACLE_HOME/bin/lsnrctl start
echo

cat <<EOF | $ORACLE_HOME/bin/sqlplus /nolog
connect / as sysdba
startup pfile=$ORACLE_INIT
EOF
