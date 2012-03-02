#!/bin/bash


TAGS="dist-5E-sw-1.8-candidate dist-6E-sw-1.8-candidate dist-f15-sw-1.8-candidate dist-f16-sw-1.8-candidate"
FEDORA_UPLOAD=1

pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

echo 'Gathering data ...'
for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_BREW_ARG --no-extra $tag | \
    perl -lne '/^\s+(.+)-.+-.+$/ and print $1' \
    | xargs -I replacestring awk '{print $2}' rel-eng/packages/replacestring \
    | sed "s/$/ $tag/"
done \
    | perl -lane '$X{$F[0]} .= " $F[1]"; END { for (sort keys %X) { print "$_$X{$_}" } }' \
    | while read package_dir tags ; do
      (
      echo Building package in path $package_dir for $tags
      cd $package_dir && \
          ONLY_TAGS="$tags" ${TITO_PATH}tito release koji
      )
    if [ "0$FEDORA_UPLOAD" -eq 1 ] ; then
      (
      echo Uploading tgz for path $package_dir
      cd $package_dir && LC_ALL=C ${TITO_PATH}tito build --tgz | \
      awk '/Wrote:.*tar.gz/ {print $2}' | \
      xargs -I packagepath scp packagepath fedorahosted.org:spacewalk
      )
    fi
    done

popd >/dev/null

