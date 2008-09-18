VERSION=`awk '{print $1}' version`
RELEASE=`awk '{print $2}' version`

echo "thispartignored backend-$VERSION.tar.gz" > sources

rm -f backend-$VERSION.tar.gz
rm -rf rpm-build/

find . -path ./version -prune -o -path ./Makefile -prune -o -path ./Makefile.dist-cvs -prune -o -path sources -prune -o -path backend-0.1 -o -type f -print -o -type l -print -o -path ./Makefile.backend -prune | while read file ; do d=`dirname $file` ; /usr/bin/test -d backend-$VERSION/$d || mkdir -p backend-$VERSION/$d ; ln $file backend-$VERSION/$file ; done && (/usr/bin/test -z "Makefile.backend" || ln Makefile.backend backend-$VERSION/Makefile ) && tar czf backend-$VERSION.tar.gz backend-$VERSION

rm -rf backend-$VERSION/

mkdir -p rpm-build
cp backend-$VERSION.tar.gz rpm-build/
cp version rpm-build/
cp sources rpm-build/
rpmbuild --define "_topdir %(pwd)/rpm-build" \
         --define "_builddir %{_topdir}" \
         --define "_rpmdir %{_topdir}" \
         --define "_srcrpmdir %{_topdir}" \
         --define "_specdir %{_topdir}" \
         --define "_sourcedir %{_topdir}" \
         -bs backend.spec
