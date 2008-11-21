#!/bin/bash

TAG=dist-5E-sw-0.4-candidate
pushd `pwd`

BASENAME=`basename $0`
cd `echo $0 | sed s/$BASENAME//`/..;

for package in ` \
	rel-eng/koji-missing-builds.pl $TAG | \
	awk '{ if (x==1) { print } } /Builds missing in koji/ { x=1 }' | \
	sed '1,$s/\s*\([a-zA-Z_-]*\)-.*/\1/' | \
	xargs -I replacestring cat rel-eng/packages/replacestring |cut -f2 -d' '`; do 
  ( cd $package && make srpm DIST='.el5' \
    | tail -n1 | cut -f2 -d' ' | \
    xargs -I packagepath koji -c ~/.koji/spacewalk-config build $TAG packagepath; ) 
done

popd
