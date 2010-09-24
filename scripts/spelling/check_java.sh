#!/bin/bash

dirs=(
java/code/src/com/redhat/rhn/frontend/strings/database
java/code/src/com/redhat/rhn/frontend/strings/java
java/code/src/com/redhat/rhn/frontend/strings/jsp
java/code/src/com/redhat/rhn/frontend/strings/nav
java/code/src/com/redhat/rhn/frontend/strings/template
)

if [ $# -lt 1 ]
then
	echo "Usage: `basename $0` {lang}"
	exit 9
fi

for lang in "$@"
do
	echo $lang
	for dir in "${dirs[@]}"
	do
		if [ "$lang" = "en_US" ]; then
			xslt=onlySource.xslt
		else
			xslt=onlyTarget.xslt
		fi
		dirbase=$(basename "$dir")
		filename="../../$dir/StringResource_$lang.xml"
		if [ -f "$filename" ]; then
			echo "$(tput bold)$lang in $dir:$(tput sgr0) "
			xsltproc $xslt ../../$dir/StringResource_$lang.xml | \
			aspell list -l $lang -p $(pwd)/ignored_$lang.txt --ignore=3 --encoding=utf-8 | \
			sort -u
		fi
	done
done
