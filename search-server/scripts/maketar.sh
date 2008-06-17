if [ -a version ]; then
   version=`cat version | awk '/^[0-9]\.[0-9]\.[0-9]* / { print $1 }'`

   if [ "$version" == "" ]; then
       echo "Version not found"
       exit -1
   fi
   
   echo "Creating /tmp/rhn-search-$version"
   mkdir /tmp/rhn-search-$version

   echo "Copying repo to /tmp/rhn-search-$version/"
   cp -R * /tmp/rhn-search-$version/

   cd /tmp/
   rm -f rhn-search-$version/scripts/maketar.sh
   echo "Creating /tmp/rhn-search-$version.tar.gz file"
   tar -czf /tmp/rhn-search-$version.tar.gz rhn-search-$version/ --exclude .svn
   cd -

   echo "Removing /tmp/rhn-search-$version"
   rm -rf /tmp/rhn-search-$version

   echo ""
   echo "You can find your tar at /tmp/rhn-search-$version.tar.gz"
   echo ""

else
   echo "You moron, you gotta run this from the directory containing the version file."
fi
