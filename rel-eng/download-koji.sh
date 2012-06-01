#!/bin/sh

KOJI=$(echo "$1" | sed 's,\(https*://.*\)/[^/]*$,\1/,')
WGET='wget --no-check-certificate -nv'

$WGET -O - $1 \
    | awk -F\" 'function basename(f) {
                        gsub(".*[/=]", "", f)
                        return f}
                />download</ && ! /src\.rpm/ {
                        print $4 " -O " basename($4)}
                /"getfile?.*\.rpm"/ && ! /src\.rpm/ {
                        print "'"$KOJI"'" $2 " -O " basename($2)}
                /"http:\/\/download.*\.rpm/ && ! /src\.rpm/ {
                        print $2 " -O " basename($2)} ' \
    | xargs -n 3 $WGET
