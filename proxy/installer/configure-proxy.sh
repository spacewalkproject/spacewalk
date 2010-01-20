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

  --version=VERSION
			Version of Spacewalk Proxy Server you want to activate.
  --rhn-parent=RHN_PARENT
			Your parent Spacewalk server.
  --traceback-email=TRACEBACK_EMAIL
			Email to which tracebacks should be sent.
  --use-ssl=USE_SSL
			1  if  Spacewalk  Proxy Server should communicate with parent over SSL. 
			0 otherwise. Even if disabled, client can still use SSL to connect 
			to Spacewalk Proxy Server.
  --ca-chain=CA_CHAIN
			The CA cert used to verify the ssl connection to parent.
  --force-own-ca
			Do not use parent CA and force to create your own.
  --http-proxy=HTTP_PROXY
			HTTP proxy in host:port format, e.g. squid.redhat.com:3128
  --http-username=HTTP_USERNAME
			The username for an authenticated proxy.
  --http-password=HTTP_PASSWORD
			The password to use for an authenticated proxy.
  --ssl-build-dir=SSL_BUILD_DIR
			The directory where we build SSL certificate. Default is /root/ssl-build
  --ssl-org=SSL_ORG
			Organization name to be used in SSL certificate.
  --ssl-orgunit=SSL_ORGUNIT
			Organization unit name to be used in SSL certificate.
  --ssl-common=SSL_COMMON
			Common name to be used in SSL certificate.
  --ssl-city=SSL_CITY
			City to be used in SSL certificate.
  --ssl-state=SSL_STATE
			State to be used in SSL certificate.
  --ssl-country=SSL_COUNTRY
			Two letters country code to be used in SSL certificate.
  --ssl-email=SSL_EMAIL
			Email to be used in SSL certificate.
  --ssl-password=SSL_PASSWORD
			Password to be used for SSL CA certificate.
  --install-monitoring=Y
			Y if monitoring should be installed. Any other value means that 
			monitoring will not be installed.
  --enable-scout=1
			1 to enable monitoring scout, 0 otherwise.
  --monitoring-parent=MONITORING_PARENT
			Name of the parent for your scout. Usually the same value as in 
			RHN_PARENT.
  --monitoring-parent-ip=MONITORING_PARENT_IP
			IP address of MONITORING_PARENT
  --populate-config-channel=Y
			Y if config chanel should be created and configuration files in that channel
			updated. Configuration channel will be named rhn_proxy_config_\${SYSTEM_ID}.		
HELP
	exit
}

INTERACTIVE=1

while [ $# -ge 1 ]; do
	case $1 in
            --help | -h)  print_help;;
            --answer-file=*) . $(echo $1 | cut -d= -f2-);;
            --non-interactive) INTERACTIVE=0;;

			--version=*) VERSION=$(echo $1 | cut -d= -f2-);;
			--rhn-parent=*) RHN_PARENT=$(echo $1 | cut -d= -f2-);;
			--traceback-email=*) TRACEBACK_EMAIL=$(echo $1 | cut -d= -f2-);;
			--use-ssl=*) USE_SSL=$(echo $1 | cut -d= -f2-);;
			--ca-chain=*) CA_CHAIN=$(echo $1 | cut -d= -f2-);;
			--force-own-ca) FORCE_OWN_CA=1;;
			--http-proxy=*) HTTP_PROXY=$(echo $1 | cut -d= -f2-);;
			--http-username=*) HTTP_USERNAME=$(echo $1 | cut -d= -f2-);;
			--http-password=*) HTTP_PASSWORD=$(echo $1 | cut -d= -f2-);;
			--ssl-build-dir=*) SSL_BUILD_DIR=$(echo $1 | cut -d= -f2-);;
			--ssl-org=*) SSL_ORG=$(echo $1 | cut -d= -f2-);;
			--ssl-orgunit=*) SSL_ORGUNIT=$(echo $1 | cut -d= -f2-);;
			--ssl-common=*) SSL_COMMON=$(echo $1 | cut -d= -f2-);;
			--ssl-city=*) SSL_CITY=$(echo $1 | cut -d= -f2-);;
			--ssl-state=*) SSL_STATE=$(echo $1 | cut -d= -f2-);;
			--ssl-country=*) SSL_COUNTRY=$(echo $1 | cut -d= -f2-);;
			--ssl-email=*) SSL_EMAIL=$(echo $1 | cut -d= -f2-);;
			--ssl-password=*) SSL_PASSWORD=$(echo $1 | cut -d= -f2-);;
			--install-monitoring=*) INSTALL_MONITORING=$(echo $1 | cut -d= -f2-);;
			--enable-scout=*) ENABLE_SCOUT=$(echo $1 | cut -d= -f2-);;
			--monitoring-parent=*) MONITORING_PARENT_IP=$(echo $1 | cut -d= -f2-);;
			--monitoring-parent-ip=*) MONITORING_PARENT_IP=$(echo $1 | cut -d= -f2-);;
			--populate-config-channel=*) POPULATE_CONFIG_CHANNEL=$(echo $1 | cut -d= -f2-);;
			*) echo Error: Invalid option $1
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
                Y|y|Y/n|n/Y|1)
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
                /usr/bin/rhn-proxy-activate \
                        --server="$RHN_PARENT" \
                        --http-proxy="$HTTP_PROXY" \
                        --http-proxy-username="$HTTP_USERNAME" \
                        --http-proxy-password="$HTTP_PASSWORD" \
                        --ca-cert="$CA_CHAIN" \
                        --deactivate --non-interactive
                exit $1
        fi
}

