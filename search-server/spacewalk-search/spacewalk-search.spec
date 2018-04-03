%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: spacewalk-search
Summary: Spacewalk Full Text Search Server
License: GPLv2
Version: 2.9.0
Release: 1%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone https://github.com/spacewalkproject/spacewalk.git
# cd search-server
# make test-srpm
URL: https://github.com/spacewalkproject/spacewalk
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch

#Requires: apache-ibatis-sqlmap
Requires: c3p0 >= 0.9.1
Requires: cglib
Requires: doc-indexes
Requires: jakarta-commons-httpclient
Requires: jakarta-oro
Requires: javapackages-tools
#Requires: lucene
Requires: objectweb-asm
Requires: quartz < 2.0
Conflicts: quartz >= 2.0
Requires: redstone-xmlrpc
#Requires: picocontainer
Requires: tanukiwrapper
Requires: simple-core
Obsoletes: rhn-search < 5.3.0
BuildRequires: ant
#BuildRequires: apache-ibatis-sqlmap
BuildRequires: c3p0 >= 0.9.1
BuildRequires: cglib
BuildRequires: jakarta-commons-httpclient
BuildRequires: jakarta-oro
BuildRequires: java-1.8.0-openjdk-devel
BuildRequires: javapackages-tools
#BuildRequires: lucene
BuildRequires: objectweb-asm
BuildRequires: quartz < 2.0
BuildRequires: redstone-xmlrpc
#BuildRequires: picocontainer
BuildRequires: tanukiwrapper
BuildRequires: simple-core
%if 0%{?fedora} || 0%{?rhel} >=7 || 0%{?suse_version} >= 1315
Requires: apache-commons-cli
Requires: apache-commons-codec
Requires: apache-commons-lang
Requires: apache-commons-logging
Requires: mchange-commons
BuildRequires: apache-commons-cli
BuildRequires: apache-commons-codec
BuildRequires: apache-commons-lang
BuildRequires: apache-commons-logging
%else
Requires: jakarta-commons-cli
Requires: jakarta-commons-codec
Requires: jakarta-commons-lang
Requires: jakarta-commons-logging
BuildRequires: jakarta-commons-cli
BuildRequires: jakarta-commons-codec
BuildRequires: jakarta-commons-lang
BuildRequires: jakarta-commons-logging
%endif
%if 0%{?fedora} && 0%{?fedora} >= 21
Requires: log4j12
BuildRequires: log4j12
%else
Requires: log4j
BuildRequires: log4j
%endif
%if 0%{?rhel} && 0%{?rhel} < 7
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
%endif
%if 0%{?fedora} || 0%{?rhel} >=7 || 0%{?suse_version} >= 1210
BuildRequires: systemd
%endif
%if 0%{?suse_version}
BuildRequires: doc-indexes
%endif

%description
This package contains the code for the Full Text Search Server for
Spacewalk Server.

%prep
%setup -n %{name}-%{version}

# disable crash dumps in IBM java (OpenJDK have them off by default)
if java -version 2>&1 | grep -q IBM ; then
    sed -i '/#wrapper\.java\.additional\.[0-9]=-Xdump:none/ { s/^#//; }' \
        src/config/search/rhn_search_daemon.conf
fi

%install
rm -fr ${RPM_BUILD_ROOT}
ant -Djar.version=%{version} install
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib
install -d -m 755 $RPM_BUILD_ROOT%{_var}/lib/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_var}/lib/rhn/search/indexes
ln -s -f %{_prefix}/share/rhn/search/indexes/docs $RPM_BUILD_ROOT%{_var}/lib/rhn/search/indexes/docs
install -d -m 755 $RPM_BUILD_ROOT%{_sbindir}
%if 0%{?fedora} || 0%{?rhel} >=7 || 0%{?suse_version} >= 1210
install -d -m 755 $RPM_BUILD_ROOT%{_unitdir}
%else
install -d -m 755 $RPM_BUILD_ROOT%{_initrddir}
%endif
install -d -m 755 $RPM_BUILD_ROOT%{_bindir}
install -d -m 755 $RPM_BUILD_ROOT%{_var}/log/rhn/search
install -d -m 755 $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/nutch
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d
install -p -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib/
# using install -m does not preserve the symlinks
cp -d lib/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib
install -p -m 644 src/config/etc/logrotate.d/rhn-search $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/rhn-search
install -p -m 755 src/config/rhn-search $RPM_BUILD_ROOT%{_sbindir}
%if 0%{?fedora} || 0%{?rhel} >=7 || 0%{?suse_version} >= 1210
install -p -m 755 src/config/rhn-search.service $RPM_BUILD_ROOT%{_unitdir}
%else
install -p -m 755 src/config/rhn-search.init $RPM_BUILD_ROOT%{_initrddir}/rhn-search
%endif
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT%{_bindir}/rhnsearchd
install -p -m 644 src/config/search/rhn_search.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_search.conf
install -p -m 644 src/config/search/rhn_search_daemon.conf $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_search_daemon.conf
ln -s -f %{_prefix}/share/rhn/search/lib/spacewalk-search-%{version}.jar $RPM_BUILD_ROOT%{_prefix}/share/rhn/search/lib/spacewalk-search.jar
%if 0%{?fedora} && 0%{?fedora} >= 21
sed -i 's/log4j.jar/log4j-1.jar/' $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_search_daemon.conf
%endif
%if 0%{?suse_version} >= 1315
sed -i 's/nutch-2008-12-01_04-01-21.jar/apache-nutch-1.9.jar/' $RPM_BUILD_ROOT%{_prefix}/share/rhn/config-defaults/rhn_search_daemon.conf
%endif

