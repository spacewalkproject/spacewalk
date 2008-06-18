#!/bin/bash

default_or_input () {
	unset INPUT
        read INPUT
	if [ "$INPUT" = "" ]; then
		INPUT=$1
	fi
	echo -n $INPUT
}

DIR=/usr/share/doc/proxy/conf-template
HOSTNAME=`hostname`

RHN_PARENT=`grep serverURL= /etc/sysconfig/rhn/up2date |tail -n1 | awk -F= '{print $2}' |awk -F/ '{print $3}'`
echo -n "RHN Parrent [$RHN_PARENT]:"
RHN_PARENT=`default_or_input $RHN_PARENT`

echo -n "Traceback email []:"
TRACEBACK_EMAIL=`default_or_input `

echo -n "Use SSL [0]:"
USE_SSL=`default_or_input 0`

CA_CHAIN=`grep sslCACert /etc/sysconfig/rhn/up2date |tail -n1 | awk -F= '{print $2}'`
echo -n "CA Chain [$CA_CHAIN]:"
CA_CHAIN=`default_or_input $CA_CHAIN`

echo -n "HTTP Proxy []:"
HTTP_PROXY=`default_or_input `

if [ "$HTTP_PROXY" != "" ]; then

	echo -n "HTTP username []:"
	HTTP_USERNAME=`default_or_input `

	if [ "$HTTP_USERNAME" != "" ]; then
		echo -n "HTTP password []:"
		HTTP_PASSWORD=`default_or_input `
	fi
fi

rpm -q rhns-proxy-monitoring >/dev/null
if [ $? -eq 0 ]; then
	#here we configure monitoring
	#and with cluster.ini
	echo "Monitoring conf is stil todo."
fi
ENABLE_SCOUT=0

cat $DIR/c2s.xml | sed "s/\${session.hostname\}/$HOSTNAME/g" > /etc/jabberd/c2s.xml
cat $DIR/sm.xml | sed "s/\${session.hostname\}/$HOSTNAME/g" > /etc/jabberd/sm.xml
cp $DIR/squid.conf /etc/squid/squid.conf
cat $DIR/rhn.conf | sed "s|\${session.ca_chain:/usr/share/rhn/RHNS-CA-CERT}|$CA_CHAIN|g" \
	| sed "s/\${session.http_proxy}/$HTTP_PROXY/g" \
	| sed "s/\${session.http_proxy_username}/$HTTP_USERNAME/g" \
	| sed "s/\${session.http_proxy_password}/$HTTP_PASSWORD/g" \
	| sed "s/\${session.rhn_parent}/$RHN_PARENT/g" \
	| sed "s/\${session.traceback_mail}/$TRACEBACK_EMAIL/g" \
	| sed "s/\${session.use_ssl:0}/$USE_SSL/g" \
	| sed "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
	> /etc/rhn/rhn.conf

/etc/init.d/rhn-proxy restart

#${session.rhn_monitoring_parent_ip}
#${session.rhn_monitoring_parent}
#${session.rhn_monitoring_parent_ip}
#${session.rhn_monitoring_parent}
#${session.scout_shared_key}


#${session.enable_monitoring_scout:0}
