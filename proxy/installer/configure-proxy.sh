#!/bin/bash

if [ 0$UID -gt 0 ]; then
    echo Run as root.
    exit 1
fi

print_help() {
    cat <<HELP
usage: configure-proxy.sh [options]

options:
  --answer-file=filename
            Indicates the location of an answer file to be use for answering
            questions asked during the installation process. See man page for
            for an example and documentation.
  --enable-scout
            Enable monitoring scout.
  --force-own-ca
            Do not use parent CA and force to create your own.
  -h, --help
            show this help message and exit
  --http-password=HTTP_PASSWORD
            The password to use for an authenticated proxy.
  --http-proxy=HTTP_PROXY
            HTTP proxy in host:port format, e.g. squid.redhat.com:3128
  --http-username=HTTP_USERNAME
            The username for an authenticated proxy.
  --install-monitoring
            Install and enable monitoring.
  --monitoring-parent=MONITORING_PARENT
            Name of the parent for your scout. Usually RHN parent.
  --monitoring-parent-ip=MONITORING_PARENT_IP
            IP address of MONITORING_PARENT
  --non-interactive
            For use only with --answer-file. If the --answer-file doesn't
            provide a required response, default answer is used.
  --populate-config-channel
            Create config chanel and save configuration files to that channel.
            Configuration channel name is rhn_proxy_config_\${SYSTEM_ID}.
  --rhn-password=RHN_PASSWORD
            Red Hat Network or Spacewalk password.
  --rhn-user=RHN_USER
            Red Hat Network or Spacewalk user account.
  --ssl-build-dir=SSL_BUILD_DIR
            The directory where we build SSL certificate. Default is /root/ssl-build
  --ssl-city=SSL_CITY
            City to be used in SSL certificate.
  --ssl-common=SSL_COMMON
            Common name to be used in SSL certificate.
  --ssl-country=SSL_COUNTRY
            Two letters country code to be used in SSL certificate.
  --ssl-email=SSL_EMAIL
            Email to be used in SSL certificate.
  --ssl-org=SSL_ORG
            Organization name to be used in SSL certificate.
  --ssl-orgunit=SSL_ORGUNIT
            Organization unit name to be used in SSL certificate.
  --ssl-password=SSL_PASSWORD
            Password to be used for SSL CA certificate.
  --ssl-state=SSL_STATE
            State to be used in SSL certificate.
  --ssl-cname=CNAME_ALIAS
            Cname alias of the machine. Can be specified multiple times.
  --start-services[=N]
            1 or Y to start all services after configuration. This is default.
            0 or N to not start services after configuration.
  --traceback-email=TRACEBACK_EMAIL
            Email to which tracebacks should be sent.
  --use-ssl
            Let Spacewalk Proxy Server communicate with parent over SSL.
            Even if it is disabled client can still use SSL to connect
            to Spacewalk Proxy Server.
  --version=VERSION
            Version of Spacewalk Proxy Server you want to activate.
HELP
    exit 1
}

parse_answer_file() {
    local FILE="$1"
    local ALIAS
    if [ ! -r "$FILE" ] ; then
       echo "Answer file '$FILE' is not readable."
       exit 1
    fi
    . "$FILE"
    for ALIAS in ${SSL_CNAME[@]}; do
        SSL_CNAME_PARSED[CNAME_INDEX++]=--set-cname=$ALIAS
    done
}

set_value() {
    local OPTION="$1"
    local VAR="$2"
    local ARG="$3"
    [[ "$ARG" =~ ^- ]] \
        && echo "$0: option $OPTION requires argument! Use answer file if your argument starts with '-'." \
        && print_help
    eval "$(printf "%q=%q" "$VAR" "$ARG")"
}

INTERACTIVE=1
CNAME_INDEX=0