%clean

%post
%if 0%{?suse_version} >= 1210
%service_add_post rhn-search.service
%else
if [ -f /etc/init.d/rhn-search ]; then
   # This adds the proper /etc/rc*.d links for the script
   /sbin/chkconfig --add rhn-search

   was_running=0
   if /sbin/service rhn-search status > /dev/null 2>&1 ; then
       was_running=1
   fi
fi
%endif

# Migrate original /usr/share/rhn/search/indexes/*
# to /var/lib/rhn/search/indexes
cd %{_prefix}/share/rhn/search/indexes && /bin/ls | /bin/grep -v docs | while read i ; do
    if [ ! -e %{_var}/lib/rhn/search/indexes/$i ] ; then
        if [ $was_running -eq 1 ] ; then
            if [ -f /etc/init.d/rhn-search ]; then
               /sbin/service rhn-search stop > /dev/null 2>&1
               was_running=2
            fi
        fi
        /bin/mv $i %{_var}/lib/rhn/search/indexes/$i
        # If the mv failed for whatever reason, symlink
        if [ -e $i ] ; then
            /bin/rm -rf %{_var}/lib/rhn/search/indexes/$i
            /bin/ln -s -f %{_prefix}/share/rhn/search/indexes/$i %{_var}/lib/rhn/search/indexes/$i
        fi
    fi
done

if [ -f /etc/init.d/rhn-search ]; then
   if [ $was_running -eq 1 ] ; then
       /sbin/service rhn-search status > /dev/null 2>&1 || /sbin/service rhn-search start > /dev/null 2>&1
   fi
fi

%preun
%if 0%{?suse_version} >= 1210
%service_del_preun rhn-search.service
%else
if [ $1 = 0 ] ; then
    if [ -f /etc/init.d/rhn-search ]; then
       /sbin/service rhn-search stop >/dev/null 2>&1
       /sbin/chkconfig --del rhn-search
    fi
fi
%endif

%if 0%{?suse_version} >= 1210
%postun
%service_del_postun rhn-search.service

%pre
%service_add_pre rhn-search.service
%endif

