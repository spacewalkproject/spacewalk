#!/bin/bash

let errors=0

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

if [ -z $GITDIR ] ; then
  echo "Please set GITDIR to the root of your GIT checkout"
  exit 1
fi

makedir /etc/rhn
makedir /etc/rhn/search
makedir /etc/rhn/default
makedir /etc/rhn/satellite-httpd
makedir /etc/rhn/satellite-httpd/conf
makedir /etc/rhn/satellite-httpd/conf.d
makedir /etc/rhn/satellite-httpd/conf/rhn
makedir /etc/sysconfig/rhn
makedir /var/www/lib

cd /etc
symlink $GITDIR/satellite/config/etc/webapp-keyring.gpg

cd /etc/rhn
symlink $GITDIR/web/conf/rhn.conf

cd /etc/rhn/default
symlink $GITDIR/web/conf/rhn_web.conf
symlink $GITDIR/java/conf/default/rhn_hibernate.conf

cd /etc/rhn/satellite-httpd
symlink /var/log/httpd logs
symlink /usr/lib/httpd/modules
symlink /var/run 

cd /etc/rhn/satellite-httpd/conf
symlink $GITDIR/backend/httpd-conf/rhn_server.conf
symlink $GITDIR/satellite/fedora/config/etc/rhn/satellite-httpd/conf/rhnweb.conf
symlink $GITDIR/satellite/config/etc/rhn/satellite-httpd/conf/satidmap.pl
symlink $GITDIR/satellite/config/etc/rhn/satellite-httpd/conf/startup.pl
symlink $GITDIR/satellite/config/etc/rhn/satellite-httpd/conf/workers.properties

cd /etc/rhn/satellite-httpd/conf.d
symlink $GITDIR/satellite/fedora/config/etc/rhn/satellite-httpd/conf.d/satellite.conf

cd /etc/httpd/conf.d
symlink /etc/rhn/satellite-httpd/conf.d/satellite.conf

#Note...not symlinking here since we'll be modifying this file and
#don't want to checkin the change.
cp $GITDIR/satellite/config/etc/sysconfig/satellite-httpd /etc/sysconfig
sudo sed -i 's/@@serverDOTnls_lang@@/english.UTF8/g' /etc/sysconfig/satellite-httpd

cd /var/www
symlink $GITDIR/web/html

cd /var/www/html
symlink $GITDIR/branding/css
symlink $GITDIR/branding/img
symlink $GITDIR/branding/templates

cd /var/www/html/nav
symlink $GITDIR/branding/styles

cd /var/www/lib
symlink $GITDIR/web/modules/cypress/Cypress 
symlink $GITDIR/web/modules/dobby/Dobby 
symlink $GITDIR/web/modules/grail/Grail
symlink $GITDIR/web/modules/rhn/RHN 
symlink $GITDIR/web/modules/pxt/PXT 
symlink $GITDIR/web/modules/ 
symlink $GITDIR/web/modules/sniglets/Sniglets


cd /var/lib/tomcat5/webapps
symlink $GITDIR/java/rhnwebapp rhn

cd /etc/tomcat5/Catalina/localhost
symlink $GITDIR/java/conf/rhn.xml

cd /etc/rhn/search
symlink $GITDIR/search-server/src/config/search/rhn_search.conf

cd $GITDIR/java
symlink conf/eclipse/.project

echo ""
echo "Finished: errors = $errors"
echo ""

exit $errors