OPTS=$(getopt --longoptions=help,answer-file:,non-interactive,version:,traceback-email:,use-ssl::,force-own-ca,http-proxy:,http-username:,http-password:,ssl-build-dir:,ssl-org:,ssl-orgunit:,ssl-common:,ssl-city:,ssl-state:,ssl-country:,ssl-email:,ssl-password:,ssl-cname:,install-monitoring::,enable-scout::,monitoring-parent:,monitoring-parent-ip:,populate-config-channel::,start-services:: -n ${0##*/} -- h "$@")

if [ $? != 0 ] ; then
    print_help
fi

# It is getopt's responsibility to make this safe
eval set -- "$OPTS"

while : ; do
    case "$1" in
        --help|-h)  print_help;;
        --answer-file) set_value "$1" ANSWER_FILE "$2";
                       parse_answer_file "$ANSWER_FILE"; shift;;
        --non-interactive) INTERACTIVE=0;;
        --version) set_value "$1" VERSION "$2"; shift;;
        --traceback-email) set_value "$1" TRACEBACK_EMAIL "$2"; shift;;
        --use-ssl) USE_SSL="${2:-1}"; shift;;
        --force-own-ca) FORCE_OWN_CA=1;;
        --http-proxy) set_value "$1" HTTP_PROXY "$2"; shift;;
        --http-username) set_value "$1" HTTP_USERNAME "$2"; shift;;
        --http-password) set_value "$1" HTTP_PASSWORD "$2"; shift;;
        --ssl-build-dir) set_value "$1" SSL_BUILD_DIR "$2"; shift;;
        --ssl-org) set_value "$1" SSL_ORG "$2"; shift;;
        --ssl-orgunit) set_value "$1" SSL_ORGUNIT "$2"; shift;;
        --ssl-common) set_value "$1" SSL_COMMON "$2"; shift;;
        --ssl-city) set_value "$1" SSL_CITY "$2"; shift;;
        --ssl-state) set_value "$1" SSL_STATE "$2"; shift;;
        --ssl-country) set_value "$1" SSL_COUNTRY "$2"; shift;;
        --ssl-email) set_value "$1" SSL_EMAIL "$2"; shift;;
        --ssl-password) set_value "$1" SSL_PASSWORD "$2"; shift;;
        --ssl-cname) SSL_CNAME_PARSED[CNAME_INDEX++]="--set-cname=$2"; shift;;
        --install-monitoring) set_value "$1" INSTALL_MONITORING "${2:-Y}"; shift;;
        --enable-scout) ENABLE_SCOUT="${2:-1}"; shift;;
        --monitoring-parent) set_value "$1" MONITORING_PARENT "$2"; shift;;
        --monitoring-parent-ip) set_value "$1" MONITORING_PARENT_IP "$2"; shift;;
        --populate-config-channel) POPULATE_CONFIG_CHANNEL="${2:-Y}"; shift;;
        --start-services) START_SERVICES="${2:-Y}"; shift;;
        --rhn-user) set_value "$1" RHN_USER "$2"; shift;;
        --rhn-password) set_value "$1" RHN_PASSWORD "$2"; shift;;
        --) shift;
            if [ $# -gt 0 ] ; then
                echo "Error: Extra arguments found: $@"
                print_help
                exit 1
            fi
            break;;
        *) echo Error: Invalid option $1; exit 1;;
    esac
    shift
done

# params dep check
if [[ $INTERACTIVE == 0 \
    && ( -z $POPULATE_CONFIG_CHANNEL || $( yes_no $POPULATE_CONFIG_CHANNEL ) == 1 ) \
    && ( -z  $RHN_USER || -z $RHN_PASSWORD ) ]]; then
        echo "Error: When --populate-config-channel is set to Yes both --rhn-user and --rhn-password have to be provided."
        exit 1
fi

if [[ $INTERACTIVE == 0 && -z $ANSWER_FILE ]]; then
    echo "Option --non-interactive is for use only with option --answer-file."
    exit 1
fi

ACCUMULATED_ANSWERS=""

generate_answers() {
    if [ "$INTERACTIVE" = 1 -a ! -z "$ACCUMULATED_ANSWERS" ]; then
        local WRITE_ANSWERS
        echo "There were some answers you had to enter manually."
        echo "Would you like to have written those into file"
        echo -n "formatted as answers file? [Y/n]: "
        read WRITE_ANSWERS
        WRITE_ANSWERS=$(yes_no ${WRITE_ANSWERS:-Y})
        if [ "$WRITE_ANSWERS" = 1 ]; then
            local tmp=$(mktemp proxy-answers.txt.XXXXX)
            echo "Writing $tmp"
            echo "# Answer file generated by ${0##*/} at $(date)$ACCUMULATED_ANSWERS" > $tmp
        fi
    fi
}

