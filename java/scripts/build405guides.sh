#!/bin/sh

guides=("reference satellite")
TOP=$HOME/trunk/rhn

TMPDIR=/tmp/rhn-docs
RHNDOCS=RHNdocs
echo "o Cleaning $TMPDIR"

rm -rf $TMPDIR
mkdir $TMPDIR
cd $TMPDIR

export CVS_RSH=ssh
export CVSROOT=:ext:shughes@cvs.devel.redhat.com:/cvs/ecs
#export CVSROOT=:pserver:anonymous@cvs.devel.redhat.com:/cvs/ecs

cvs co -r RHN_4_0_5 -d rh-sgml rh-sgml

for guide in ${guides[@]}
do
  cvs co -r RHN_4_0_5  $RHNDOCS/$guide
  cp -r rh-sgml $RHNDOCS/$guide/.
done

rm -rf rh-sgml

cd $RHNDOCS

cvs co -d docs-stuff docs/docs-stuff

for guide in ${guides[@]}
do
  pushd $guide
  export PATH=$PATH:$TMPDIR/$RHNDOCS/docs-stuff

  echo "o BUIDLING $guide"

  make html pdf

  echo "o RHNifying $guide"

  # We add the lang to the filename now
  GUIDEDIR=RHN-$guide-en
  pushd $TMPDIR/$RHNDOCS/$guide/$GUIDEDIR
 
  for i in `find . -name '*.html'`
  do
    # fix jade compiler invalid html tags
    xmllint --format --html $i > $i.tmp 
    perl -p -e 's|<KEYCAP[^>]*>(.*?)</KEYCAP>|$1|ig' $i.tmp > $i
    perl -p -e 's|<ISBN[^>]*>(.*?)</ISBN>|$1|ig' $i > $i.tmp
    mv $i.tmp $i
    # apply rhn stylesheet
    perl $TOP/scripts/pxtify-html.pl -s $TOP/scripts/rhnify-html.xsl -i $i
    # change internal html links to jsp links
    sed 's/\.html/\.jsp/g' $i > $i.tmp

    #jsp'ize
    echo "<%@ page contentType=\"text/html; charset=UTF-8\"%>" | cat - $i.tmp > $i
    mv $i `basename $i .html`.jsp
    rm $i.tmp
  done 
  cp -r * $HOME/trunk/rhn-svn/eng/docs/guides/$guide/rhn405/en/.
  cp ../RHN-$guide-en.pdf $HOME/trunk/rhn-svn/eng/docs/guides/$guide/rhn405/en/RHN-$guide-405-en.pdf
  popd
  popd
done
