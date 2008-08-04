%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: spacewalk-search
Summary: Spacewalk Full Text Search Server
Group: Applications/Internet
License: GPLv2
Version: 0.1.1
Release: 0%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd search-server
# make test-srpm
URL:       https://fedorahosted.org/spacewalk 
Source0:   %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch

Summary: Java web application files for Spacewalk
Group: Applications/Internet
Requires: tanukiwrapper
Requires: jpackage-utils >= 0:1.5
BuildRequires: ant
BuildRequires: tanukiwrapper
BuildRequires: java-devel >= 1.5.0
%description
This package contains the code for the Java version of the Spacewalk Web Site.

%prep
%setup

%install
ant -Djar.version=%{version} all
rm -f lib/tanukiwrapper-3.1.2.jar
install -d -m 755 $RPM_BUILD_ROOT/%{_sysconfdir}/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/indexes
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/classes/com/redhat/satellite/search/db
install -d -m 755 $RPM_BUILD_ROOT/etc/init.d
install -d -m 755 $RPM_BUILD_ROOT/${_bindir}
install -d -m 755 $RPM_BUILD_ROOT/%{_var}/log/rhn/search
install -d -m 755 $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/nutch

install -m 644 dist/%{name}-%{version}.jar $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib/
install -m 644 lib/* $RPM_BUILD_ROOT/%{_prefix}/share/rhn/search/lib
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
* Mon Aug  4 2008 Jan Pazdziora 0.1.1-0
- rebuilt with BuildRequires: java-devel >= 1.5.0