default_or_input() {
    local MSG="$1"
    local VARIABLE="$2"
    local DEFAULT="$3"

    local INPUT
    local CURRENT_VALUE=${!VARIABLE}
    #in following code is used not so common expansion
    #var_a=${var_b:-word}
    #which is like: var_a = $var_b ? word
    DEFAULT=${CURRENT_VALUE:-$DEFAULT}
    local VARIABLE_ISSET=$(set | grep "^$VARIABLE=")

    echo -n "$MSG [$DEFAULT]: "
    if [ "$INTERACTIVE" = "1" -a  -z "$VARIABLE_ISSET" ]; then
        read INPUT
        ACCUMULATED_ANSWERS+=$(printf "\n%q=%q" "$VARIABLE" "${INPUT:-$DEFAULT}")
    elif [ -z "$VARIABLE_ISSET" ]; then
        echo "$DEFAULT"
    else
        DEFAULT=${!VARIABLE}
        echo "$DEFAULT"
    fi
    if [ -z "$INPUT" ]; then
        INPUT="$DEFAULT"
    fi
    eval "$(printf "%q=%q" "$VARIABLE" "$INPUT")"
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

config_error() {
    if [ $1 -gt 0 ]; then
        echo "$2 Installation interrupted."
        /usr/bin/rhn-proxy-activate \
            --server="$RHN_PARENT" \
            --http-proxy="$HTTP_PROXY" \
            --http-proxy-username="$HTTP_USERNAME" \
            --http-proxy-password="$HTTP_PASSWORD" \
            --ca-cert="$CA_CHAIN" \
            --deactivate --non-interactive
        generate_answers
        exit $1
    fi
}

# Return 0 if rhnParent is Hosted. Otherwise return 1.
is_hosted() {
    [ "$1" = "xmlrpc.rhn.redhat.com" -o \
        $( PYTHONPATH='/usr/share/rhn' python -c "from up2date_client import config; cfg = config.initUp2dateConfig(); print  '$1' in cfg['hostedWhitelist']" ) = "True" ]
    return $?
}

check_ca_conf() {
    if [ -f /root/ssl-build/rhn-ca-openssl.cnf ] \
        && awk '/^[[:space:]]*\[[[:space:]]*[_[:alnum:]]*[[:space:]]*]/ {CORRECT_SECTION=0} \
        /^[[:space:]]*\[[[:space:]]*CA_default[[:space:]]*]/ {CORRECT_SECTION=1} \
        /^[[:space:]]*copy_extensions[[:space:]]*=[[:space:]]*copy/ && CORRECT_SECTION==1 {exit 1}' \
        /root/ssl-build/rhn-ca-openssl.cnf > /dev/null \
            && [ ${#SSL_CNAME_PARSED[@]} -gt 0 ]; then
            cat <<WARNING
It seems you tried to use the --set-cname option. On inspection we noticed that the openssl configuration file we use is missing a critically important option. Without this option, not only will multi host SSL certificates not work, but the planet Earth will implode in a massive rip in the time/space continuum. To avoid this failure, we choose to gracefully exit here and request for you to edit the openssl configuration file
 /root/ssl-build/rhn-ca-openssl.cnf
and add this line:
 copy_extensions = copy
in
 [ CA_default ]
section.
Then re-run this script again.
WARNING
            generate_answers
            exit 3
    fi
}

YUM="yum install"
UPGRADE="yum upgrade"
# add -y for non-interactive installation
if [ "$INTERACTIVE" = "0" ]; then
    YUM="$YUM -y"
    UPGRADE="$UPGRADE -y"
fi
SYSCONFIG_DIR=/etc/sysconfig/rhn
RHNCONF_DIR=/etc/rhn
HTTPDCONF_DIR=/etc/httpd/conf
HTTPDCONFD_DIR=/etc/httpd/conf.d
HTMLPUB_DIR=/var/www/html/pub
JABBERD_DIR=/etc/jabberd
SQUID_DIR=/etc/squid
SYSTEMID_PATH=`PYTHONPATH='/usr/share/rhn' python -c "from up2date_client import config; cfg = config.initUp2dateConfig(); print cfg['systemIdPath'] "`

if [ ! -r $SYSTEMID_PATH ]; then
    echo ERROR: Spacewalk Proxy does not appear to be registered
    exit 2
fi

SYSTEM_ID=$(/usr/bin/xsltproc /usr/share/rhn/get_system_id.xslt $SYSTEMID_PATH | cut -d- -f2)

DIR=/usr/share/doc/proxy/conf-template
HOSTNAME=$(hostname)

FORCE_OWN_CA=$(yes_no $FORCE_OWN_CA)

SSL_BUILD_DIR=${SSL_BUILD_DIR:-/root/ssl-build}
if ! [ -d $SSL_BUILD_DIR ] && [ 0$FORCE_OWN_CA -eq 0 ]; then
    echo "Error: ssl build directory $SSL_BUILD_DIR does not exist. Please create this directory."
    exit 1
fi

UP2DATE_FILE=$SYSCONFIG_DIR/up2date
RHN_PARENT=$(awk -F= '/serverURL=/ {split($2, a, "/")} END {print a[3]}' $UP2DATE_FILE)
echo "Using RHN parent (from $UP2DATE_FILE): $RHN_PARENT"

if [ "$RHN_PARENT" == "rhn.redhat.com" ]; then
   RHN_PARENT="xmlrpc.rhn.redhat.com"
   cat <<WARNING
*** Warning: plain rhn.redhat.com should not be used as RHN Parent.
*** Using xmlrpc.rhn.redhat.com instead.
WARNING
fi

CA_CHAIN=$(awk -F'[=;]' '/sslCACert=/ {a=$2} END {print a}' $UP2DATE_FILE)
echo "Using CA Chain (from $UP2DATE_FILE): $CA_CHAIN"

if [ 0$FORCE_OWN_CA -eq 0 ] && \
    ! is_hosted "$RHN_PARENT" && \
    [ ! -f /root/ssl-build/RHN-ORG-PRIVATE-SSL-KEY ] && \
    ! diff $CA_CHAIN /root/ssl-build/RHN-ORG-TRUSTED-SSL-KEY &>/dev/null; then
        cat <<CA_KEYS
Please do copy your CA key and public certificate from $RHN_PARENT to
/root/ssl-build directory. You may want to execute this command:
 scp 'root@$RHN_PARENT:/root/ssl-build/{RHN-ORG-PRIVATE-SSL-KEY,RHN-ORG-TRUSTED-SSL-CERT,rhn-ca-openssl.cnf}' $SSL_BUILD_DIR
CA_KEYS
        exit 1
fi

check_ca_conf

if ! /sbin/runuser nobody -s /bin/sh --command="[ -r $CA_CHAIN ]" ; then
    echo Error: File $CA_CHAIN is not readable by nobody user.
    exit 1
fi

default_or_input "HTTP Proxy" HTTP_PROXY ''

if [ "$HTTP_PROXY" != "" ]; then

    default_or_input "HTTP username" HTTP_USERNAME ''

    if [ "$HTTP_USERNAME" != "" ]; then
        default_or_input "HTTP password" HTTP_PASSWORD ''
    fi
fi

VERSION_FROM_PARENT=$(rhn-proxy-activate --server=$RHN_PARENT \
        --http-proxy="$HTTP_PROXY" \
        --http-proxy-username="$HTTP_USERNAME" \
        --http-proxy-password="$HTTP_PASSWORD" \
        --ca-cert="$CA_CHAIN" \
        --list-available-versions 2>/dev/null|sort|tail -n1)
VERSION_FROM_RPM=$(rpm -q --queryformat %{version} spacewalk-proxy-installer|cut -d. -f1-2)
default_or_input "Proxy version to activate" VERSION ${VERSION_FROM_PARENT:-$VERSION_FROM_RPM}

default_or_input "Traceback email" TRACEBACK_EMAIL ''

default_or_input "Use SSL" USE_SSL 'Y/n'
USE_SSL=$(yes_no $USE_SSL)


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

if [ ${#SSL_CNAME_PARSED[@]} -eq 0 ]; then
    VARIABLE_ISSET=$(set | grep "^SSL_CNAME=")
    if [ -z $VARIABLE_ISSET ]; then
        default_or_input "Cname aliases (separated by space)" SSL_CNAME_ASK ''
        CNAME=($SSL_CNAME_ASK)
        for ALIAS in ${CNAME[@]}; do
            SSL_CNAME_PARSED[CNAME_INDEX++]=--set-cname=$ALIAS
        done
        check_ca_conf
    fi
fi

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

if [ -x /usr/sbin/rhn-proxy ]; then
    /usr/sbin/rhn-proxy stop
fi

$YUM spacewalk-proxy-management
# check if package install successfully
rpm -q spacewalk-proxy-management >/dev/null
if [ $? -ne 0 ]; then
    config_error 2 "Installation of package spacewalk-proxy-management failed."
fi
$UPGRADE

if is_hosted "$RHN_PARENT"; then
    #skip monitoring part for hosted
    MONITORING=1
    ENABLE_SCOUT=0
else
    rpm -q spacewalk-proxy-monitoring >/dev/null
    MONITORING=$?
    if [ $MONITORING -ne 0 ]; then
        echo "You do not have monitoring installed."
        echo "Do you want to install monitoring scout?"

        default_or_input "Will run '$YUM spacewalk-proxy-monitoring'." INSTALL_MONITORING 'Y/n'
        INSTALL_MONITORING=$(yes_no $INSTALL_MONITORING)
        if [ "$INSTALL_MONITORING" = "1" ]; then
            $YUM spacewalk-proxy-monitoring
            MONITORING=$?
        fi
    else
        $YUM spacewalk-proxy-monitoring
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
        RESOLVED_IP=$(/usr/bin/getent hosts $MONITORING_PARENT | cut -f1 -d' ')
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

ln -sf /etc/pki/spacewalk/jabberd/server.pem /etc/jabberd/server.pem
if [ "$VERSION" = '5.3' -o "$VERSION" = '5.2' -o "$VERSION" = '5.1' -o "$VERSION" = '5.0' ]; then
    sed -e "s/\${session.hostname}/$HOSTNAME/g" </usr/share/rhn/installer/jabberd/c2s.xml >/etc/jabberd/c2s.xml
    sed -e "s/\${session.hostname}/$HOSTNAME/g" </usr/share/rhn/installer/jabberd/sm.xml >/etc/jabberd/sm.xml
else
    /usr/bin/spacewalk-setup-jabberd --macros "hostname:$HOSTNAME"
fi

# size of squid disk cache will be 60% of free space on /var/spool/squid
# df -P give free space in kB
# * 60 / 100 is 60% of that space
# / 1024 is to get value in MB
SQUID_SIZE=$(df -P /var/spool/squid | awk '{a=$4} END {printf("%d", a * 60 / 100 / 1024)}')
SQUID_REWRITE="s|cache_dir ufs /var/spool/squid 15000 16 256|cache_dir ufs /var/spool/squid $SQUID_SIZE 16 256|g;"
SQUID_VER_MAJOR=$(squid -v | awk -F'[ .]' '/Version/ {print $4}')
if [ $SQUID_VER_MAJOR -ge 3 ] ; then
    # squid 3.X has acl 'all' built-in
    SQUID_REWRITE="$SQUID_REWRITE s/^acl all.*//;"
    # squid 3.2 and later need none instead of -1 for range_offset_limit
    SQUID_VER_MINOR=$(squid -v | awk -F'[ .]' '/Version/ {print $5}')
    if [[ $SQUID_VER_MAJOR -ge 4 || ( $SQUID_VER_MAJOR -eq 3 && $SQUID_VER_MINOR -ge 2 ) ]] ; then
        SQUID_REWRITE="$SQUID_REWRITE s/^range_offset_limit.*/range_offset_limit none/;"
    fi
fi
sed "$SQUID_REWRITE" < $DIR/squid.conf  > $SQUID_DIR/squid.conf
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
for file in $SYSTEMID_PATH $UP2DATE_FILE; do
    chown root:apache $file
    chmod 0640 $file
done

#Setup the cobbler stuff, needed to use koan through a proxy
PROTO="http";
if [ $USE_SSL -eq 1 ]; then
   PROTO="https"
fi
sed -e "s/\$PROTO/$PROTO/g" \
    -e "s/\$RHN_PARENT/$RHN_PARENT/g" < $DIR/cobbler-proxy.conf > $HTTPDCONFD_DIR/cobbler-proxy.conf


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
    ${SSL_CNAME_PARSED[@]} \
    $RHN_SSL_TOOL_PASSWORD_OPTION $RHN_SSL_TOOL_PASSWORD
config_error $? "SSL key generation failed!"

echo "Installing SSL certificate for Apache and Jabberd:"
rpm -Uv $(/usr/bin/rhn-ssl-tool --gen-server --rpm-only --dir="$SSL_BUILD_DIR" 2>/dev/null |grep noarch.rpm)

if [ -e $HTTPDCONFD_DIR/ssl.conf ]; then
    mv $HTTPDCONFD_DIR/ssl.conf $HTTPDCONFD_DIR/ssl.conf.bak
fi
sed -e "s|^SSLCertificateFile /etc/pki/tls/certs/localhost.crt$|SSLCertificateFile $HTTPDCONF_DIR/ssl.crt/server.crt|g" \
    -e "s|^SSLCertificateKeyFile /etc/pki/tls/private/localhost.key$|SSLCertificateKeyFile $HTTPDCONF_DIR/ssl.key/server.key|g" \
    -e "s|</VirtualHost>|RewriteEngine on\nRewriteOptions inherit\nSSLProxyEngine on\n</VirtualHost>|" \
    < $HTTPDCONFD_DIR/ssl.conf.bak  > $HTTPDCONFD_DIR/ssl.conf


CHANNEL_LABEL="rhn_proxy_config_$SYSTEM_ID"
default_or_input "Create and populate configuration channel $CHANNEL_LABEL?" POPULATE_CONFIG_CHANNEL 'Y/n'
POPULATE_CONFIG_CHANNEL=$(yes_no $POPULATE_CONFIG_CHANNEL)
if [ "$POPULATE_CONFIG_CHANNEL" = "1" ]; then
    RHNCFG_STATUS=1
    default_or_input "RHN username:" RHN_USER ''
    while [ $RHNCFG_STATUS != 0 ] ; do
        CONFIG_CHANNELS=$(rhncfg-manager list-channels ${RHN_USER:+--username="${RHN_USER}"} ${RHN_PASSWORD:+--password="${RHN_PASSWORD}"} --server-name="$RHN_PARENT")
        RHNCFG_STATUS=$?
        # In case of incorrect username/password, we want to re-ask user
        unset RHN_USER
        unset RHN_PASSWORD
    done
    if ! grep -q -E "^ +$CHANNEL_LABEL$" <<<"$CONFIG_CHANNELS" ; then
        rhncfg-manager create-channel --server-name "$RHN_PARENT" "$CHANNEL_LABEL"
    fi
    rhncfg-manager update --server-name "$RHN_PARENT" \
        --channel="$CHANNEL_LABEL" \
        $HTTPDCONFD_DIR/ssl.conf \
        $RHNCONF_DIR/rhn.conf \
        $RHNCONF_DIR/cluster.ini \
        $SQUID_DIR/squid.conf \
        $HTTPDCONFD_DIR/cobbler-proxy.conf \
        $HTTPDCONF_DIR/httpd.conf \
        $JABBERD_DIR/c2s.xml \
        $JABBERD_DIR/sm.xml
fi

echo "Enabling Spacewalk Proxy."
if [ $ENABLE_SCOUT -ne 0 ]; then
    MonitoringScout="MonitoringScout"
fi
for service in squid httpd jabberd $MonitoringScout; do
    if [ -x /usr/bin/systemctl ] ; then
        /usr/bin/systemctl enable $service
    else
        /sbin/chkconfig --add $service
        /sbin/chkconfig --level 345 $service on
    fi
done

# default is 1
START_SERVICES=$(yes_no ${START_SERVICES:-1})
if [ "$START_SERVICES" = "1" ]; then
    /usr/sbin/rhn-proxy restart
else
    echo Skipping start of services.
    echo Use "/usr/sbin/rhn-proxy start" to manualy start proxy.
fi

generate_answers
