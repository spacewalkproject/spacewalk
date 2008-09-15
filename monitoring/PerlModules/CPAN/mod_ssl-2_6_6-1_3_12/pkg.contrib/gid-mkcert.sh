#!/bin/sh
##
##  gid-mkcert.sh -- Create Certificates for Global Server ID facility
##  Copyright (c) 1998-2000 Ralf S. Engelschall, All Rights Reserved. 
##
##  This script is derived from mkcert.sh from the mod_ssl distribution.
##  It requires OpenSSL 0.9.4.
##

#   parameters
openssl="openssl"
sslcrtdir="."
sslcsrdir="."
sslkeydir="."

#   some optional terminal sequences
case $TERM in
    xterm|xterm*|vt220|vt220*)
        T_MD=`echo dummy | awk '{ printf("%c%c%c%c", 27, 91, 49, 109); }'`
        T_ME=`echo dummy | awk '{ printf("%c%c%c", 27, 91, 109); }'`
        ;;
    vt100|vt100*)
        T_MD=`echo dummy | awk '{ printf("%c%c%c%c%c%c", 27, 91, 49, 109, 0, 0); }'`
        T_ME=`echo dummy | awk '{ printf("%c%c%c%c%c", 27, 91, 109, 0, 0); }'`
        ;;
    default)
        T_MD=''
        T_ME=''
        ;;
esac

#   find some random files
#   (do not use /dev/random here, because this device 
#   doesn't work as expected on all platforms)
randfiles=''
for file in /var/log/messages /var/adm/messages \
            /kernel /vmunix /vmlinuz \
            /etc/hosts /etc/resolv.conf; do
    if [ -f $file ]; then
        if [ ".$randfiles" = . ]; then
            randfiles="$file"
        else
            randfiles="${randfiles}:$file"
        fi
    fi
done

echo "${T_MD}This is GID-MKCERT (Global Server ID Generation)${T_ME}"
echo "${T_MD}Copyright (c) 1998-2000 Ralf S. Engelschall, All Rights Reserved.${T_ME}"

if [ ! -f $sslcrtdir/ca.crt ]; then
    echo ""
    echo "${T_MD}Generating custom Certificate Authority (CA)${T_ME}"
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 1: Generating RSA private key for CA (1024 bit)${T_ME}"
    if [ ! -f $HOME/.rnd ]; then
        touch $HOME/.rnd
    fi
    if [ ".$randfiles" != . ]; then
        $openssl genrsa -rand $randfiles \
                        -out $sslkeydir/ca.key \
                        1024
    else
        $openssl genrsa -out $sslkeydir/ca.key \
                        1024
    fi
    if [ $? -ne 0 ]; then
        echo "gid-mkcert.sh:Error: Failed to generate RSA private key" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 2: Generating X.509 certificate signing request for CA${T_ME}"
    cat >.mkcert.cfg <<EOT
[ req ]
default_bits                    = 1024
distinguished_name              = req_DN
[ req_DN ]
countryName                     = "1. Country Name             (2 letter code)"
countryName_default             = XY
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = "2. State or Province Name   (full name)    "
stateOrProvinceName_default     = Snake Desert
localityName                    = "3. Locality Name            (eg, city)     "
localityName_default            = Snake Town
0.organizationName              = "4. Organization Name        (eg, company)  "
0.organizationName_default      = Snake Oil, Ltd
organizationalUnitName          = "5. Organizational Unit Name (eg, section)  "
organizationalUnitName_default  = Certificate Authority
commonName                      = "6. Common Name              (eg, CA name)  "
commonName_max                  = 64
commonName_default              = Snake Oil CA
emailAddress                    = "7. Email Address            (eg, name@FQDN)"
emailAddress_max                = 40
emailAddress_default            = ca@snakeoil.dom
EOT
    $openssl req -config .mkcert.cfg \
                 -new \
                 -key $sslkeydir/ca.key \
                 -out $sslcsrdir/ca.csr
    if [ $? -ne 0 ]; then
        echo "gid-mkcert.sh:Error: Failed to generate certificate signing request" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 3: Generating X.509 certificate for CA signed by itself${T_ME}"
    cat >.mkcert.cfg <<EOT
extensions = x509v3
[ x509v3 ]
subjectAltName   = email:copy
basicConstraints = CA:true,pathlen:0
nsComment        = "mod_ssl generated custom CA certificate"
nsCertType       = sslCA
EOT
    $openssl x509 -extfile .mkcert.cfg \
                  -days 365 \
                  -signkey $sslkeydir/ca.key \
                  -in  $sslcsrdir/ca.csr -req \
                  -out $sslcrtdir/ca.crt
    if [ $? -ne 0 ]; then
        echo "gid-mkcert.sh:Error: Failed to generate self-signed CA certificate" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}RESULT:${T_ME}"
    $openssl verify $sslcrtdir/ca.crt
    if [ $? -ne 0 ]; then
        echo "gid-mkcert.sh:Error: Failed to verify resulting X.509 certificate" 1>&2
        exit 1
    fi
