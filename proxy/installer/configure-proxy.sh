#!/bin/bash

if [ 0$UID -gt 0 ]; then
       echo Run as root.
       exit 1
fi

print_help () {
	cat <<HELP
usage: configure-proxy.sh [options]

options:
  --answer-file=filename
            Indicates the location of an answer file to be use for answering
            questions asked during the installation process. See man page for
            for an example and documentation.
  -h, --help            
            show this help message and exit
  --non-interactive
            For use only with --answer-file. If the --answer-file doesn't
            provide a required response, default answer is used.

HELP
	exit
}

INTERACTIVE=1

while [ $# -ge 1 ]; do
	case $1 in
            --help | -h)  print_help;;
            --answer-file=*) . `echo $1 | cut -d= -f2`;;
            --non-interactive) INTERACTIVE=0;;
    esac
    shift
done

default_or_input () {
	local MSG="$1"
	local VARIABLE="$2"
	local DEFAULT="$3"

	local INPUT
	local CURRENT_VALUE=$(eval "echo \$$VARIABLE")
	#in following code is used not so common expansion
	#var_a=${var_b:-word}
	#which is like: var_a = $var_b ? word
	DEFAULT=${CURRENT_VALUE:-$DEFAULT}
	local VARIABLE_ISSET=$(set | grep "^$VARIABLE=")

	echo -n "$MSG [$DEFAULT]: "
	if [ "$INTERACTIVE" = "1" -a  -z "$VARIABLE_ISSET" ]; then
		read INPUT
	elif [ -z "$VARIABLE_ISSET" ]; then
		echo $DEFAULT
	else
		eval "DEFAULT=\$$VARIABLE"
		echo $DEFAULT
	fi
	if [ -z "$INPUT" ]; then
		INPUT="$DEFAULT"
	fi
	eval "$VARIABLE='$INPUT'"
}

yes_no() {
        case "$1" in
                Y|y|Y/n|n/Y)
                        echo 1
                        ;;
                *)
                        echo 0
                        ;;
        esac
}

config_error () {
        if [ $1 -gt 0 ]; then
                echo "$2 Installation interrupted."
                /usr/bin/rhn-proxy-activate --server="$RHN_PARENT" --http-proxy="$HTTP_PROXY" --http-proxy-username="$HTTP_USERNAME" --http-proxy-password="$HTTP_PASSWORD" --ca-cert="$CA_CHAIN" --deactivate --non-interactive
                exit $1
        fi
}

#do we have yum or up2date?
YUM_OR_UPDATE="up2date -i"
if [ -f /usr/bin/yum ]; then
	YUM_OR_UPDATE="yum install"
        # add -y for non-interactive installation
	[ "$INTERACTIVE" = "0" ] && YUM_OR_UPDATE="$YUM_OR_UPDATE -y"
fi
SYSCONFIG_DIR=/etc/sysconfig/rhn
RHNCONF_DIR=/etc/rhn
HTTPDCONFD_DIR=/etc/httpd/conf.d
HTMLPUB_DIR=/var/www/html/pub
JABBERD_DIR=/etc/jabberd


SYSTEM_ID=`/usr/bin/xsltproc /usr/share/rhn/get_system_id.xslt $SYSCONFIG_DIR/systemid | cut -d- -f2`

DIR=/usr/share/doc/proxy/conf-template
HOSTNAME=`hostname`

default_or_input "Proxy version to activate" VERSION $(rpm -q --queryformat %{version} spacewalk-proxy-installer|cut -d. -f1-2)

default_or_input "RHN Parent" RHN_PARENT $(awk -F= '/serverURL=/ {split($2, a, "/")} END { print a[3]}' $SYSCONFIG_DIR/up2date)

if [ "$RHN_PARENT" == "rhn.redhat.com" ]; then
   RHN_PARENT="xmlrpc.rhn.redhat.com"
   cat <<WARNING
*** Warning: plain rhn.redhat.com should not be used as RHN Parent.
*** Using xmlrpc.rhn.redhat.com instead.
WARNING
fi

default_or_input "Traceback email" TRACEBACK_EMAIL ''

default_or_input "Use SSL" USE_SSL 'Y/n'
USE_SSL=$(yes_no $USE_SSL)

default_or_input "CA Chain" CA_CHAIN $(awk -F'[=;]' '/sslCACert=/ {a=$2} END { print a}' $SYSCONFIG_DIR/up2date)

if ! /sbin/runuser apache -s /bin/sh --command="[ -r $CA_CHAIN ]" ; then
	echo Error: File $CA_CHAIN is not readable by apache user.
	exit 1
fi

default_or_input "HTTP Proxy" HTTP_PROXY ''

if [ "$HTTP_PROXY" != "" ]; then

	default_or_input "HTTP username" HTTP_USERNAME ''

	if [ "$HTTP_USERNAME" != "" ]; then
		default_or_input "HTTP password" HTTP_PASSWORD ''
	fi
fi

cat <<SSLCERT
Regardless of whether you enabled SSL for the connection to the Spacewalk Parent
Server, you will be prompted to generate an SSL certificate.
This SSL certificate will allow client systems to connect to this Spacewalk Proxy
securely. Refer to the Spacewalk Proxy Installation Guide for more information.
SSLCERT

