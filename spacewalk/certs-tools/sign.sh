#!/bin/bash
#
# Copyright (c) 2008--2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
#
# script that signs a certificate request with a CA key
# The script expects to find ca.key, ca.crt and server.csr in the working
# directory
# The signed certificate is saved in server.crt
# server.crt and server.key are packaged as rhn-httpd-ssl-key-pair-*.rpm
# RHN-ORG-TRUSTED-SSL-CERT (or ca.cert) is packaged as
# rhn-org-trusted-ssl-cert-*.rpm
#

TOPDIR=$(cd $(dirname $0) && pwd)

PASSWORD=
STARTDATE=
# 1 year.
EXP_DAYS=365

CA_KEY=ca.key
CA_CRT=ca.crt

SERVER_KEY=server.key
SERVER_CSR=server.csr

CLIENT_RPM_NAME="rhn-org-trusted-ssl-cert"
SERVER_RPM_NAME="rhn-httpd-ssl-key-pair"
SSL_BACKUP_TARBALL_NAME="rhn-org-ssl-backup"


usage() {
    echo "Usage:"
    echo "$0 [OPTIONS]"
    echo "Signs a server certificate request with a CA key"
    echo
    echo "  OPTIONS:"
    echo "    --help            display usage and exit"
    echo "    --topdir          path to gen-rpm.sh [$TOPDIR]"
    echo "    --password        password for the CA key [read from stdin]"
    echo "    --startdate       start date; format: YYMMDDHHMMSSZ (the letter Z)"
    echo "    --days            number of days the cert is valid"
    echo "    --ca-key          Certificate Authority private key"
    echo "    --ca-crt          Certificate Authority certificate"
    echo "    --server-key      Server (httpd) private key"
    echo "    --server-csr      Server (httpd) Certificate Signing Request"
    echo "    --server-crt      Server (httpd) Certificate"
    echo "    --ca-rpm          RPM name for the CA certificate"
    echo "                      (default: $CLIENT_RPM_NAME)"
    echo "    --server-rpm      RPM name for the server's (httpd) SSL key/cert pair"
    echo "                      (default: $SERVER_RPM_NAME)"
    echo "    --openssl-conf    Use this OpenSSL configuration file"
    echo
    exit $1
}

while [ ${#} -ne 0 ]; do
    arg="$1"
    shift
    case "$arg" in
        --help)
            usage 0
            ;;
        --topdir)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            TOPDIR="$1"
            shift;;
        --password)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            PASSWORD="$1"
            shift;;
        --startdate)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            STARTDATE="$1"
            shift;;
        --days)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            EXP_DAYS="$1"
            shift;;
        --ca-key)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            CA_KEY="$1"
            shift;;
        --ca-crt)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            CA_CRT="$1"
            shift;;
        --server-key)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            SERVER_KEY="$1"
            shift;;
        --server-csr)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            SERVER_CSR="$1"
            shift;;
        --ca-rpm)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            CLIENT_RPM_NAME="$1"
            shift;;
        --server-rpm)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            SERVER_RPM_NAME="$1"
            shift;;
        --openssl-conf)
            [ ${#} -eq 0 ] && (echo "No parameter specified for $arg" >&2; exit 1)
            OPENSSL_CONF="$1"
            shift;;
        "") break;;
        *) 
            echo "Extra parameter $1 ignored"
            shift
    esac
done

gen_openssl_conf() {
    cat > openssl.cnf << EOF
[ ca ]
default_ca      = CA_default            # The default ca section

[ CA_default ]
serial		= serial 		# The current serial number
database        = index.txt
# Commenting for now, the cert gets too big
x509_extensions = usr_cert
copy_extensions = copy

# For the CA policy
[ policy_match ]
countryName		= match
stateOrProvinceName	= optional
organizationName	= match
organizationalUnitName	= optional
commonName		= supplied
emailAddress		= optional

[ usr_cert ]
basicConstraints = CA:false
extendedKeyUsage = serverAuth,clientAuth
nsCertType = server
keyUsage = digitalSignature, keyEncipherment

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer:always
EOF
}

if [ -z "$OPENSSL_CONF" ]; then
    gen_openssl_conf
    OPENSSL_CONF=openssl.cnf
fi


# Error checking - make sure all the needed files are there
for fn in $CA_KEY $CA_CRT $SERVER_KEY $SERVER_CSR $OPENSSL_CONF; do
    if [ ! -f ${fn} ]; then
        echo "Error: Could not find required file ${fn}"
        exit 1
    fi
    if [ ! -s ${fn} ] ; then
        echo "Error: Zero-length file ${fn}"
        exit 2
    fi
