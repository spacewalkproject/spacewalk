#!/bin/bash

dirs=(
java/code/src/com/redhat/rhn/frontend/strings/database
java/code/src/com/redhat/rhn/frontend/strings/java
java/code/src/com/redhat/rhn/frontend/strings/jsp
java/code/src/com/redhat/rhn/frontend/strings/nav
java/code/src/com/redhat/rhn/frontend/strings/template
)

for lang in "${langs[@]}"
do
	for dir in "${dirs[@]}"
	do
		if [ "$lang" = "en_US" ]; then
			xslt=onlySource.xslt
		else
			xslt=onlyTarget.xslt
		fi
		dirbase=$(basename "$dir")
		echo "Spell check result for $lang in $dirbase"
		xsltproc $xslt ../../$dir/StringResource_$lang.xml | \
		aspell list -l $lang -p $(pwd)/ignored_$lang.txt --ignore=3 --encoding=utf-8 | \
		sort -u
	done
done
