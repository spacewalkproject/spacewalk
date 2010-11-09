#!/bin/bash


if [ "$(basename $0)" == "build-missing-builds-in-brew.sh" ] ; then
    TAGS="satellite-5.4-rhel-5-candidate"
    KOJI_MISSING_BUILD_BREW_ARG="--brew"
    TITO_BUILD_ARG="--cvs-release"
else
    TAGS="dist-5E-sw-1.2-candidate dist-f12-sw-1.2-candidate dist-f13-sw-1.2-candidate dist-f14-sw-1.2-candidate"
    TITO_BUILD_ARG="--koji-release"
    FEDORA_UPLOAD=1
fi

pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_BREW_ARG --no-extra $tag | \
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
      cd $package && \
          echo y | ${TITO_PATH}tito build $TITO_BUILD_ARG | \
          awk '/Wrote:.*tar.gz/ {print $2}' | \
          if [ "0$FEDORA_UPLOAD" -eq 1 ] ; then
              xargs -I packagepath scp packagepath fedorahosted.org:spacewalk
          fi
    )
done

popd
