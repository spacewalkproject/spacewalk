#!/bin/bash

# TAGS=([0]="satellite-5.4-rhel-5-candidate" [1]="satellite-5.4-rhel-6-candidate")
TAGS=([0]="satellite-5.4-rhel-5-candidate")

pushd `pwd`

cd `dirname $0`/..

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

for tag in 0 ; do
  rel-eng/koji-missing-builds.py --brew --no-extra ${TAGS[$tag]} | \
    awk '!(/buildsys-macros/ || /oracle-server-admin/ || /oracle-server-scripts/ || /heirloom-pkgtools/) {
                 if (x==1) { print gensub(" *([a-zA-Z_-]+)-.*", "\\1", "g")}
                 }
             /Builds missing in koji/ { x=1 }' | \
	  xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring | \
        grep -v solaris
done | sort | uniq | \
while read package ; do
    (
      echo Building package in path $package
      cd $package && ${TITO_PATH}tito build --cvs-release | \
          awk '/Wrote:.*tar.gz/ {print $2}'
    )
done

popd