#do we have yum or up2date?
YUM_OR_UPDATE="up2date -i"
UPGRADE="up2date -u"
if [ -f /usr/bin/yum ]; then
        YUM_OR_UPDATE="yum install"
        UPGRADE="yum upgrade"
        # add -y for non-interactive installation
        if [ "$INTERACTIVE" = "0" ]; then
                YUM_OR_UPDATE="$YUM_OR_UPDATE -y"
                UPGRADE="$UPGRADE -y"
        fi
fi
SYSCONFIG_DIR=/etc/sysconfig/rhn
RHNCONF_DIR=/etc/rhn
HTTPDCONF_DIR=/etc/httpd/conf
HTTPDCONFD_DIR=/etc/httpd/conf.d
HTMLPUB_DIR=/var/www/html/pub
JABBERD_DIR=/etc/jabberd
SQUID_DIR=/etc/squid

if [ ! -r $SYSCONFIG_DIR/systemid ]; then
	echo ERROR: RHN Proxy does not appear to be registered
	exit 2
fi

SYSTEM_ID=$(/usr/bin/xsltproc /usr/share/rhn/get_system_id.xslt $SYSCONFIG_DIR/systemid | cut -d- -f2)

DIR=/usr/share/doc/proxy/conf-template
HOSTNAME=$(hostname)

SSL_BUILD_DIR=${SSL_BUILD_DIR:-/root/ssl-build}
if ! [ -d $SSL_BUILD_DIR ] && [ 0$FORCE_OWN_CA -eq 0 ]; then
	echo "Error: ssl build directory $SSL_BUILD_DIR does not exist. Please create this directory."
	exit 1
fi

default_or_input "RHN Parent" RHN_PARENT $(awk -F= '/serverURL=/ {split($2, a, "/")} END { print a[3]}' $SYSCONFIG_DIR/up2date)

if [ "$RHN_PARENT" == "rhn.redhat.com" ]; then
   RHN_PARENT="xmlrpc.rhn.redhat.com"
   cat <<WARNING
*** Warning: plain rhn.redhat.com should not be used as RHN Parent.
*** Using xmlrpc.rhn.redhat.com instead.
WARNING
fi

default_or_input "CA Chain" CA_CHAIN $(awk -F'[=;]' '/sslCACert=/ {a=$2} END { print a}' $SYSCONFIG_DIR/up2date)

if [ 0$FORCE_OWN_CA -eq 0 ] && \
	[ "$RHN_PARENT" != "xmlrpc.rhn.redhat.com" -a ! -f /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY ] && \
	! diff $CA_CHAIN /root/ssl-build/RHN-ORG-TRUSTED-SSL-KEY &>/dev/null; then
	cat <<CA_KEYS
Please do copy your CA key and public certificate from $RHN_PARENT to 
/root/ssl-build directory. You may want to execute this command:
 scp 'root@$RHN_PARENT:/root/ssl-build/{RHN-ORG-PRIVATE-SSL-KEY,RHN-ORG-TRUSTED-SSL-CERT,rhn-ca-openssl.cnf}' $SSL_BUILD_DIR
