VERSION=`awk '{print $1}' version`
RELEASE=`awk '{print $2}' version`

echo "thispartignored rhn-web-$VERSION.tar.gz" > sources

rm -f rhn-web-$VERSION.tar.gz
rm -rf rpm-build/

find . -path ./version -prune -o -path ./Makefile -prune -o -path ./Makefile.dist-cvs -prune -o -path sources -prune -o -path rhn-web-0.1 -o -type f -print -o -type l -print -o -path ./Makefile.rhn-web -prune | while read file ; do d=`dirname $file` ; /usr/bin/test -d rhn-web-$VERSION/$d || mkdir -p rhn-web-$VERSION/$d ; ln $file rhn-web-$VERSION/$file ; done && (/usr/bin/test -z "Makefile.rhn-web" || ln Makefile.rhn-web rhn-web-$VERSION/Makefile ) && tar czf rhn-web-$VERSION.tar.gz rhn-web-$VERSION

rm -rf rhn-web-$VERSION/

mkdir -p rpm-build
cp rhn-web-$VERSION.tar.gz rpm-build/
cp version rpm-build/
cp sources rpm-build/
rpmbuild --define "_topdir %(pwd)/rpm-build" \
         --define "_builddir %{_topdir}" \
         --define "_rpmdir %{_topdir}" \
         --define "_srcrpmdir %{_topdir}" \
         --define "_specdir %{_topdir}" \
         --define "_sourcedir %{_topdir}" \
         -bs rhn-web.spec
