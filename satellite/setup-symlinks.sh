#!/bin/bash
#
# This script is designed to manage the symbolic links
# as needed to maintain an RHN satellite development
# workspace.  The script will ensure that all needed
# directories are created.  Links need to be created
# in places where real files/dirs exist, the script will
# mv the real file to file.save.  The script is idempotent.
# In other words, it may be run over-and-over without
# negative affects.
#
# The environment variable SVNDIR is expected to be
# set to the root of your svn checkout.  That is, the
# path to the directory containing the (eng) directory.
#

let errors=0

chdir()
{
  echo ""
  cd $1
  pwd=`pwd`
  echo "working directory: ( $pwd )"
  echo ""
}

makedir()
{
  echo ""
  if [ -d $1 ]
  then
    echo "directory ( $1 ) already exists"
  else
    echo "making directory ( $1 ) ..."
    mkdir -p $1
  fi
}

symlink()
{
  echo ""
  if [ ! -e $1 ]
  then
    echo "( $1 ) NOT-LINKED, file not found"
    let errors+=1
    return
  fi
  DIR=`pwd`
  if [ -z $2 ]
  then
    NAME=`basename $1`
  else
    NAME=$2
  fi
  if [ -L $NAME ]
  then
    echo "( $DIR/$NAME ) already linked, unlinking..."
    rm -f $NAME
  else
    if [ -e $NAME ]
    then
      echo "( $DIR/$NAME ) already exists, saving ..."
      mv $NAME $NAME.save
    fi
  fi
  echo "linking ( $DIR/$NAME ) as:"
  echo "        ( $1 ) ..."
  ln -s $1 $NAME
}

if [ -z $SVNDIR ] ; then
    echo "Please set SVNDIR to your SVN checkout"
    exit 1
fi

makedir /etc/rhn
makedir /etc/rhn/default
makedir /etc/rhn/satellite-httpd
makedir /etc/rhn/satellite-httpd/conf
makedir /etc/rhn/satellite-httpd/conf/rhn
makedir /var/www/lib

chdir /etc
symlink $SVNDIR/eng/web/conf/tnsnames.ora

chdir /etc/rhn
symlink $SVNDIR/eng/web/conf/rhn.conf

chdir /etc/rhn/default
symlink $SVNDIR/eng/web/conf/rhn_web.conf
symlink $SVNDIR/eng/java/conf/default/rhn_hibernate.conf

chdir /etc/rhn/satellite-httpd
symlink /var/log/httpd logs
symlink /usr/lib/httpd/modules
symlink /var/run

chdir /etc/rhn/satellite-httpd/conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/httpd.conf
symlink /etc/httpd/conf/magic
symlink $SVNDIR/eng/backend/httpd-conf/rhn_server.conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/rhnweb.conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/satidmap.pl
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/ssl.conf
symlink /etc/httpd/conf/ssl.crt
symlink /etc/httpd/conf/ssl.key
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/startup.pl
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/workers.properties

chdir /etc/httpd/conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/httpd.conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/startup.pl
symlink $SVNDIR/eng/java/conf/workers.properties

chdir /etc/init.d
symlink $SVNDIR/eng/satellite/config/etc/init.d/satellite-httpd

chdir /var/www
symlink $SVNDIR/eng/web/html

chdir /var/www/lib
symlink $SVNDIR/eng/web/modules/dobby/Dobby 
symlink $SVNDIR/eng/web/modules/grail/Grail
symlink $SVNDIR/eng/web/modules/rhn/RHN 
symlink $SVNDIR/eng/web/modules/pxt/PXT 
symlink $SVNDIR/eng/web/modules/ 
symlink $SVNDIR/eng/web/modules/sniglets/Sniglets

chdir /etc/tomcat5
symlink $SVNDIR/eng/java/conf/tomcat-users.xml
symlink $SVNDIR/eng/java/conf/tomcat5.conf
symlink $SVNDIR/eng/java/conf/server.xml

chdir /var/lib/tomcat5/webapps
symlink $SVNDIR/eng/java/rhnwebapp rhn

chdir /etc/tomcat5/Catalina/localhost
symlink $SVNDIR/eng/java/conf/rhn.xml

chdir $SVNDIR/eng/java
symlink conf/eclipse/.project

echo ""
echo "Finished: errors = $errors"
echo ""

exit $errors
