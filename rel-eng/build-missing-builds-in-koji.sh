#!/bin/bash

TAGS=([0]="dist-5E-sw-0.9-candidate" [1]="dist-f11-sw-0.9-candidate" [2]="dist-f12-sw-0.9-candidate")

pushd `pwd`

cd `dirname $0`/..

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

for tag in 0 1 2; do
  rel-eng/koji-missing-builds.py --no-extra ${TAGS[$tag]} | \
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
      cd $package && ${TITO_PATH}tito build --koji-release | \
      awk '/Wrote:.*tar.gz/ {print $2}' | \
      xargs -I packagepath scp packagepath fedorahosted.org:spacewalk
    )
done

popd
