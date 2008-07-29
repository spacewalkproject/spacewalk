%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: rhn-search
Summary: RHN Satellite Full Text Search Server
Group: Applications/Internet
License: GPLv2
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root
BuildArch: noarch

Summary: Java web application files for RHN
Group: Applications/Internet
Requires: tanukiwrapper
Requires: jpackage-utils >= 0:1.5
BuildRequires: ant
BuildRequires: tanukiwrapper
%description
This package contains the code for the Java version of the Red Hat
Network Web Site.

%prep
%setup

%install
ant -Djar.version=%{version} all
rm -f lib/tanukiwrapper-3.1.2.jar
install -d -m 755 $RPM_BUILD_ROOT/etc/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/search/indexes
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/search/lib
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/search/classes/com/redhat/satellite/search/db
install -d -m 755 $RPM_BUILD_ROOT/etc/init.d
install -d -m 755 $RPM_BUILD_ROOT/usr/bin
install -d -m 755 $RPM_BUILD_ROOT/var/log/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/usr/share/rhn/search/nutch

install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT/%{_usr}/share/rhn/search/lib/
install -m 644 lib/* $RPM_BUILD_ROOT/%{_usr}/share/rhn/search/lib
install -m 644 src/config/log4j.properties $RPM_BUILD_ROOT/%{_usr}/share/rhn/search/classes/log4j.properties
install -m 644 src/config/com/redhat/satellite/search/db/* $RPM_BUILD_ROOT/%{_usr}/share/rhn/search/classes/com/redhat/satellite/search/db
install -m 755 src/config/rhn-search $RPM_BUILD_ROOT/etc/init.d
ln -s -f /usr/sbin/tanukiwrapper $RPM_BUILD_ROOT/%{_usr}/bin/rhnsearchd
install -m 644 src/config/search/rhn_search.conf $RPM_BUILD_ROOT/etc/rhn/search/rhn_search.conf
install -m 644 src/config/search/rhn_search_daemon.conf $RPM_BUILD_ROOT/etc/rhn/search/rhn_search_daemon.conf

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%attr(755, root, root) %{_var}/log/rhn/search
%{_usr}/share/rhn/search/lib/*
%{_usr}/share/rhn/search/classes/log4j.properties
%{_usr}/share/rhn/search/classes/com/*
%attr(755, root, root) %{_usr}/share/rhn/search/indexes
%attr(755, root, root) %{_sysconfdir}/init.d/rhn-search
%attr(755, root, root) %{_usr}/bin/rhnsearchd
%config(noreplace) %{_sysconfdir}/rhn/search/rhn_search.conf
%config(noreplace) %{_sysconfdir}/rhn/search/rhn_search_daemon.conf
