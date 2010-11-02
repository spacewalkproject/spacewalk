#!/bin/bash

dirs=(
java/code/src/com/redhat/rhn/frontend/strings/database
java/code/src/com/redhat/rhn/frontend/strings/java
java/code/src/com/redhat/rhn/frontend/strings/jsp
java/code/src/com/redhat/rhn/frontend/strings/nav
java/code/src/com/redhat/rhn/frontend/strings/template
)

if [ $# -lt 2 ]
then
    echo "Usage: `basename $0` basedir {lang}"
    echo "Example: `basename $0` . en_US de fr"
    exit 9
fi

basedir=$1
scriptdir=$(dirname "$0")
logfile=$(mktemp)

for lang in "${@:2}"
do
    langshort=${lang:0:2}
    for dir in "${dirs[@]}"
    do
        if [ "$lang" = "en_US" ]; then
            xslt="$scriptdir/onlySource.xslt"
        else
            xslt="$scriptdir/onlyTarget.xslt"
        fi
        dirbase=$(basename "$dir")
        filename="$basedir/$dir/StringResource_$lang.xml"
        if [ -f "$filename" ]; then
            echo "$(tput bold)$lang in $dir:$(tput sgr0) "
            xsltproc "$xslt" "$filename" | \
            aspell list -l $lang --home-dir="$scriptdir" \
                -p "ignored_$langshort.txt" --ignore=3 --encoding=utf-8 | \
            sort -u | tee -a "$logfile"
        fi
    done
done

retcode=0
if [ -s "$logfile" -a "$lang" = "en_US" ]; then
    echo "ERROR: There are spelling errors in resources, please fix or"
    echo "add the following words in the scripts/spelling/ignore_en.txt:"
    echo "--cut--"
    cat "$logfile"
    echo "--cut--"
    retcode=1
fi

rm "$logfile";
exit $retcode;
