#!/bin/bash

set -e

OPTS=$(getopt --longoptions=db: -n ${0##*/} -- d: "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true ; do
    case "$1" in
        -d|--db)
            PGNAME=$2
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error [$1]!" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$PGNAME" ] ; then
    echo "usage: $(basename $0) --db <database_name>" >&2
    exit 1
fi

runuser - postgres -c "dropdb $PGNAME"
