#!/bin/bash

if [ 0$UID -gt 0 ]; then
	echo Run as root.
	exit 1
fi
 
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
echo -n "RHN Parent [$RHN_PARENT]: "
RHN_PARENT=`default_or_input $RHN_PARENT`

echo -n "Traceback email []: "
TRACEBACK_EMAIL=`default_or_input `

echo -n "Use SSL [0]: "
USE_SSL=`default_or_input 0`

CA_CHAIN=`grep sslCACert /etc/sysconfig/rhn/up2date |tail -n1 | awk -F= '{print $2}'`
echo -n "CA Chain [$CA_CHAIN]: "
CA_CHAIN=`default_or_input $CA_CHAIN`

echo -n "HTTP Proxy []: "
HTTP_PROXY=`default_or_input `

echo SSL Certificate:
echo -n "Common name: "
COMMON_NAME=`default_or_input `

echo -n "Country (two letters code): "
COUNTRY=`default_or_input `

echo -n "City: "
CITY=`default_or_input `

echo -n "State: "
STATE=`default_or_input `

echo -n "Organization: "
ORG=`default_or_input `

echo -n "Organization unit: "
ORG_UNIT=`default_or_input `



if [ "$HTTP_PROXY" != "" ]; then

	echo -n "HTTP username []:"
	HTTP_USERNAME=`default_or_input `

	if [ "$HTTP_USERNAME" != "" ]; then
		echo -n "HTTP password []:"
        	HTTP_PASSWORD=`default_or_input `
	fi
fi

rpm -q rhns-proxy-monitoring >/dev/null
MONITORING=$?
if [ $MONITORING -ne 0 ]; then
        echo "You do not have monitoring installed. Do you want to install it?"

        YUM_OR_UPDATE="up2date -i"
	if [ -f /usr/bin/yum ]; then
                YUM_OR_UPDATE="yum install"
        fi

	echo -n "Will run '$YUM_OR_UPDATE rhns-proxy-monitoring'.  [Y/n]:"
	INSTALL_MONITORING=`default_or_input Y | tr y Y`
	if [ "$INSTALL_MONITORING" = "Y" ]; then
	        $YUM_OR_UPDATE rhns-proxy-monitoring
	        MONITORING=$?
	fi
fi
ENABLE_SCOUT=0
if [ $MONITORING -eq 0 ]; then
	#here we configure monitoring
	#and with cluster.ini
	echo "Configuring monitoring."
        echo -n "Monitoring parent [$RHN_PARENT]:"
        MONITORING_PARENT=`default_or_input $RHN_PARENT`
        RESOLVED_IP=`/usr/bin/getent hosts $RHN_PARENT | cut -f1 -d' '`
        echo -n "Monitoring parent IP [$RESOLVED_IP]:"
        MONITORING_PARENT_IP=`default_or_input $RESOLVED_IP`
        echo -n "Enable monitoring scout [y/N]:"
        ENABLE_SCOUT=`default_or_input N | tr nNyY 0011`
        echo "Your scout shared key (can be find on parent"
        echo -n "in /etc/rhn/cluster.ini as key scoutsharedkey): "
        SCOUT_SHARED_KEY=`default_or_input `
fi

echo Creating config files.
# size of squid disk cache will be 60% of free space on /var/spool/squid
SQUID_SIZE=$(( `df -P /var/spool/squid |tail -n1 | awk '{print $4 }'` / 100 * 6 ))

cat $DIR/c2s.xml | sed "s/\${session.hostname\}/$HOSTNAME/g" > /etc/jabberd/c2s.xml
cat $DIR/sm.xml | sed "s/\${session.hostname\}/$HOSTNAME/g" > /etc/jabberd/sm.xml
cat $DIR/squid.conf | sed "s|cache_dir ufs /var/spool/squid 15000 16 256|cache_dir ufs /var/spool/squid $SQUID_SIZE 16 256|g" \
        > /etc/squid/squid.conf
cat $DIR/rhn.conf | sed "s|\${session.ca_chain:/usr/share/rhn/RHNS-CA-CERT}|$CA_CHAIN|g" \
	| sed "s/\${session.http_proxy}/$HTTP_PROXY/g" \
	| sed "s/\${session.http_proxy_username}/$HTTP_USERNAME/g" \
	| sed "s/\${session.http_proxy_password}/$HTTP_PASSWORD/g" \
	| sed "s/\${session.rhn_parent}/$RHN_PARENT/g" \
	| sed "s/\${session.traceback_mail}/$TRACEBACK_EMAIL/g" \
	| sed "s/\${session.use_ssl:0}/$USE_SSL/g" \
	| sed "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
	> /etc/rhn/rhn.conf
cat $DIR/cluster.ini | sed "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
        | sed "s/\${session.rhn_monitoring_parent_ip}/$MONITORING_PARENT_IP/g" \
        | sed "s/\${session.rhn_monitoring_parent}/$MONITORING_PARENT/g" \
        | sed "s/\${session.scout_shared_key}/$SCOUT_SHARED_KEY/g" \
        > /etc/rhn/cluster.ini

echo Creating CA certificate
cd /root
rhn-ssl-tool --gen-ca --dir=/root/ssl-build --set-common-name=$COMMON_NAME \
	--set-country=$COUNTRY --set-city=$CITY --set-state=$STATE \
	--set-org=$ORG --set-org-unit=$ORG_UNIT --set-email=$TRACEBACK_EMAIL

echo Creating SSL certificate
rhn-ssl-tool --gen-server --dir=/root/ssl-build \
	--set-hostname $HOSTNAME --set-country=$COUNTRY \
	--set-city=$CITY --set-state=$STATE  --set-org=$ORG \
	--set-org-unit=$ORG_UNIT --set-email=$TRACEBACK_EMAIL

rpm -Uv --replacepkgs /root/ssl-build/`grep noarch.rpm  /root/ssl-build/latest.txt`
cp /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT /var/www/html/pub/

echo Creating PEM for jabberd
UTF8=$(shell locale -c LC_CTYPE -k | grep -q charmap.*UTF-8 && echo -utf8)
PEM1=`/bin/mktemp /tmp/openssl.XXXXXX`
PEM2=`/bin/mktemp /tmp/openssl.XXXXXX`
/usr/bin/openssl req $UTF8 -newkey rsa:1024 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2 -set_serial 0 
cat $PEM1 >  /etc/jabberd/server.pem  
echo ""    >> /etc/jabberd/server.pem
cat $PEM2 >> /etc/jabberd/server.pem
rm -f $PEM1 $PEM2

/etc/init.d/rhn-proxy restart