CA_KEYS
	exit 1
fi

if ! /sbin/runuser nobody -s /bin/sh --command="[ -r $CA_CHAIN ]" ; then
	echo Error: File $CA_CHAIN is not readable by nobody user.
	exit 1
fi

VERSION_FROM_PARENT=$(rhn-proxy-activate --server=$RHN_PARENT --list-available-versions 2>/dev/null|sort|tail -n1)
VERSION_FROM_RPM=$(rpm -q --queryformat %{version} spacewalk-proxy-installer|cut -d. -f1-2)
default_or_input "Proxy version to activate" VERSION ${VERSION_FROM_PARENT:-$VERSION_FROM_RPM}

default_or_input "Traceback email" TRACEBACK_EMAIL ''

default_or_input "Use SSL" USE_SSL 'Y/n'
USE_SSL=$(yes_no $USE_SSL)


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


/usr/bin/rhn-proxy-activate --server="$RHN_PARENT" \
                            --http-proxy="$HTTP_PROXY" \
                            --http-proxy-username="$HTTP_USERNAME" \
                            --http-proxy-password="$HTTP_PASSWORD" \
                            --ca-cert="$CA_CHAIN" \
                            --version="$VERSION" \
                            --non-interactive
config_error $? "Proxy activation failed!"

rpm -q rhn-apache >/dev/null
if [ $? -eq 0 ]; then
    echo "Package rhn-apache present - assuming upgrade:"
    echo "Force removal of /etc/httpd/conf/httpd.conf - backed up to /etc/httpd/conf/httpd.conf.rpmsave"
    mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.rpmsave
fi

$YUM_OR_UPDATE spacewalk-proxy-management
# check if package install successfully
rpm -q spacewalk-proxy-management >/dev/null
if [ $? -ne 0 ]; then
	config_error 2 "Installation of package spacewalk-proxy-management failed."
fi
$UPGRADE

if [ "$RHN_PARENT" == "xmlrpc.rhn.redhat.com" ]; then
    #skip monitoring part for hosted
    MONITORING=1
    ENABLE_SCOUT=0
else
    rpm -q spacewalk-proxy-monitoring >/dev/null
    MONITORING=$?
    if [ $MONITORING -ne 0 ]; then
        echo "You do not have monitoring installed."
		echo "Do you want to install monitoring scout?"

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
    if [ $MONITORING -eq 0 ]; then
        #here we configure monitoring
        #and with cluster.ini
        echo "Configuring monitoring."
        default_or_input "Monitoring parent" MONITORING_PARENT "$RHN_PARENT"
        RESOLVED_IP=$(/usr/bin/getent hosts $RHN_PARENT | cut -f1 -d' ')
        default_or_input "Monitoring parent IP" MONITORING_PARENT_IP "$RESOLVED_IP"
        default_or_input "Enable monitoring scout" ENABLE_SCOUT "Y/n"
        ENABLE_SCOUT=$(yes_no $ENABLE_SCOUT)
        SCOUT_SHARED_KEY=`/usr/bin/rhn-proxy-activate --enable-monitoring \
                --quiet \
                --server="$RHN_PARENT" \
                --http-proxy="$HTTP_PROXY" \
                --http-proxy-username="$HTTP_USERNAME" \
                --http-proxy-password="$HTTP_PASSWORD" \
                --ca-cert="$CA_CHAIN" | \
            awk '/\: [0-9a-f]+/  { print $4 }' `
    else
	    ENABLE_SCOUT=0
    fi
fi

# size of squid disk cache will be 60% of free space on /var/spool/squid
# df -P give free space in kB
# * 60 / 100 is 60% of that space
# / 1024 is to get value in MB
SQUID_SIZE=$(df -P /var/spool/squid | awk '{a=$4} END {printf("%d", a * 60 / 100 / 1024)}')

ln -sf /etc/pki/spacewalk/jabberd/server.pem /etc/jabberd/server.pem
sed "s/\${session.hostname\}/$HOSTNAME/g"  < $DIR/c2s.xml  > $JABBERD_DIR/c2s.xml
sed "s/\${session.hostname\}/$HOSTNAME/g"  < $DIR/sm.xml   > $JABBERD_DIR/sm.xml
sed "s|cache_dir ufs /var/spool/squid 15000 16 256|cache_dir ufs /var/spool/squid $SQUID_SIZE 16 256|g" \
        < $DIR/squid.conf  > $SQUID_DIR/squid.conf
