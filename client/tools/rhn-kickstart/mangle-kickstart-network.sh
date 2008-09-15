#!/bin/sh
unset LANG

unset PATH
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

KS=$1
DEVICE=$2

fatal() {
    err=$1; shift; echo "$*"; exit $err
}
usage() {
    fatal 1 "Usage: $0 DEVICE KSFILE"
}

[ -f "$KS" -a -n "$DEVICE" ] || usage

# auto means figure out what the default gw uses
if [ "$DEVICE" = "auto" ]; then
    DEVICE=$(route -n | grep '^0.0.0.0' | perl -lane 'print $F[7]')
fi

# test that the device, you know, exists
(ifconfig $DEVICE &> /dev/null) || fatal 2 "Network device $DEVICE does not seem to exist."

# okay.  now we rifle through ifconfig to figure out the necessary components
IPADDR=$(ifconfig $DEVICE | perl -lne '/inet addr:([\d.]+)/ and print $1')
NETMASK=$(ifconfig $DEVICE | perl -lne '/Mask:([\d.]+)/ and print $1')
GATEWAY=$(route -n | grep '^0.0.0.0' | perl -lane 'print $F[1]')
HOSTNAME=$(hostname)
#NAMESERVER=$(cat /etc/resolv.conf | perl -lne '/^nameserver\s+(\S+)$/ and print $1' | head -1)
# bug 156123 - check for something other than a local caching nameserver
for n in $(cat /etc/resolv.conf | perl -lne '/^nameserver\s+(\S+)$/ and print $1'); do
    if [ "$n" != "127.0.0.1" ]; then
        NAMESERVER=$n
        break
    fi
done

# that's it.  now we replace the current network --bootproto line in
# the kickstart and we're done
perl -p -i.back - $KS <<EOF
s(^network.*--bootproto.*)(network --bootproto static --device $DEVICE --ip $IPADDR --gateway $GATEWAY --nameserver $NAMESERVER --netmask $NETMASK --hostname $HOSTNAME)
EOF
