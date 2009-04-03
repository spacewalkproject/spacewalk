#!/bin/bash

TAGS=([0]="dist-5E-sw-0.6-candidate" [1]="dist-f10-sw-0.6-candidate")

pushd `pwd`

cd `dirname $0`/..

for tag in 0 1; do
  rel-eng/koji-missing-builds.py --no-extra ${TAGS[$tag]} | \
    grep -v oracle-server-admin | \
    grep -v oracle-server-scripts | \
	  awk '!/buildsys-macros/ {
                 if (x==1) { print gensub(" *([a-zA-Z_-]+)-.*", "\\1", "g")}
                 }
             /Builds missing in koji/ { x=1 }' | \
	  xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring | \
        while read package ; do
          (
            echo Building package in path $package 
            cd $package && ${TITO_PATH}tito build --koji-release | \
            awk '/Wrote:.*tar.gz/ {print $2}' | \
            xargs -I packagepath scp packagepath fedorahosted.org:spacewalk
          )
        done
done

popd