sed -e "s|\${session.ca_chain:/usr/share/rhn/RHNS-CA-CERT}|$CA_CHAIN|g" \
	    -e "s/\${session.http_proxy}/$HTTP_PROXY/g" \
	    -e "s/\${session.http_proxy_username}/$HTTP_USERNAME/g" \
	    -e "s/\${session.http_proxy_password}/$HTTP_PASSWORD/g" \
	    -e "s/\${session.rhn_parent}/$RHN_PARENT/g" \
	    -e "s/\${session.traceback_mail}/$TRACEBACK_EMAIL/g" \
	    -e "s/\${session.use_ssl:0}/$USE_SSL/g" \
	    -e "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
        < $DIR/rhn.conf  > $RHNCONF_DIR/rhn.conf
if [ $MONITORING -eq 0 ]; then
	sed -e "s/\${session.enable_monitoring_scout:0}/$ENABLE_SCOUT/g" \
            -e "s/\${session.rhn_monitoring_parent_ip}/$MONITORING_PARENT_IP/g" \
            -e "s/\${session.rhn_monitoring_parent}/$MONITORING_PARENT/g" \
            -e "s/\${session.scout_shared_key}/$SCOUT_SHARED_KEY/g" \
        < $DIR/cluster.ini  > $RHNCONF_DIR/cluster.ini
fi

# systemid need to be readable by apache/proxy
chown root:apache $SYSCONFIG_DIR/systemid
chmod 0640 $SYSCONFIG_DIR/systemid

#Setup the cobbler stuff, needed to use koan through a proxy
PROTO="http";
if [ $USE_SSL -eq 1 ]; then
   PROTO="https"
fi
echo "ProxyPass /cobbler_api $PROTO://$RHN_PARENT/cobbler_api" > $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "ProxyPassReverse /cobbler_api $PROTO://$RHN_PARENT/cobbler_api" >> $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "RewriteRule ^/cblr/svc/op/ks/(.*)$ /download/$0 [P,L]" >> $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "ProxyPass /cblr $PROTO://$RHN_PARENT/cblr" >> $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "ProxyPassReverse /cblr $PROTO://$RHN_PARENT/cblr" >> $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "ProxyPass /cobbler $PROTO://$RHN_PARENT/cobbler" >> $HTTPDCONFD_DIR/cobbler-proxy.conf
echo "ProxyPassReverse /cobbler $PROTO://$RHN_PARENT/cobbler" >> $HTTPDCONFD_DIR/cobbler-proxy.conf



# lets do SSL stuff
SSL_BUILD_DIR=${SSL_BUILD_DIR:-"/root/ssl-build"}

if [ -n "$SSL_PASSWORD" ] ; then
        # use SSL_PASSWORD if already set
        RHN_SSL_TOOL_PASSWORD_OPTION="--password"
		RHN_SSL_TOOL_PASSWORD="$SSL_PASSWORD"
elif [ "$INTERACTIVE" = "0" ] ; then
        # non-interactive mode but no SSL_PASSWORD :(
        config_error 4 "Please define SSL_PASSWORD."
fi

if [ ! -f $SSL_BUILD_DIR/RHN-ORG-PRIVATE-SSL-KEY ]; then
	echo "Generating CA key and public certificate:"
	/usr/bin/rhn-ssl-tool --gen-ca -q \
                --dir="$SSL_BUILD_DIR" \
                --set-common-name="$SSL_COMMON" \
                --set-country="$SSL_COUNTRY" \
                --set-city="$SSL_CITY" \
                --set-state="$SSL_STATE" \
                --set-org="$SSL_ORG" \
                --set-org-unit="$SSL_ORGUNIT" \
                --set-email="$SSL_EMAIL" \
                $RHN_SSL_TOOL_PASSWORD_OPTION $RHN_SSL_TOOL_PASSWORD
	config_error $? "CA certificate generation failed!"
else
	echo "Using CA key at $SSL_BUILD_DIR/RHN-ORG-PRIVATE-SSL-KEY."
fi

RPM_CA=$(grep noarch $SSL_BUILD_DIR/latest.txt 2>/dev/null)

