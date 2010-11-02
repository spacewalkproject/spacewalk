#!/bin/bash

dirs=(
backend/po
client/rhel/rhnsd/po
client/rhel/yum-rhn-plugin/po
client/rhel/rhn-client-tools/po
)

if [ $# -lt 1 ]
then
    echo "Usage: `basename $0` {lang}"
    exit 9
fi

for lang in "$@"
do
    langshort=${lang:0:2}
    for dir in "${dirs[@]}"
    do
        # po2txt does not go well with stdin mode (temp must be used)
        tempfile=$(mktemp --suffix -spellcheck.po)
        filename="../../$dir/$lang.po"
        if [ -f "$filename" ]; then
            echo "$(tput bold)$lang in $dir:$(tput sgr0) "
            # remove untranslated strings (put a dummy space in it)
            cat "$filename" | sed 's/^msgstr ""/msgstr " "/g' | sed -r 's/_//g' > "$tempfile"
            po2txt --progress=none --nofuzzy "$tempfile" | \
            aspell list -l $lang -p $(pwd)/ignored_$langshort.txt --ignore=3 --encoding=utf-8 | \
            sort -u
            rm "$tempfile"
        fi
    done
done