fi

echo ""
echo "${T_MD}Generating custom SERVER${T_ME}"
echo "______________________________________________________________________"
echo ""
echo "${T_MD}STEP 5: Generating RSA private key for SERVER (1024 bit)${T_ME}"
if [ ! -f $HOME/.rnd ]; then
    touch $HOME/.rnd
fi
if [ ".$randfiles" != . ]; then
    $openssl genrsa -rand $randfiles \
                    -out $sslkeydir/server.key \
                    1024
else
    $openssl genrsa -out $sslkeydir/server.key \
                    1024
fi
if [ $? -ne 0 ]; then
    echo "gid-mkcert.sh:Error: Failed to generate RSA private key" 1>&2
    exit 1
fi
echo "______________________________________________________________________"
echo ""
echo "${T_MD}STEP 6: Generating X.509 certificate signing request for SERVER${T_ME}"
cat >.mkcert.cfg <<EOT
[ req ]
default_bits                    = 1024
distinguished_name              = req_DN
[ req_DN ]
countryName                     = "1. Country Name             (2 letter code)"
countryName_default             = XY
countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = "2. State or Province Name   (full name)    "
stateOrProvinceName_default     = Snake Desert
localityName                    = "3. Locality Name            (eg, city)     "
localityName_default            = Snake Town
0.organizationName              = "4. Organization Name        (eg, company)  "
0.organizationName_default      = Snake Oil, Ltd
organizationalUnitName          = "5. Organizational Unit Name (eg, section)  "
organizationalUnitName_default  = Webserver Team
commonName                      = "6. Common Name              (eg, FQDN)     "
commonName_max                  = 64
commonName_default              = www.snakeoil.dom
emailAddress                    = "7. Email Address            (eg, name@fqdn)"
emailAddress_max                = 40
emailAddress_default            = www@snakeoil.dom
EOT
$openssl req -config .mkcert.cfg \
             -new \
             -key $sslkeydir/server.key \
             -out $sslcsrdir/server.csr
if [ $? -ne 0 ]; then
    echo "gid-mkcert.sh:Error: Failed to generate certificate signing request" 1>&2
    exit 1
fi
echo "______________________________________________________________________"
echo ""
echo "${T_MD}STEP 7: Generating X.509 certificate signed by own CA${T_ME}"
cat >.mkcert.cfg <<EOT
extensions = x509v3
[ x509v3 ]
subjectAltName    = email:copy
basicConstraints  = pathlen:0
nsComment         = "mod_ssl generated custom server certificate"
nsCertType        = server
#extendedKeyUsage = RID:2.16.840.1.113730.4.1,RID:1.3.6.1.4.1.311.10.3.3
extendedKeyUsage  = msSGC,nsSGC
EOT
if [ ! -f .mkcert.serial ]; then
    echo '01' >.mkcert.serial
fi
$openssl x509 -extfile .mkcert.cfg \
              -days 365 \
              -CAserial .mkcert.serial \
              -CA $sslcrtdir/ca.crt \
              -CAkey $sslkeydir/ca.key \
              -in $sslcsrdir/server.csr -req \
              -out $sslcrtdir/server.crt
if [ $? -ne 0 ]; then
    echo "gid-mkcert.sh:Error: Failed to generate X.509 certificate" 1>&2
    exit 1
fi
caname="`$openssl x509 -noout -text -in $sslcrtdir/ca.crt |\
         grep Subject: | sed -e 's;.*CN=;;' -e 's;/Em.*;;'`"
username="`$openssl x509 -noout -text -in $sslcrtdir/server.crt |\
            grep Subject: | sed -e 's;.*CN=;;' -e 's;/Em.*;;'`"
$openssl pkcs12 \
    -export \
    -in $sslcrtdir/server.crt \
    -inkey $sslkeydir/server.key \
    -certfile $sslcrtdir/ca.crt \
    -name "$username" \
    -caname "$caname" \
    -out $sslcrtdir/server.p12
echo "______________________________________________________________________"
echo ""
echo "${T_MD}RESULT:${T_ME}"
$openssl verify -CAfile $sslcrtdir/ca.crt $sslcrtdir/server.crt
if [ $? -ne 0 ]; then
    echo "gid-mkcert.sh:Error: Failed to verify resulting X.509 certificate" 1>&2
    exit 1
fi
echo "______________________________________________________________________"
echo ""
echo "${T_MD}STEP 8: Enrypting RSA private key of SERVER with a pass phrase for security${T_ME}"
$openssl rsa -des3 -in $sslkeydir/server.key -out $sslkeydir/server.key.crypt
if [ $? -ne 0 ]; then
    echo "gid-mkcert.sh:Error: Failed to encrypt RSA private key" 1>&2
    exit 1
fi
cp $sslkeydir/server.key.crypt $sslkeydir/server.key
rm -f $sslkeydir/server.key.crypt

##EOF##
