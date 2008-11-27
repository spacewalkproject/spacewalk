#!/bin/bash

TAG=dist-5E-sw-0.4-candidate
pushd `pwd`

BASENAME=`basename $0`
cd `echo $0 | sed s/$BASENAME//`/..;

for package in ` \
	rel-eng/koji-missing-builds.pl $TAG | \
	awk '!/buildsys-macros/ { if (x==1) { print gensub(" *([a-zA-Z_-]+)-.*", "\\1 ", "g")} }
             /Builds missing in koji/ { x=1 }' | \
	xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring `; do
  ( cd $package && make srpm DIST='.el5' | \
    awk '/Wrote:/ {print $2}' | \
    xargs -I packagepath koji -c ~/.koji/spacewalk-config build $TAG packagepath; )
done

popd
