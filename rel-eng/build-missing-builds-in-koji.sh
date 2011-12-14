#!/bin/bash


TAGS="dist-5E-sw-1.6-candidate dist-6E-sw-1.6-candidate dist-f14-sw-1.6-candidate dist-f15-sw-1.6-candidate dist-f16-sw-1.6-candidate"
FEDORA_UPLOAD=1

pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

PACKAGES=$(mktemp)
PACKAGES_TAG=$(mktemp)

#gather data
echo -n Gathering data:
for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_BREW_ARG --no-extra $tag | \
    perl -lne '/^\s+(.+)-.+-.+$/ and print $1' | \
    xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring \
    | \
    while read package ; do
      echo $package>>$PACKAGES && \
      echo $package $tag>>$PACKAGES_TAG
      echo -n .
    done
done
echo

#build packages
cat $PACKAGES_TAG | sort | \
while read package tag; do
  (
      echo Building package in path $package for $tag
      cd $package && \
          ONLY_TAGS=$tag ${TITO_PATH}tito release koji && \
          echo $package>>$PACKAGES && \
          echo $package $tag>>$PACKAGES_TAG
  )
done

#upload tgz
if [ "0$FEDORA_UPLOAD" -eq 1 ] ; then
  for package in $(cat $PACKAGES | sort | uniq); do
  (
      echo Uploading tgz for path $package
      cd $package && LC_ALL=C ${TITO_PATH}tito build --tgz | \
      awk '/Wrote:.*tar.gz/ {print $2}' | \
      xargs -I packagepath scp packagepath fedorahosted.org:spacewalk
  )
  done
fi
rm $PACKAGES

popd >/dev/null
