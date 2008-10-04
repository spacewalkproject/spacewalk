Name: spacewalk-proxy-installer
Summary: Spacewalk Proxy Server Installer
Group:   Applications/Internet
License: GPLv2
Version: 0.3.1
Release: 1%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd proxy/installer
# make srpm
URL:            https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch

Summary: Command Line Installer of Spacewalk Proxy Server
Group:    Applications/Internet
Requires: rhncfg-client
Requires: rhncfg
Requires: rhncfg-management
Requires: rhncfg-actions
Requires: glibc-common
BuildRequires: /usr/bin/docbook2man
Obsoletes: rhns-proxy <= 5.2

%define defaultdir %{_usr}/share/doc/proxy/conf-template/

%description
The Spacewalk Proxy Server allows package proxying/caching
and local package delivery services for groups of local servers from
Spacewalk Server. This service adds flexibility and economy of
resources to package update and deployment.

This package includes command line installer of Spacewalk Proxy Server.
Run configure-proxy.sh after installation to configure proxy.

%prep
%setup -q

%build
/usr/bin/docbook2man rhn-proxy-activate.sgml
/usr/bin/gzip rhn-proxy-activate.8

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
mkdir -p $RPM_BUILD_ROOT/%{_mandir}/man8
mkdir -p $RPM_BUILD_ROOT/%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT/%{_usr}/share/rhn/installer
install -m 755 -d $RPM_BUILD_ROOT%{defaultdir}
install -m 644 c2s.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 sm.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 cluster.ini $RPM_BUILD_ROOT%{defaultdir}
install -m 644 squid.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 rhn.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 755 configure-proxy.sh $RPM_BUILD_ROOT/%{_usr}/sbin
install -m 755 rhn-proxy-activate $RPM_BUILD_ROOT%{_bindir}
install rhn_proxy_activate.py $RPM_BUILD_ROOT%{_usr}/share/rhn/installer
install __init__.py $RPM_BUILD_ROOT%{_usr}/share/rhn/installer/
install rhn-proxy-activate.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{defaultdir}
%{defaultdir}/c2s.xml
%{defaultdir}/sm.xml
%{defaultdir}/cluster.ini
%{defaultdir}/squid.conf
%{defaultdir}/rhn.conf
%{_usr}/sbin/configure-proxy.sh
%{_mandir}/man8/rhn-proxy-activate.8.gz
%dir %{_usr}/share/rhn/installer
%{_usr}/share/rhn/installer/__init__.py*
%{_usr}/share/rhn/installer/rhn_proxy_activate.py*
%{_bindir}/rhn-proxy-activate

%changelog
* Wed Oct  1 2008 Miroslav Suchý <msuchy@redhat.com> 0.3.1-1
- move rhn-proxy-activate to installer

* Tue Sep  9 2008 Miroslav Suchý 0.2.3-1
- replace certs in ssl.conf

* Thu Sep  4 2008 Miroslav Suchý 0.2.2-1
- add SSL support
- add " around params

* Tue Sep  2 2008 Milan Zazrivec 0.2.1-1
- Fixed package requirements

* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-2
- rename to spacewalk-proxy-installer
- rewrite %%description

* Tue Aug  6 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-1
- rename to spacewalk
- clean up spec

* Tue Jun 17 2008 Miroslav Suchy <msuchy@redhat.com>
- initial version

