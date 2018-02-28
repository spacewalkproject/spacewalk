#!/bin/bash


pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

. rel-eng/build-missing-builds.conf

build_in_koji() {
          local tags=$1
          local releaser=$2
          local package=$3
          local package_dir=$4
          (
            cd $package_dir && \
            ONLY_TAGS="$tags" ${TITO_PATH}tito release $releaser </dev/tty
          )
}

build_in_copr() {
          local tags=$1
          local releaser=$2
          local package=$3
          local package_dir=$4
          for t in $tags ; do
              copr-cli build-package "$t" --nowait --name "$package"
          done
}

case "$TITO_RELEASER" in
        copr) KOJI_MISSING_BUILD_ARG=--copr
              BUILD_FUNC=build_in_copr
                ;;
        brew) $KOJI_MISSING_BUILD_ARG=--brew
              BUILD_FUNC=build_in_koji
                ;;
        koji) BUILD_FUNC=build_in_koji
                ;;
        *) echo "unknown builder" >&2
           exit 1
                ;;
esac

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

echo 'Gathering data ...'
for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_ARG --no-extra $tag \
    | perl -lne '/^\s+(.+)-.+-.+$/ and print $1' \
    | xargs -I {} awk "{print \$2 \" {} $tag\"}" rel-eng/packages/{}
done \
    | perl -lane '$X{"$F[0] $F[1]"} .= " $F[2]"; END { for (sort keys %X) { print "$_$X{$_}" } }' \
    | while read package_dir package tags ; do
      echo Building $package in path $package_dir for $tags
      $BUILD_FUNC "$tags" "$TITO_RELEASER" "$package" "$package_dir"
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