%files
%attr(755, root, root) %{_var}/log/rhn/search
%{_prefix}/share/rhn/search/lib/*
%attr(755, root, root) %{_sbindir}/rhn-search
%if 0%{?fedora} || 0%{?rhel} >=7 || 0%{?suse_version} >= 1210
%attr(755, root, root) %{_unitdir}/rhn-search.service
%else
%attr(755, root, root) %{_initrddir}/rhn-search
%endif
%{_bindir}/rhnsearchd
%{_prefix}/share/rhn/config-defaults/rhn_search.conf
%{_prefix}/share/rhn/config-defaults/rhn_search_daemon.conf
%{_sysconfdir}/logrotate.d/rhn-search
%dir %attr(755, root, root) %{_var}/lib/rhn/search
%dir %attr(755, root, root) %{_var}/lib/rhn/search/indexes
%{_var}/lib/rhn/search/indexes/docs
%if 0%{?suse_version}
%dir %attr(755, root, root) %{_var}/lib/rhn
%dir %attr(750,root,www) %{_prefix}/share/rhn/config-defaults
%dir /usr/share/rhn
%dir /usr/share/rhn/search
%dir /usr/share/rhn/search/lib
%attr(770,root,www) %dir /var/log/rhn
%endif

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Thu Sep 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- 1483503 - disable ibm java coredumps in tanukiwrapper

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Mon Jul 17 2017 Jan Dobes 2.7.6-1
- Remove more fedorahosted links

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.5-1
- recompile all packages with the same (latest) version of java

* Mon Apr 10 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.4-1
- use java 1.8.0
- use default RHEL6 jakarta-commons-* packages

* Wed Apr 05 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.3-1
- updated RHEL6 Requires after jpackage removal
- use simple logging

* Thu Mar 30 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.2-1
- simplified Requires/Buildrequires ifdefs
- added missing requires

* Thu Mar 30 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.1-1
- simplify rhn-search jar list

* Mon Jun 13 2016 Grant Gainey 2.6.1-1
- spacewalk-search: use apache-nutch 1.9
- spacewalk-search: build on openSUSE
- Bumping package versions for 2.6.

* Fri Jan 08 2016 Jan Dobes 2.5.2-1
- require log4j12, it will not download in build time on Fedora 23 otherwise

* Thu Oct 22 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- run indexing tasks only after previous one finishes
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.2-1
- Bumping copyright year.

* Tue Apr 28 2015 Tomas Lestach <tlestach@redhat.com> 2.4.1-1
- fix snapshot tag rhn-search issue
- instantiate insert query only when needed
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.7-1
- Updating copyright info for 2015

* Thu Feb 26 2015 Tomas Lestach <tlestach@redhat.com> 2.3.6-1
- missing value PIDFile for systemd

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 2.3.5-1
- fix spec condition error

* Wed Jan 28 2015 Tomas Lestach <tlestach@redhat.com> 2.3.4-1
- link the compatibility log4j jar on fc21
- move jpackage.jars to a separate file

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.3-1
- Getting rid of trailing spaces in XML
- Getting rid of trailing spaces in Java

* Wed Sep 24 2014 Tomas Lestach <tlestach@redhat.com> 2.3.2-1
- use StringUtils for checking non-empty values
- 1085033 - set newly constructed "db_name" even if db_ssl_enabled is disabled

* Thu Aug 14 2014 Stephen Herr <sherr@redhat.com> 2.3.1-1
- 1129827 - fix package searching in shared channels
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.8-1
- fix copyright years

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.7-1
- fixed apache vs. jakarta  -commons-{codec,lang} build requires

* Wed Jun 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.6-1
- fixed apache vs. jakarta  -commons-{codec,lang} conflict

* Tue Jun 24 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.5-1
- updated deps on RHEL7

* Mon Jun 23 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.4-1
- use javapackages-tools instead of jpackage-utils on RHEL7

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- Use maxDoc() to actually iterate over all documents
- Do not skip in case the last record has been deleted
- De-duplicate handleDeletedRecords() implementations

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- spec file polish

* Tue Mar 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- make taskomatic and rhn-search configuration overrideable via rhn.conf

* Wed Feb 12 2014 Stephen Herr <sherr@redhat.com> 2.1.14-1
- 1061425 - make package search faster

* Thu Jan 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.13-1
- %%attr() mode not applicaple to symlink
- resolve conflict between {apache,jakarta}-commons-cli on Fedora 20

* Wed Jan 08 2014 Tomas Lestach <tlestach@redhat.com> 2.1.12-1
- let spacewalk-search buildrequire javapackages-tools

* Tue Jan 07 2014 Tomas Lestach <tlestach@redhat.com> 2.1.11-1
- jpackage-utils were replaced with javapackages-tools in fc20

* Mon Jan 06 2014 Tomas Lestach <tlestach@redhat.com> 2.1.10-1
- fix rhn-search on fedoras

* Thu Dec 12 2013 Tomas Lestach <tlestach@redhat.com> 2.1.9-1
- do not let cleanindex log into the console
- there're no objectweb-asm on rhel5
- let spacewalk-search require c3p0 >= 0.9.1

* Wed Dec 11 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.8-1
- 1040540 - have package search return all matching results

* Fri Dec 06 2013 Tomas Lestach <tlestach@redhat.com> 2.1.7-1
- 1023669 - have unique id for SnapshotTag
- 1023669 - remove unused logger
- 1023669 - start using verifyServerVisibility
- 1023669 - start using errata visibility
- 1023669 - fix list iterations as query parameters
- 1023669 - add connection customizer
- 1023669 - introduce C3P0DataSourceFactory
- 1023669 - link cglib-node and objectweb-asm for DelteIndexes
- 1023669 - require and link c3p0
- 1023669 - require and link cglib-nodep and objectweb-asm
- 1023669 - replace ibatis jar with mybatis
- 1023669 - adapt code for mybatis
- 1023669 - migrate to mybatis
- 1023669 - remove original setSessionTimeZone

* Fri Nov 15 2013 Tomas Lestach <tlestach@redhat.com> 2.1.6-1
- Fix custom info value index removal in advanced search

* Thu Oct 31 2013 Matej Kollar <mkollar@redhat.com> 2.1.5-1
- 1020952 - Single db root cert + option name change

* Thu Oct 31 2013 Tomas Lestach <tlestach@redhat.com> 2.1.4-1
- 1023669 - set Session Time Zone for Oracle connections
- Unchecked conversion removed in rhnsearch
- 1020952 - SSL for Postgresql: Java (rhn-search)

* Wed Oct 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- 1002590 - unified way how we call rhn-search cleanindex

* Tue Oct 01 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- 1013629 - clean up old help links

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.1-1
- removed trailing whitespaces