default_or_input "Organization" SSL_ORG ''

default_or_input "Organization Unit" SSL_ORGUNIT "$HOSTNAME"

default_or_input "Common Name" SSL_COMMON "$HOSTNAME"

default_or_input "City" SSL_CITY ''

default_or_input "State" SSL_STATE ''

default_or_input "Country code" SSL_COUNTRY ''

default_or_input "Email" SSL_EMAIL "$TRACEBACK_EMAIL"


/usr/bin/rhn-proxy-activate --server="$RHN_PARENT" --http-proxy="$HTTP_PROXY" --http-proxy-username="$HTTP_USERNAME" --http-proxy-password="$HTTP_PASSWORD" --ca-cert="$CA_CHAIN" --version="$VERSION" --non-interactive
config_error $? "Proxy activation failed!"

$YUM_OR_UPDATE spacewalk-proxy-management
# check if package install successfully
rpm -q spacewalk-proxy-management >/dev/null
if [ $? -ne 0 ]; then
	config_error 2 "Installation of package spacewalk-proxy-management failed."
fi

rpm -q spacewalk-proxy-monitoring >/dev/null
MONITORING=$?
if [ $MONITORING -ne 0 ]; then
        echo "You do not have monitoring installed. Do you want to install it?"

        default_or_input "Will run '$YUM_OR_UPDATE spacewalk-proxy-monitoring'." INSTALL_MONITORING 'Y/n'
        INSTALL_MONITORING=$(yes_no $INSTALL_MONITORING)
	if [ "$INSTALL_MONITORING" = "1" ]; then
	        $YUM_OR_UPDATE spacewalk-proxy-monitoring
	        MONITORING=$?
	fi
else
	$YUM_OR_UPDATE spacewalk-proxy-monitoring
    # check if package install successfully
    rpm -q spacewalk-proxy-monitoring >/dev/null
    if [ $? -ne 0 ]; then
        config_error 3 "Installation of package spacewalk-proxy-monitoring failed."
    fi
fi
ENABLE_SCOUT=0
if [ $MONITORING -eq 0 ]; then
	#here we configure monitoring
	#and with cluster.ini
	echo "Configuring monitoring."
        default_or_input "Monitoring parent" MONITORING_PARENT "$RHN_PARENT"
        RESOLVED_IP=`/usr/bin/getent hosts $RHN_PARENT | cut -f1 -d' '`
        default_or_input "Monitoring parent IP" MONITORING_PARENT_IP "$RESOLVED_IP"
        default_or_input "Enable monitoring scout" ENABLE_SCOUT "Y/n"
        ENABLE_SCOUT=$(yes_no $ENABLE_SCOUT)
        MSG=$(echo -n "Your scout shared key (can be found on parent\nin $RHNCONF_DIR/cluster.ini as key scoutsharedkey)")
        default_or_input "$MSG" SCOUT_SHARED_KEY ''
fi

# size of squid disk cache will be 60% of free space on /var/spool/squid
# df -P give free space in kB
# * 60 / 100 is 60% of that space
# / 1024 is to get value in MB
SQUID_SIZE=$(( `df -P /var/spool/squid | awk '{a=$4} END {print a}'` * 60 / 100 / 1024 ))

sed "s/\${session.hostname\}/$HOSTNAME/g"  < $DIR/c2s.xml  > $JABBERD_DIR/c2s.xml
sed "s/\${session.hostname\}/$HOSTNAME/g"  < $DIR/sm.xml   > $JABBERD_DIR/sm.xml
sed "s|cache_dir ufs /var/spool/squid 15000 16 256|cache_dir ufs /var/spool/squid $SQUID_SIZE 16 256|g" \
        < $DIR/squid.conf  > /etc/squid/squid.conf
sed -e "s|\${session.ca_chain:/usr/share/rhn/RHNS-CA-CERT}|$CA_CHAIN|g" \
	    -e "s/\${session.http_proxy}/$HTTP_PROXY/g" \
	    -e "s/\${session.http_proxy_username}/$HTTP_USERNAME/g" \
	    -e "s/\${session.http_proxy_password}/$HTTP_PASSWORD/g" \
	    -e "s/\${session.rhn_parent}/$RHN_PARENT/g" \
	    -e "s/\${session.traceback_mail}/$TRACEBACK_EMAIL/g" \
	    -e "s/\${session.use_ssl:0}/$USE_SSL/g" \
	    -e "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
        < $DIR/rhn.conf  > $RHNCONF_DIR/rhn.conf
sed -e "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
            -e "s/\${session.rhn_monitoring_parent_ip}/$MONITORING_PARENT_IP/g" \
            -e "s/\${session.rhn_monitoring_parent}/$MONITORING_PARENT/g" \
            -e "s/\${session.scout_shared_key}/$SCOUT_SHARED_KEY/g" \
        < cat $DIR/cluster.ini  > $RHNCONF_DIR/cluster.ini


#Setup the cobbler stuff, needed to use koan through a proxy
PROTO="http";
if [ $USE_SSL -eq 1 ]; then
   PROTO="https"
