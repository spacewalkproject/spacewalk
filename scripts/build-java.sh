#!/bin/bash
 
BOXNODIR=root@$1
 
if [ ! -f ./*spec ]; then
    echo "No spec file found in $(pwd)";
    exit 1;
fi
 
SRPM=$(tito build --test --srpm | tail -n1 | sed 's/^Wrote: //g')
echo "Copying $SRPM"
 
ssh -C "$BOXNODIR" "rm -rf tmp-tito"
ssh -C "$BOXNODIR" "mkdir -p tmp-tito"
scp "$SRPM" "$BOXNODIR:tmp-tito/" && rm -f "$SRPM"
 
ssh -C "$BOXNODIR" "
cd ~/tmp-tito/
SRPM=\$(ls -t1 *rpm | head -n1)
if [ -f \"\$SRPM\" ]; then
   TOMCAT=\$(ls -d /etc/tomcat* | xargs -n1 basename)
   service taskomatic stop
   service httpd stop
   for t in \$TOMCAT; do service \$t stop; done
   # yum-builddep \"\$SRPM\" >/dev/null
   # echo "YUM-BUILDDEP: \$?"
   yum install -y jmock ant-apache-regexp ant-contrib ant-junit ant-nodeps checkstyle postgresql-jdbc 'perl(XML::XPath)'
   rm -rf /usr/src/redhat/SOURCES/*
   rm -rf /usr/src/redhat/BUILD/*
   rm -f /usr/src/redhat/RPMS/*/*rpm
   rm -f /root/rpmbuild/RPMS/*/*rpm
   DIST=\$(rpm -q kernel --qf %{release} | awk -F . '{print \$NF}')
   echo "DIST: \$DIST"
   RPMMACRO=\$(echo \$DIST | sed 's/el/rhel /' | sed 's/fc/fedora /')
   echo "RPMMACRO: \$RPMMACRO"
   OMIT="postgresql"
   rpm -q spacewalk-oracle > /dev/null
   if [ \$? -ne 0 ]; then
       OMIT="oracle"
   fi
   echo "OMIT: \$OMIT"
   OMIT_TESTS='--define \"omit-tests 1\"'
   echo "try: \$OMIT_TESTS, 2: $2"
   if [ \"$2\" != \"\" ]
   then
       OMIT_TESTS=\"\"
       rpmbuild --define \"\$RPMMACRO\" --rebuild -bi \"\$SRPM\" > /tmp/rpmbuid.txt
   else
       rpmbuild --define \"\$RPMMACRO\" --define \"omit-tests 1\" --rebuild -bi \"\$SRPM\" > /tmp/rpmbuid.txt
   fi
   echo "OMIT_TESTS: \$OMIT_TESTS"
   echo "RPMBUILD: \$?"
   # rhel has it here
   if [ -d /usr/src/redhat/RPMS ]; then
       PACKAGES=\$(ls /usr/src/redhat/RPMS/*/*rpm | grep -v \$OMIT)
       # rpm -Uvh --oldpackage /usr/src/redhat/RPMS/*/*rpm --force
   fi
   # fedora has it here
   if [ -d /root/rpmbuild/RPMS ]; then
       PACKAGES=\$(ls /root/rpmbuild/RPMS/*/*rpm | grep -v \$OMIT)
       # rpm -Uvh --oldpackage /root/rpmbuild/RPMS/*/*rpm
       # yum localinstall -y --nogpgcheck /root/rpmbuild/RPMS/*/*rpm
       #rm -f /root/rpmbuild/RPMS/*/*rpm
   fi
   echo "PACKAGES: \$PACKAGES"
   rpm -Uvh --oldpackage \$PACKAGES
   for t in \$TOMCAT; do service \$t start; done
   spacewalk-startup-helper wait-for-tomcat
   service httpd start
   service taskomatic start
   echo Success
fi"
