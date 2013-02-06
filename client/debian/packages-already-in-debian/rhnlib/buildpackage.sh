#!/usr/bin/bash

# script to build a solaris package of up2date-list
#
#  Adrian Likins <alikins@redhat.com>
#

NAME=`cat $1 | grep PKG | cut -f2 -d'='| cut -f2 -d\"` 
TMP=/tmp
BUILDPREFIX=$TMP/build-$NAME
# er, lame
BUILDPREFIX_REL=tmp/build-$NAME
DESTPREFIX_REL=opt/redhat/rhn/solaris
DESTPREFIX=/${DESTPREFIX_REL}
DATADIR=${TMP}/${NAME}-pkginfo/
USERNAME=`whoami`


# path for solaris build stuff, will need to get tweaked for hpux/aix, but 
# theres some infof or that already un use_spec.sh

#PATH=/opt/redhat/rhn/solaris/bin:/opt/redhat/gnupro-03r1/H-sparc-sun-solaris2.5/bin:/opt/redhat/gnupro-03r1/contrib:/opt/redhat/rpm/solaris/bin:/home/cygnus/release/bin:/es/cst/bin:/bsp/bin:/usr/progressive/bin:/usr/unsupported/bin:/bin:/usr/ucb:/usr/sbin:/usr/local/bin:/sbin:/usr/kerberos/bin:/usr/local/bin:/usr/bin:/usr/X11R6/bin

PYTHONDIR=$DESTPREFIX/lib/python2.2/
PYTHONMODDIR=$PYTHONDIR/site-packages
BANGPATH=$DESTPREFIX/bin/python

# helper stuff
#INSTALL=/opt/redhat/gnupro-03r1/contrib/H-sparc-sun-solaris2.6/bin/install

#INSTALL=/es/unsupported/sparc-sun-solaris2.5/src/fileutils-4.1/src/ginstall
INSTALL=/usr/ucb/install

FILELIST=$TMP/filelist-$NAME

mkdir -p $BUILDPREFIX
# clean up the build root
rm -rf $BUILDPREFIX/*

# er, duh
#make
python setup.py build 

# install into the fake prefix
# make  PREFIX=$BUILDPREFIX INSTALL=$INSTALL PYTHONDIR=$PYTHONDIR PYTHONMOD_DIR=$PYTHONMODDIR BANGPATH=$BANGPATH install

python setup.py install --prefix=$BUILDPREFIX
# find the packages installed into the build root
find $BUILDPREFIX -print > $FILELIST

# create the package prototype
mkdir -p $DATADIR
cat $FILELIST | pkgproto > $DATADIR/prototype

# add the info about pkginfo file
echo "i pkginfo" > $DATADIR/prototype.tmp

cat $DATADIR/prototype >> $DATADIR/prototype.tmp

# write it back again
cp $DATADIR/prototype.tmp  $DATADIR/prototype

PROTOTYPE=$DATADIR/prototype

# cp our pkginfo file to the datafir
cp pkginfo $DATADIR/pkginfo

# okay, now the fun begins. The problem is that all the paths are
# wrong. You can't simply change the prototype, cause it will
# look for the new paths, where nothing exist. So you have to
# build the package, then tweak the package info directly. 

# build the actual package, pre munge
pkgmk -o -r / -d $TMP  -f $PROTOTYPE

ls -la $TMP

# the package is in filesystem format, so we
# need to go into that dir and start mucking
# with stuff
cd $TMP/${NAME}/root/

# since the package as is has a local
# equilvient of $(BUILDPREFIX), we need to
# create a dir structure representing what
# the dest version is

mkdir -p $DESTPREFIX_REL

# move the stuff to the new dir that we actually
# want...
echo $BUILDPREFIX_REL $DESTPREFIX_REL
echo
pwd
echo

mv ${BUILDPREFIX_REL}/* ${DESTPREFIX_REL}/

 
rm -rf $BUILDPREFIX_REL


# pkgmap is the manifest of files and what not
# we need to blip it about to sub in the new file
# paths


cd ..


# use perl cause I'm dumb and lazy
 perl -pi -e  "s|${BUILDPREFIX}|${DESTPREFIX}|g" pkgmap 

# fix the file ownership as well

perl -pi -e "s|${USERNAME}|root|g" pkgmap 
# now that we've got the file all munged up, lets
# go ahead and convert the file to a datastream format

pkgtrans -s $TMP  $TMP/$NAME.package $NAME

# probabaly want to compress the package at this
# point