fi
echo "ProxyPass /cobbler_api $PROTO://$RHN_PARENT/cobbler_api" > $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "ProxyPassReverse /cobbler_api $PROTO://$RHN_PARENT/cobbler_api" >> $HTTPDCONFD_DIR/cobbler-proxy.conf

# lets do SSL stuff
SSL_BUILD_DIR="/root/ssl-build"

if [ -n "$SSL_PASSWORD" ] ; then
        # use SSL_PASSWORD if already set
        RHNSSLTOOLPWD="--password '$SSL_PASSWORD'"
elif [ "$INTERACTIVE" = "0" ] ; then
        # non-interactive mode but no SSL_PASSWORD :(
        config_error 4 "Please define SSL_PASSWORD."
fi

if [ ! -f $SSL_BUILD_DIR/RHN-ORG-PRIVATE-SSL-KEY ]; then
	echo "Generating CA key and public certificate:"
	/usr/bin/rhn-ssl-tool --gen-ca -q --dir="$SSL_BUILD_DIR" --set-common-name="$SSL_COMMON" \
		--set-country="$SSL_COUNTRY" --set-city="$SSL_CITY" --set-state="$SSL_STATE" \
		--set-org="$SSL_ORG" --set-org-unit="$SSL_ORGUNIT" --set-email="$SSL_EMAIL" \
                $RHNSSLTOOLPWD
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

if [ ! -f $HTMLPUB_DIR/$RPM_CA ] || [ ! -f $HTMLPUB_DIR/RHN-ORG-TRUSTED-SSL-CERT ]; then
	echo "Copying CA public certificate to $HTMLPUB_DIR for distribution to clients:"
	cp $SSL_BUILD_DIR/RHN-ORG-TRUSTED-SSL-CERT $SSL_BUILD_DIR/$RPM_CA $HTMLPUB_DIR/
fi

echo "Generating SSL key and public certificate:"
/usr/bin/rhn-ssl-tool --gen-server -q --no-rpm --set-hostname "$HOSTNAME" --dir="$SSL_BUILD_DIR" \
		--set-country="$SSL_COUNTRY" --set-city="$SSL_CITY" --set-state="$SSL_STATE"  \
		--set-org="$SSL_ORG" --set-org-unit="$SSL_ORGUNIT" --set-email="$SSL_EMAIL" \
                $RHNSSLTOOLPWD
config_error $? "SSL key generation failed!"

echo "Installing SSL certificate for Apache and Jabberd:"
rpm -Uv `/usr/bin/rhn-ssl-tool --gen-server --rpm-only --dir="$SSL_BUILD_DIR" 2>/dev/null |grep noarch.rpm`

mv $HTTPDCONFD_DIR/ssl.conf $HTTPDCONFD_DIR/ssl.conf.bak
sed -e "s|^SSLCertificateFile /etc/pki/tls/certs/localhost.crt$|SSLCertificateFile /etc/httpd/conf/ssl.crt/server.crt|g" \
	    -e "s|^SSLCertificateKeyFile /etc/pki/tls/private/localhost.key$|SSLCertificateKeyFile /etc/httpd/conf/ssl.key/server.key|g" \
	    -e "s|</VirtualHost>|SSLProxyEngine on\n</VirtualHost>|"
        < $HTTPDCONFD_DIR/ssl.conf.bak  > $HTTPDCONFD_DIR/ssl.conf


CHANNEL_LABEL="rhn_proxy_config_$SYSTEM_ID"
default_or_input "Create and populate configuration channel $CHANNEL_LABEL?" POPULATE_CONFIG_CHANNEL 'Y/n'
POPULATE_CONFIG_CHANNEL=$(yes_no $POPULATE_CONFIG_CHANNEL)
if [ "$POPULATE_CONFIG_CHANNEL" = "1" ]; then
	rhncfg-manager create-channel --server-name "$RHN_PARENT" rhn_proxy_config_$SYSTEM_ID
	rhncfg-manager update --server-name "$RHN_PARENT" --channel=rhn_proxy_config_$SYSTEM_ID \
		$HTTPDCONFD_DIR/ssl.conf $RHNCONF_DIR/rhn.conf $RHNCONF_DIR/cluster.ini /etc/squid/squid.conf \
		$HTTPDCONFD_DIR/cobbler-proxy.conf /etc/httpd/conf/httpd.conf $HTTPDCONFD_DIR/rhn_proxy.conf \
		$HTTPDCONFD_DIR/proxy_broker.conf $HTTPDCONFD_DIR/proxy_redirect.conf \
		$JABBERD_DIR/c2s.xml $JABBERD_DIR/sm.xml
fi

echo "Enabling Spacewalk Proxy."
if [ $ENABLE_SCOUT -ne 0 ]; then
  MonitoringScout="MonitoringScout"
fi
for service in squid httpd jabberd $MonitoringScout; do
  /sbin/chkconfig --add $service 
  if [ "$1" = "1" ] ; then  # first install
      /sbin/chkconfig --level 345 $service on 
  fi
done
/usr/sbin/rhn-proxy restart

