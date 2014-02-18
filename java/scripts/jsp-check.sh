#!/bin/bash

SCRIPTDIR=$( dirname $( readlink --canonicalize $0 ) )
SED_HELPER=$SCRIPTDIR/jsp-check-helper.sed

# Run me in Spacewalk git root...

# | xargs -n 1 bash -c "tr '\\n' ' ' < \$1 | sed -f $SED_HELPER | xmllint - >& /dev/null ; if [[ \$? -ne 0 ]]; then echo \$1; fi" --

echo "Potential problems:" >&2
git locate '*.jsp*' \
| grep 'jspf\?$' \
| while read; do
    FILE=$REPLY
    tr '\n' ' ' < "$FILE" \
    | sed -f "$SED_HELPER" \
    | xmllint - >& /dev/null
    if [[ $? -ne 0 ]]; then
        echo "$FILE"
    fi
done
