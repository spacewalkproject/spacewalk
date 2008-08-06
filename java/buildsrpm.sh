NAME=spacewalk-java
VERSION=`awk '{print $1}' version`
RELEASE=`awk '{print $2}' version`

echo "thispartignored $NAME-$VERSION.tar.gz" > sources

rm -f $NAME-$VERSION.tar.gz
rm -rf rpm-build/

find . -path ./version -prune -o -path ./build -prune -o -path ./buildsrpm.sh -prune -o -path ./Makefile -prune -o -path ./Makefile.dist-cvs -prune -o -path sources -prune -o -path $NAME-$VERSION -o -type f -print -o -type l -print -o -path ./Makefile.$NAME -prune | while read file ; do d=`dirname $file` ; /usr/bin/test -d $NAME-$VERSION/$d || mkdir -p $NAME-$VERSION/$d ; ln $file $NAME-$VERSION/$file ; done && tar czf $NAME-$VERSION.tar.gz $NAME-$VERSION

rm -rf $NAME-$VERSION/

mkdir -p rpm-build
cp $NAME-$VERSION.tar.gz rpm-build/
cp version rpm-build/
cp sources rpm-build/
rpmbuild --define "_topdir %(pwd)/rpm-build" \
         --define "_builddir %{_topdir}" \
         --define "_rpmdir %{_topdir}" \
         --define "_srcrpmdir %{_topdir}" \
         --define "_specdir %{_topdir}" \
         --define "_sourcedir %{_topdir}" \
         --nodeps \
         -bs rhn-java.spec
