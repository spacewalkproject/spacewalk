%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: proxy
Summary: Red Hat Network Proxy Server Installer
Group: RHN/Server
License: RHN Subscription License
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
Source0: %{name}-%{version}.tar.gz
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch

Summary: Command Line Installer of Red Hat Network Proxy Server
Group: RHN/Server
Requires: rhns-proxy-management >= %{version}
Requires: rhncfg-client
Requires: rhncfg
Requires: rhncfg-management
Requires: rhncfg-actions

%define defaultdir /usr/share/doc/proxy/conf-template/

%description
Command Line Installer of Red Hat Network Proxy Server.

Run configure-proxy.sh after installation to configure proxy.

%prep
%define build_sub_dir %(echo %{main_source} | sed 's/\.tar\.gz$//')
%setup -n %build_sub_dir
cp %{SOURCE1} .

#%build
#make

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/sbin
install -m 755 -d $RPM_BUILD_ROOT%{defaultdir}
install -m 644 c2s.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 sm.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 cluster.ini $RPM_BUILD_ROOT%{defaultdir}
install -m 644 squid.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 755 configure-proxy.sh $RPM_BUILD_ROOT/usr/sbin

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{defaultdir}
%{defaultdir}/c2s.xml
%{defaultdir}/sm.xml
%{defaultdir}/cluster.ini
%{defaultdir}/squid.conf
/usr/sbin/configure-proxy.sh

%changelog
* Tue Jun 17 2008 Miroslav Suchy <msuchy@redhat.com>
- initial version

