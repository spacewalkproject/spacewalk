#script to help push rhn-i18n-guides to svn
#author:shughes

export CVSROOT=:ext:shughes@cvs.devel.redhat.com:/cvs/ecs
export CVSDIR=/home/shughes/docs
export CVS_RSH=krsh
export TOP=$HOME/trunk/rhn #CVS RHN DIR
export TAG=RHN_4_1_0 #RHN DOCS TAG
export RELEASE=rhn410
export DOCSDIR=$HOME/trunk/rhn-svn/eng/docs
export SATDOCS=$HOME/trunk/rhn/satellite/docs

books=( "satellite reference channel-mgmt proxy client-config" )
cd $CVSDIR
#rm -rf RHNdocs
#cvs co -r $TAG RHNdocs/docs-stuff
#cvs co -r $TAG RHNdocs/rh-sgml

for book in ${books[@]}
do
    cvs up RHNdocs/${book}
    pushd RHNdocs/${book}
    make clean
    make html pdf
    pushd RHN-${book}-en
    LIST=`find . -name '*.html'`
    for j in $LIST ; do
      echo "<%@ page contentType=\"text/html; charset=UTF-8\"%>" | cat - $j > $j.new
      mv $j.new $j;
      #convert all internal relative links to jsp links
      perl -i -pe 's/(HREF|href)=\"((?!https?:|HTTPS?:).*)\.html(#?.*)\"/HREF=\"$2.jsp$3\"/' $j  
      #strip out docs css
      perl -i -pe 's/rhdocs-man\.css//' $j  
    done
    rename .html .jsp $LIST
    cp -r * $DOCSDIR/guides/${book}/$RELEASE/en/.
    popd
    cp RHN-${book}-en.pdf $SATDOCS/.
    popd
done  
