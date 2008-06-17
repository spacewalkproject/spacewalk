if [ -a version ]; then
   version=`cat version | awk '/^[0-9]\.[0-9]\.[0-9]* / { print $1 }'`

   if [ "$version" == "" ]; then
       echo "Version not found"
       exit -1
   fi
   
   echo "Creating /tmp/rhn-java-sat-$version"
   mkdir /tmp/rhn-java-sat-$version

   echo "Copying repo to /tmp/rhn-java-sat-$version/"
   cp -R * /tmp/rhn-java-sat-$version/

   cd /tmp/
   echo "Creating /tmp/rhn-java-sat-$version.tar.gz file"
   tar -czf /tmp/rhn-java-sat-$version.tar.gz rhn-java-sat-$version/ --exclude .svn
   cd -

   echo "Removing /tmp/rhn-java-sat-$version"
   rm -rf /tmp/rhn-java-sat-$version

   echo ""
   echo "You can find your tar at /tmp/rhn-java-sat-$version.tar.gz"
   echo ""

else
   echo "You moron, you gotta run this from the directory containing the version file."
fi
