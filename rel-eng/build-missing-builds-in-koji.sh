#!/bin/bash


TAGS="dist-5E-sw-1.6-candidate dist-6E-sw-1.6-candidate dist-f14-sw-1.6-candidate dist-f15-sw-1.6-candidate dist-f16-sw-1.6-candidate"
FEDORA_UPLOAD=1

pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

declare -a PACKAGES

for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_BREW_ARG --no-extra $tag | \
    perl -lne '/^\s+(.+)-.+-.+$/ and print $1' | \
    xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring \
    | \
    while read package ; do
    (
      echo Building package in path $package for $tag
      cd $package && \
          ${TITO_PATH}tito release $tag && \
          PACKAGES[${#PACKAGES[@]}]=$package
    )
    done
done
if [ "0$FEDORA_UPLOAD" -eq 1 ] ; then
  for package in "${PACKAGES[@]}"; do
    echo $package
  done | sort | uniq |\
  while read package ; do
  (
      echo Uploading tgz for path $package
      cd $package && LC_ALL=C ${TITO_PATH}tito build --tgz | \
      awk '/Wrote:.*tar.gz/ {print $2}' | \
      xargs -I packagepath scp packagepath fedorahosted.org:spacewalk
  )
  done
fi

popd >/dev/null
