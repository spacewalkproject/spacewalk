#!/bin/bash

if [ 0$UID -gt 0 ]; then
       echo Run as root.
       exit 1
fi

default_or_input () {
	unset INPUT
        read INPUT
	if [ "$INPUT" = "" ]; then
		INPUT="$1"
	fi
	echo -n $INPUT 
}

config_error () {
        if [ $1 -gt 0 ]; then
                echo "$2 Configuration interrupted."
                exit 1
        fi
}

#do we have yum or up2date?
YUM_OR_UPDATE="up2date -i"
if [ -f /usr/bin/yum ]; then
	YUM_OR_UPDATE="yum install"
fi

DIR=/usr/share/doc/proxy/conf-template
VERSION=`rpm -q --queryformat %{version} spacewalk-proxy-installer|cut -d. -f1-2`
HOSTNAME=`hostname`

echo -n "Proxy version to activate [$VERSION]: "
VERSION=`default_or_input $VERSION`

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

if [ "$HTTP_PROXY" != "" ]; then

	echo -n "HTTP username []: "
	HTTP_USERNAME=`default_or_input `

	if [ "$HTTP_USERNAME" != "" ]; then
		echo -n "HTTP password []: "
        	HTTP_PASSWORD=`default_or_input `
	fi
fi

cat <<SSLCERT
Regardless of whether you enabled SSL for the connection to the Spacewalk Parent
Server, you will be prompted to generate an SSL certificate.
This SSL certificate will allow client systems to connect to this Spacewalk Proxy
securely. Refer to the Spacewalk Proxy Installation Guide for more information.
SSLCERT

echo -n "Organization: "
SSL_ORG=`default_or_input `

echo -n "Organization Unit [$HOSTNAME]: "
SSL_ORGUNIT=`default_or_input $HOSTNAME`

echo -n "Common Name: "
SSL_COMMON=`default_or_input`

echo -n "City: "
SSL_CITY=`default_or_input `

echo -n "State: "
SSL_STATE=`default_or_input `

echo -n "Country code: "
SSL_COUNTRY=`default_or_input `

echo -n "Email [$TRACEBACK_EMAIL]: "
SSL_EMAIL=`default_or_input $TRACEBACK_EMAIL`


/usr/bin/rhn-proxy-activate --server="$RHN_PARENT" --http-proxy="$HTTP_PROXY" --http-proxy-username="$HTTP_USERNAME" --http-proxy-password="$HTTP_PASSWORD" --ca-cert="$CA_CHAIN" --version="$VERSION" --non-interactive
config_error $? "Proxy activation failed!"

$YUM_OR_UPDATE spacewalk-proxy-management

rpm -q spacewalk-proxy-monitoring >/dev/null
MONITORING=$?
if [ $MONITORING -ne 0 ]; then
        echo "You do not have monitoring installed. Do you want to install it?"

	echo -n "Will run '$YUM_OR_UPDATE spacewalk-proxy-monitoring'.  [Y/n]:"
	INSTALL_MONITORING=`default_or_input Y | tr y Y`
	if [ "$INSTALL_MONITORING" = "Y" ]; then
	        $YUM_OR_UPDATE spacewalk-proxy-monitoring
	        MONITORING=$?
	fi
else
	$YUM_OR_UPDATE spacewalk-proxy-monitoring
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
        echo "Your scout shared key (can be found on parent"
        echo -n "in /etc/rhn/cluster.ini as key scoutsharedkey): "
        SCOUT_SHARED_KEY=`default_or_input `
fi

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

# lets do SSL stuff
SSL_BUILD_DIR="/root/ssl-build"

if [ ! -f $SSL_BUILD_DIR/RHN-ORG-PRIVATE-SSL-KEY ]; then
	echo "Generating CA key and public certificate:"
	/usr/bin/rhn-ssl-tool --gen-ca -q --dir="$SSL_BUILD_DIR" --set-common-name="$SSL_COMMON" \
		--set-country="$SSL_COUNTRY" --set-city="$SSL_CITY" --set-state="$SSL_STATE" \
		--set-org="$SSL_ORG" --set-org-unit="$SSL_ORGUNIT" --set-email="$SSL_EMAIL"
	config_error $? "CA certificate generation failed!"
else
	echo "Using CA key at $SSL_BUILD_DIR/RHN-ORG-PRIVATE-SSL-KEY."
fi

RPM_CA=`grep noarch $SSL_BUILD_DIR/latest.txt`

if [ ! -f $SSL_BUILD_DIR/$RPM_CA ]; then
	echo "Generating distributable RPM for CA public certificate:"
        /usr/bin/rhn-ssl-tool --gen-ca -q --rpm-only --dir="$SSL_BUILD_DIR"
	RPM_CA=`grep noarch $SSL_BUILD_DIR/latest.txt`
fi

if [ ! -f /var/www/html/pub/$RPM_CA ] || [ ! -f /var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT ]; then
	echo "Copying CA public certificate to /var/www/html/pub for distribution to clients:"
	cp $SSL_BUILD_DIR/RHN-ORG-TRUSTED-SSL-CERT $SSL_BUILD_DIR/$RPM_CA /var/www/html/pub/
fi

echo "Generating SSL key and public certificate:"
/usr/bin/rhn-ssl-tool --gen-server -q --no-rpm --set-hostname "$HOSTNAME" --dir="$SSL_BUILD_DIR" \
		--set-country="$SSL_COUNTRY" --set-city="$SSL_CITY" --set-state="$SSL_STATE"  \
		--set-org="$SSL_ORG" --set-org-unit="$SSL_ORGUNIT" --set-email="$SSL_EMAIL"
config_error $? "SSL key generation failed!"

echo "Installing SSL certificate for Apache and Jabberd:"
rpm -Uv `/usr/bin/rhn-ssl-tool --gen-server --rpm-only --dir="$SSL_BUILD_DIR" 2>/dev/null |grep noarch.rpm`

/etc/init.d/rhn-proxy restart
