#!/bin/bash
# $1 = customer id
# $2 = sat cluster id
if [ -z $1 ] ; then
	echo "ERROR: Customer ID not specified, exiting"
	exit 1
fi
if [ -z $2 ] ; then
	echo "ERROR: Satellite cluster ID not specified, exiting"
	exit 1
fi
#set up ORACLE_HOME and PATH
. /etc/profile.d/oracle.sh
export SQLSCRIPT=/usr/share/SatConfig/synch.sqplus
export CFGDB=`perl -e 'use NOCpulse::Config;$config = NOCpulse::Config->new;print $config->get("cf_db","name")'`
export LOGIN=`perl -e 'use NOCpulse::Config;$config = NOCpulse::Config->new;print $config->get("cs_db","username")."/".$config->get("cs_db","password")."@".$config->get("cs_db","name")'`

export CUST_ID=$1
export SAT_CLUSTER_ID=$2

errs=`sqlplus $LOGIN @$SQLSCRIPT $CFGDB $CUST_ID $SAT_CLUSTER_ID | egrep '(ORA-|CPY-)'`

if [ -f sqlnet.log ] ; then
	rm sqlnet.log
fi

if [ ! -z "$errs" ] ; then
	echo $errs
	exit 1
fi
