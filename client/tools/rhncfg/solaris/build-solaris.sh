#!/usr/bin/bash

# clean up junk...
make clean
rm Prototype

rm -rf /tmp/RHATrncfg*
rm -rf /test-bretm/build-target

# where you want stuff to land
DEST_PREFIX=/opt/redhat/rhn/solaris
export DEST_PREFIX

# think of this as the buildroot, should be some temp dir
BUILD_ROOT=/test-bretm/build-target
export BUILD_ROOT

# PREFIX used by the makefiles...
PREFIX="$BUILD_ROOT$DEST_PREFIX"
export PREFIX

INSTALL='/usr/ucb/install -c'
export INSTALL

LN='ln -sf'
export LN

rm -rf temp_src

mkdir temp_src
cp * temp_src/
cp -R actions temp_src/
cp -R config_* temp_src/
cd temp_src

perl -pi -e "s|/usr/bin/diff|$DEST_PREFIX/bin/diff|" \
    ./config_client/rhncfgcli_diff.py \
    ./config_common/file_utils.py \
    ./config_management/rhncfg_diff.py

perl -pi -e "s|/usr/share/rhn|$DEST_PREFIX/usr/share/rhn|" \
    ./config_client/* \
    ./config_management/*

perl -pi -e "s|/etc/sysconfig/rhn/allowed-actions|$DEST_PREFIX/etc/sysconfig/rhn/allowed-actions|" \
    ./actions/configfiles.py

perl -pi -e "s|/etc/sysconfig/rhn/systemid|$DEST_PREFIX/etc/sysconfig/rhn/systemid|" \
    ./config_client/*

perl -pi -e "s|/etc/sysconfig/rhn/up2date|$DEST_PREFIX/etc/sysconfig/rhn/up2date|" \
    ./config_common/up2date_config_parser.py

perl -pi -e "s|os.path.join\(os.sep|os.path.join\('$DEST_PREFIX'|" \
    ./config_common/local_config.py

perl -pi -e "s|^#!/usr/bin/python|#!$DEST_PREFIX/bin/python|" \
    ./config_client/rhncfg-client.py \
    ./config_management/rhncfg-manager.py

make
make install


echo "i pkginfo" > Prototype
#echo "i postinstall" >> Prototype
#echo "i checkinstall" >> Prototype

find $PREFIX -print | pkgproto | sed "s#$PREFIX#$DEST_PREFIX#g" >> Prototype

pkgmk -o -r $BUILD_ROOT -d /tmp -f Prototype

cd /tmp

# tar -cf - RHATrncfg | gzip -9 -c > RHATrncfg-1.0.sparc.pkg.tar.gz
pkgtrans -s /tmp RHATrncfg-1.0.pkg RHATrncfg
