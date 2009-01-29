#!/bin/bash

TAGS=([0]="dist-5E-sw-0.5-candidate" [1]="dist-f10-sw-0.5-candidate")
DISTS=([0]='.el5' [1]='.f10')

pushd `pwd`

cd `dirname $0`/..

for tag in 0 1; do
  rel-eng/koji-missing-builds.py ${TAGS[$tag]} | \
	  awk '!/buildsys-macros/ {
                 if (x==1) { print gensub(" *([a-zA-Z_-]+)-.*", "\\1", "g")}
                 }
             /Builds missing in koji/ { x=1 }' | \
	  xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring | \
        while read package ; do
          (
            echo Building $package for ${TAGS[$tag]}
            cd $package && make srpm DIST=${DISTS[$tag]} | \
            awk '/Wrote:/ {print $2}' | \
            xargs -I packagepath koji -c ~/.koji/spacewalk-config build ${TAGS[$tag]} packagepath
            make upload-tgz
          )
        done
done

popd
