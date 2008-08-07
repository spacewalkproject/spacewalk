%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: spacewalk-proxy
Summary: Red Hat Network Proxy Server Installer
Group:   Applications/Internet
License: GPLv2
Version: 0.1
Release: 0%{?dist}
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd proxy/installer
# make test-srpm
URL:            https://fedorahosted.org/spacewalk
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch

Summary: Command Line Installer of Spacewalk Proxy Server
Group:    Applications/Internet
Requires: spacewalk-proxy-management >= %{version}
Requires: spacewalk-client
Requires: spacewalk-cfg
Requires: spacewalk-cfg-management
Requires: spacewalk-cfg-actions
Obsoletes: rhns-proxy <= 5.2

%define defaultdir %{_usr}/share/doc/proxy/conf-template/

%description
Command Line Installer of Spacewalk Proxy Server.

Run configure-proxy.sh after installation to configure proxy.

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_usr}/sbin
install -m 755 -d $RPM_BUILD_ROOT%{defaultdir}
install -m 644 c2s.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 sm.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 cluster.ini $RPM_BUILD_ROOT%{defaultdir}
install -m 644 squid.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 755 configure-proxy.sh $RPM_BUILD_ROOT/%{_usr}/sbin

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

%changelog
* Thu Aug  6 2008 Miroslav Suchy <msuchy@redhat.com>
- rename to spacewalk
- clean up spec

* Tue Jun 17 2008 Miroslav Suchy <msuchy@redhat.com>
- initial version

