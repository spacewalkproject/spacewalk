#!/bin/bash

TAG=dist-5E-sw-0.5-candidate
pushd `pwd`

cd `dirname $0`/..

rel-eng/koji-missing-builds.py $TAG | \
	awk '!/buildsys-macros/ {
                 if (x==1) { print gensub(" *([a-zA-Z_-]+)-.*", "\\1", "g")}
                 }
             /Builds missing in koji/ { x=1 }' | \
	xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring | \
        while read package ; do
          (
            echo Building $package
            cd $package && make srpm DIST='.el5' | \
            awk '/Wrote:/ {print $2}' | \
            xargs -I packagepath koji -c ~/.koji/spacewalk-config build $TAG packagepath
            make upload-tgz
          )
done

popd
