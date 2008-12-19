#!/bin/bash

TAG=satellite-5E-5.3-candidate
pushd `pwd`

cd `dirname $0`/..

rel-eng/brew-missing-builds.pl $TAG | \
	awk '!/buildsys-macros/ {
                 if (x==1) { print gensub(" *([a-zA-Z_-]+)-.*", "\\1", "g")}
                 }
             /Builds missing in brew/ { x=1 }' | \
	xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring | \
        while read package ; do
          (
            cd $package && make srpm DIST='.el5' | \
            awk '/Wrote:/ {print $2}' | \
            xargs -I packagepath brew build $TAG packagepath
          )
done

popd