done

GENRPMFILE=gen-rpm.sh
if [ ! -f $TOPDIR/$GENRPMFILE ]; then
    echo "$TOPDIR/$GENRPMFILE not found; please use --topdir"
    exit 1
fi
    
GENRPM="sh $TOPDIR/$GENRPMFILE"

[ -f serial ] || echo 01 > serial
echo -n > index.txt

[ -z $STARTDATE ] || STARTDATE="-startdate $STARTDATE"
# If we've been supplied a password on the command line, use it
if [ -n "$PASSWORD" ]; then
    /usr/bin/openssl ca -config $OPENSSL_CONF -in $SERVER_CSR -out server.crt \
        -outdir . -batch -cert $CA_CRT -keyfile $CA_KEY \
        $STARTDATE -days $EXP_DAYS -md md5 -policy policy_match \
        -passin "pass:$PASSWORD"
else
    /usr/bin/openssl ca -config $OPENSSL_CONF -in $SERVER_CSR -out server.crt \
        -outdir . -batch -cert $CA_CRT -keyfile $CA_KEY \
        $STARTDATE -days $EXP_DAYS -md md5 -policy policy_match
fi
    
if [ $? -ne 0 ]; then
    echo "Error: unable to generate server.crt"
    exit $?
fi

# Get the version and release for this package
version=`rpm -q --qf "%{version}" ${SERVER_RPM_NAME}`
# If the result code is non-zero, the package is not installed
[ $? -eq 0 ] || version="1.0"

release=`rpm -q --qf "%{release}" ${SERVER_RPM_NAME}` 
if [ $? -eq 0 ]; then
	release=`echo $release | sed "s/^\([0-9]*\).*$/\1/"`
else
        # package not installed
	release=0
fi
# Bump the release
release=$[$release+1]

PROD_NAME=`spacewalk-cfg-get get web product_name`
EMAIL=`spacewalk-cfg-get traceback_mail`
PACKAGER=$PROD_NAME$EMAIL

# Generate a postun scriptlet
cat > postun.scriptlet << EOSCRIPTLET
if [ \$1 = 0 ]; then
    # The following steps are copied from mod_ssl's postinstall scriptlet
    # Make sure the permissions are okay
    umask 077

    if [ ! -f /etc/httpd/conf/ssl.key/server.key ] ; then
        /usr/bin/openssl genrsa -rand /proc/apm:/proc/cpuinfo:/proc/dma:/proc/filesystems:/proc/interrupts:/proc/ioports:/proc/pci:/proc/rtc:/proc/uptime 1024 > /etc/httpd/conf/ssl.key/server.key 2> /dev/null
    fi

    if [ ! -f /etc/httpd/conf/ssl.crt/server.crt ] ; then
        cat << EOF | /usr/bin/openssl req -new -key /etc/httpd/conf/ssl.key/server.key -x509 -days 365 -out /etc/httpd/conf/ssl.crt/server.crt 2>/dev/null
--
SomeState
SomeCity
SomeOrganization
SomeOrganizationalUnit
localhost.localdomain
root@localhost.localdomain
EOF
    fi
    /sbin/service httpd graceful
    exit 0
fi
EOSCRIPTLET

# Package the server's cert and private key
$GENRPM --name $SERVER_RPM_NAME --version $version \
    --release $release --packager "$PACKAGER" \
    --summary "server private SSL key and certificate for the $PROD_NAME" \
    --description "server private SSL key and certificate for the $PROD_NAME" \
    --postun postun.scriptlet \
    /etc/httpd/conf/ssl.crt/server.crt=server.crt \
    /etc/httpd/conf/ssl.key/server.key:0600=${SERVER_KEY} || exit 1
chmod 0600 ${SERVER_RPM_NAME}-${version}-${release}.{src,noarch}.rpm
rm -f postun.scriptlet

# Now that we have the CA cert generated, let's package it into an rpm
$GENRPM --name ${CLIENT_RPM_NAME} --version $version \
    --release $release --packager "${PACKAGER}" \
    --summary "CA SSL certificate for the $PROD_NAME (client-side)" \
    --description "CA SSL certificate for the $PROD_NAME (client-side)" \
    /usr/share/rhn/${CA_CRT}=${CA_CRT} || exit 1