if [ ! -f $SSL_BUILD_DIR/$RPM_CA ]; then
	echo "Generating distributable RPM for CA public certificate:"
        /usr/bin/rhn-ssl-tool --gen-ca -q --rpm-only --dir="$SSL_BUILD_DIR"
	RPM_CA=$(grep noarch $SSL_BUILD_DIR/latest.txt)
fi

if [ ! -f $HTMLPUB_DIR/$RPM_CA ] || [ ! -f $HTMLPUB_DIR/RHN-ORG-TRUSTED-SSL-CERT ] || \
    ! diff $HTMLPUB_DIR/RHN-ORG-TRUSTED-SSL-CERT $SSL_BUILD_DIR/RHN-ORG-TRUSTED-SSL-CERT &>/dev/null; then
	echo "Copying CA public certificate to $HTMLPUB_DIR for distribution to clients:"
	cp $SSL_BUILD_DIR/RHN-ORG-TRUSTED-SSL-CERT $SSL_BUILD_DIR/$RPM_CA $HTMLPUB_DIR/
fi

echo "Generating SSL key and public certificate:"
/usr/bin/rhn-ssl-tool --gen-server -q --no-rpm \
                --set-hostname "$HOSTNAME" \
                --dir="$SSL_BUILD_DIR" \
                --set-country="$SSL_COUNTRY" \
                --set-city="$SSL_CITY" \
                --set-state="$SSL_STATE" \
                --set-org="$SSL_ORG" \
                --set-org-unit="$SSL_ORGUNIT" \
                --set-email="$SSL_EMAIL" \
                $RHN_SSL_TOOL_PASSWORD_OPTION $RHN_SSL_TOOL_PASSWORD
config_error $? "SSL key generation failed!"

echo "Installing SSL certificate for Apache and Jabberd:"
rpm -Uv $(/usr/bin/rhn-ssl-tool --gen-server --rpm-only --dir="$SSL_BUILD_DIR" 2>/dev/null |grep noarch.rpm)

if [ -e $HTTPDCONFD_DIR/ssl.conf ]; then
	mv $HTTPDCONFD_DIR/ssl.conf $HTTPDCONFD_DIR/ssl.conf.bak
fi
sed -e "s|^SSLCertificateFile /etc/pki/tls/certs/localhost.crt$|SSLCertificateFile $HTTPDCONF_DIR/ssl.crt/server.crt|g" \
	    -e "s|^SSLCertificateKeyFile /etc/pki/tls/private/localhost.key$|SSLCertificateKeyFile $HTTPDCONF_DIR/ssl.key/server.key|g" \
	    -e "s|</VirtualHost>|SSLProxyEngine on\n</VirtualHost>|" \
        < $HTTPDCONFD_DIR/ssl.conf.bak  > $HTTPDCONFD_DIR/ssl.conf


CHANNEL_LABEL="rhn_proxy_config_$SYSTEM_ID"
default_or_input "Create and populate configuration channel $CHANNEL_LABEL?" POPULATE_CONFIG_CHANNEL 'Y/n'
POPULATE_CONFIG_CHANNEL=$(yes_no $POPULATE_CONFIG_CHANNEL)
if [ "$POPULATE_CONFIG_CHANNEL" = "1" ]; then
	rhncfg-manager create-channel --server-name "$RHN_PARENT" \
                rhn_proxy_config_$SYSTEM_ID
	rhncfg-manager update --server-name "$RHN_PARENT" \
                --channel=rhn_proxy_config_$SYSTEM_ID \
                $HTTPDCONFD_DIR/ssl.conf \
                $RHNCONF_DIR/rhn.conf \
                $RHNCONF_DIR/cluster.ini \
                $SQUID_DIR/squid.conf \
                $HTTPDCONFD_DIR/cobbler-proxy.conf \
                $HTTPDCONF_DIR/httpd.conf \
                $HTTPDCONFD_DIR/rhn_proxy.conf \
                $HTTPDCONFD_DIR/proxy_broker.conf \
                $HTTPDCONFD_DIR/proxy_redirect.conf \
                $JABBERD_DIR/c2s.xml \
                $JABBERD_DIR/sm.xml
fi

echo "Enabling Spacewalk Proxy."
if [ $ENABLE_SCOUT -ne 0 ]; then
  MonitoringScout="MonitoringScout"
fi
for service in squid httpd jabberd $MonitoringScout; do
  /sbin/chkconfig --add $service 
  /sbin/chkconfig --level 345 $service on 
done
/usr/sbin/rhn-proxy restart

