#!/bin/sh
#
# $Id: setNPconfig.sh,v 1.7 2002-04-25 21:16:00 dfaraldo Exp $
#

#
# envs and functions
#

PROG=`basename $0`
USAGE="Usage: $PROG [-fha] [-t type]"
SYNTAX="_$PROG: option syntax error."

syntax_error() {
echo "$SYNTAX" >&2
echo "$USAGE"  >&2
exit 1
}

arg_syntax_check() {
[ "$1" -lt 1 ] && syntax_error
}

select_type() {
  config_ext=""
  while [ -z $config_ext ] ; do
        echo -n "Select installation type (D)evelopment, (Q)A, (P)rod, (S)tage: "
        read config_type
        case $config_type in
                [Dd]*) config_ext='dev';;
                [Qq]*) config_ext='qa';;
                [Pp]*) config_ext='prod';;
                [Ss]*) config_ext='stage';;
        esac
  done
}

#
# main
#


# command line options
while [ "$#" -gt 0 ]; do
  OPT="$1"
  case "$OPT" in
	# help
	-h)
		echo ${USAGE}
		exit 0
		;;
        # force; just do it
        -f)
                FFLAG=1
                ;;
        # config type
        -t)
                shift
                arg_syntax_check "$#"
                TARG="$1"
                TFLAG=1
	        case ${TARG} in
       	         [Dd]*) config_ext='dev';;
       	         [Qq]*) config_ext='qa';;
       	         [Pp]*) config_ext='prod';;
                 [Ss]*) config_ext='stage';;
       		esac

                ;;
	# auto type
	-a)
		if [ -f /etc/NPOps.ini ] ; then
			. /etc/NPOps.ini
			echo "Auto-setting environment to $ENVX"
			config_ext=$ENVX
			TFLAG=$ENVX
			FFLAG=1
		else
			echo "Auto-set selected, but /etc/NPOps.ini does not iexist"
			exit 1
		fi
		;;
        # end of options
	--)
        	shift
		break
		;;
	# end of options, just command arguments left
	*)
		break
  esac
  shift
done

if   [ -L /etc/NOCpulse.ini ] && [ ! ${FFLAG} ] ; then
        echo -n "A config file is already pointed to! Are you SURE you want to reset it? (y/N): "
        read answer
        case $answer in
                Y|y)    echo "Clearing old configuration!";rm /etc/NOCpulse.ini;;
        esac
elif [ -L /etc/NOCpulse.ini ] && [ ${FFLAG} ] ; then
	rm /etc/NOCpulse.ini
fi

if   [ ! -L /etc/NOCpulse.ini ] && [ ! ${TFLAG} ] ; then
	select_type
        echo "Setting config to $config_ext"
        ln -s /etc/NOCpulse.ini.$config_ext /etc/NOCpulse.ini
elif [ ! -L /etc/NOCpulse.ini ] && [  ${TFLAG} ] ; then
     	echo "Setting config to ${TFLAG}"
      	ln -s /etc/NOCpulse.ini.$config_ext /etc/NOCpulse.ini
else
        echo "NOT setting config to $config_ext"
fi

