#! /bin/bash

IDENTITY="/var/lib/nocpulse/.ssh/nocpulse-identity"
if [ ! -f "$IDENTITY" ]
then
        /bin/su -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f $IDENTITY" - nocpulse
        if [ ! -e "/var/lib/nocpulse/.bashrc" ]; then
                echo 'LANG="C"' > /var/lib/nocpulse/.bashrc
        fi
fi
