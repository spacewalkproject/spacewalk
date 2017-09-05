#!/bin/bash

# checks for missing builds / untagged commits and either sends report to email address $1 or prints to stdout
# expects koji package to be installed and postfix to be configured
# crontab -e
# 0 6 * * * $path_to_git/spacewalk/rel-eng/missing-builds-in-koji.sh $email_address

git pull -r &> /dev/null

tmp=$(mktemp)

pushd . >/dev/null
pushd `dirname $0`/.. >/dev/null

. rel-eng/build-missing-builds.conf

# say python to be nice to pipe
export PYTHONUNBUFFERED=1

case "$TITO_RELEASER" in
        copr) KOJI_MISSING_BUILD_ARG=--copr
                ;;
        brew) KOJI_MISSING_BUILD_ARG=--brew
                ;;
        koji) ;;
        *) echo "unknown builder" >&2
           exit 1
                ;;
esac

for tag in $TAGS; do
  rel-eng/koji-missing-builds.py $KOJI_MISSING_BUILD_ARG --no-extra $tag | \
    perl -lne '/^\s+(.+)-.+-.+$/ and print $1' \
    | xargs -I replacestring awk "{print \$2 \" $tag\"}" rel-eng/packages/replacestring
done \
    | perl -lane '$X{$F[0]} .= " $F[1]"; END { for (sort keys %X) { print "$_$X{$_}" } }' \
    | while read package_dir tags ; do
      echo $package_dir is missing buils in: $tags >> $tmp
      echo "$(awk '/^%changelog/{getline; for (i=2; i<NF; i++) printf $i " "; print $NF}' $package_dir*spec)" >> $tmp
      echo >> $tmp
    done

if ./rel-eng/git-untagged-commits.pl | read REPLY; then
  echo >> $tmp
  echo "Untagged commits:" >> $tmp
  ./rel-eng/git-untagged-commits.pl >> $tmp
fi

if [ -s $tmp ]; then
  if [ $# -eq 0 ]; then
    cat $tmp
  else
    cat $tmp | mail -s "Not built packages / Untagged commits for $(date +'%Y-%m-%d')" $1
  fi
fi

popd >/dev/null

rm $tmp
