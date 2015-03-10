#!/bin/bash

if [ -z "${ZANATA_BACKEND}" ];then
    for cmd in zanata-cli mvn ; do
	if which $cmd 2>/dev/null; then
	    ZANATA_BACKEND=`which $cmd`
	    break
	fi
    done
fi

if [ -z "${ZANATA_BACKEND}" ];then
    cat >/dev/stderr <<END
Please install either:
   zanata-client
   mvn
   exit 2
END
fi

if [[ ${ZANATA_BACKEND} =~ zanata-cli$ ]]; then
    ${ZANATA_BACKEND} -e -B push --disable-ssl-cert --project-config zanata-frontend.xml "$@"
    ${ZANATA_BACKEND} -e -B push --disable-ssl-cert --project-config zanata-other.xml "$@"
elif [[ ${ZANATA_BACKEND} =~ mvn$ ]]; then
    ${ZANATA_BACKEND} -e -B org.zanata:zanata-maven-plugin:push -Dzanata.disableSSlCert -Dzanata.projectConfig=zanata-frontend.xml "$@"
    ${ZANATA_BACKEND} -e -B org.zanata:zanata-maven-plugin:push -Dzanata.disableSSlCert -Dzanata.projectConfig=zanata-other.xml "$@"
fi

