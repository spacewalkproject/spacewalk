%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: spacewalk-search
Summary: Spacewalk Full Text Search Server
Group: Applications/Internet
License: GPLv2
Version: 0.2.0
Release: 1%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd search-server
# make test-srpm
URL: https://fedorahosted.org/spacewalk
Source0: spacewalk-search-git-4d9eb00244f1d7ae528cb2fec2199b1d9fb8178a.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch

Group: Applications/Internet
Requires: apache-ibatis-sqlmap
Requires: jakarta-commons-lang >= 0:2.1
Requires: jakarta-commons-logging
Requires: jpackage-utils >= 0:1.5
Requires: log4j
#Requires: lucene
Requires: quartz
Requires: redstone-xmlrpc
#Requires: picocontainer
Requires: tanukiwrapper
BuildRequires: ant
BuildRequires: apache-ibatis-sqlmap
BuildRequires: jakarta-commons-lang >= 0:2.1
BuildRequires: jakarta-commons-logging
BuildRequires: java-devel >= 1.5.0
BuildRequires: log4j
#BuildRequires: lucene
BuildRequires: quartz
BuildRequires: redstone-xmlrpc
#BuildRequires: picocontainer
BuildRequires: tanukiwrapper
%description
This package contains the code for the Full Text Search Server for
Spacewalk Server.

%prep
%setup -n spacewalk-search-git-4d9eb00244f1d7ae528cb2fec2199b1d9fb8178a

%install
ant -Djar.version=%{version} install
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/classes/com/redhat/satellite/search/db
install -d -m 755 $RPM_BUILD_ROOT/etc/init.d
install -d -m 755 $RPM_BUILD_ROOT/%{_bindir}
install -d -m 755 $RPM_BUILD_ROOT/%{_var}/log/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/nutch

install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib/
# using install -m does not preserve the symlinks
cp -d lib/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib
install -m 644 src/config/log4j.properties $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/classes/log4j.properties
install -m 644 src/config/com/redhat/satellite/search/db/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/classes/com/redhat/satellite/search/db
install -m 755 src/config/rhn-search $RPM_BUILD_ROOT/%{_sysconfdir}/init.d
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT/%{_bindir}/rhnsearchd
install -m 644 src/config/search/rhn_search.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/search/rhn_search.conf
install -m 644 src/config/search/rhn_search_daemon.conf $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/search/rhn_search_daemon.conf

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755, root, root) %{_var}/log/rhn/search
%{_prefix}/share/rhn/search/lib/*
%{_prefix}/share/rhn/search/classes/log4j.properties
%{_prefix}/share/rhn/search/classes/com/*
%attr(755, root, root) %{_prefix}/share/rhn/search/indexes
%attr(755, root, root) %{_sysconfdir}/init.d/rhn-search
%attr(755, root, root) %{_bindir}/rhnsearchd
%config(noreplace) %{_sysconfdir}/rhn/search/rhn_search.conf
%config(noreplace) %{_sysconfdir}/rhn/search/rhn_search_daemon.conf

%changelog
* Tue Sep  2 2008 Jesus Rodriguez
- tagged for rebuild
- includes errata search capability

* Mon Aug 11 2008 Jesus Rodriguez 0.1.2-1
- tagged for rebuild after rename, also bumping version

* Tue Aug  5 2008 Jan Pazdziora 0.1.2-0
- tagged for rebuild after rename, also bumping version

* Mon Aug  4 2008 Jan Pazdziora 0.1.1-0
- rebuilt with BuildRequires: java-devel >= 1.5.0
