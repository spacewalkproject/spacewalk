#!/bin/bash
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

cd /etc
symlink $SVNDIR/eng/web/conf/pxtdb.conf
symlink $SVNDIR/eng/web/conf/tnsnames.ora

cd /etc/rhn
symlink $SVNDIR/eng/web/conf/rhn.conf

cd /etc/rhn/default
symlink $SVNDIR/eng/web/conf/rhn_web.conf
symlink $SVNDIR/eng/java/conf/default/rhn_hibernate.conf

ln -s /var/log/httpd /etc/rhn/satellite-httpd/logs

cd /etc/logrotate.d
symlink $SVNDIR/eng/satellite/config/etc/logrotate.d/satellite-http

cd /etc/rhn/satellite-httpd
symlink /var/log/httpd logs
symlink /usr/lib/httpd/modules
symlink /var/run 

cd /etc/rhn/satellite-httpd/conf
symlink /etc/httpd/conf/httpd.conf
symlink /etc/httpd/conf/magic
symlink $SVNDIR/eng/backend/httpd-conf/rhn_server.conf
symlink $SVNDIR/eng/satellite/fedora/config/etc/rhn/satellite-httpd/conf/rhnweb.conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/satidmap.pl
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/ssl.conf
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/startup.pl
symlink $SVNDIR/eng/satellite/config/etc/rhn/satellite-httpd/conf/workers.properties

cd /etc/rhn/satellite-httpd/conf.d
symlink $SVNDIR/eng/satellite/fedora/config/etc/rhn/satellite-httpd/conf.d/satellite.conf

cd /etc/httpd/conf.d
symlink /etc/rhn/satellite-httpd/conf.d/satellite.conf

cd /etc/init.d
symlink $SVNDIR/eng/satellite/config/etc/init.d/satellite-httpd

cd /etc/sysconfig
symlink $SVNDIR/eng/satellite/config/etc/sysconfig/satellite-httpd
sudo sed -i 's/@@serverDOTnls_lang@@/english.UTF8/g' /etc/sysconfig/satellite-httpd

cd /var/www
symlink $SVNDIR/eng/web/html

cd /var/www/lib
symlink $SVNDIR/eng/web/modules/cypress/Cypress 
symlink $SVNDIR/eng/web/modules/dobby/Dobby 
symlink $SVNDIR/eng/web/modules/grail/Grail
symlink $SVNDIR/eng/web/modules/moon/Moon 
symlink $SVNDIR/eng/web/modules/rhn/RHN 
symlink $SVNDIR/eng/web/modules/pxt/PXT 
symlink $SVNDIR/eng/web/modules/ 
symlink $SVNDIR/eng/web/modules/sniglets/Sniglets


cd /var/lib/tomcat5/webapps
symlink $SVNDIR/eng/java/rhnwebapp rhn

cd /etc/tomcat5/Catalina/localhost
symlink $SVNDIR/eng/java/conf/rhn.xml

cd $SVNDIR/eng/java
symlink conf/eclipse/.project

