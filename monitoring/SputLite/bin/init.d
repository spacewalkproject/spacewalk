#!/bin/sh
#
# Startup script for the NOCpulse Command Queue execution agent
#
# chkconfig: 345 85 15
# description: NOCpulse Command Queue execution agent
# processname: execute_commands


# Source function library.
. /etc/rc.d/init.d/functions

daemon_user=root

# See how we were called.
case "$1" in
  start)
	echo -n "Starting execution agent: "
	/opt/home/nocpulse/bin/gogo.pl --user $daemon_user --hbfile /opt/home/nocpulse/var/commands/heartbeat --hbfreq=120 /opt/home/nocpulse/bin/execute_commands &
	echo_success
	echo
	;;
  stop)
  	/opt/home/nocpulse/bin/gogo.pl --kill execute_commands
	;;
  status)
	/opt/home/nocpulse/bin/gogo.pl --check execute_commands
	exit $?
	;;
  restart)
	$0 stop
	$0 start
	;;
  *)
	echo "Usage: $0 {start|stop|restart|status}"
	exit 1
esac

exit 0
