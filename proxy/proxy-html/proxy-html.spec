%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: rhns-proxy-html
Summary: The HTML component for Red Hat Network Proxy
Group: RHN/Server
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch

Requires: httpd

%define htmldir /var/www/html

%description
This package contains the files needed by the Red Hat Network Server.

%prep
%setup -q

%install
install -m 755 -d $RPM_BUILD_ROOT%{htmldir}
install -m 755 -d $RPM_BUILD_ROOT%{htmldir}/_rhn_proxy
install -m 644 _rhn_proxy/* $RPM_BUILD_ROOT%{htmldir}/_rhn_proxy/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,apache)
%attr(755,-,-) %dir %{htmldir}
%attr(755,-,-) %dir %{htmldir}/_rhn_proxy
%attr(644,-,-) %config %{htmldir}/_rhn_proxy/index.html
%attr(644,-,-) %{htmldir}/_rhn_proxy/*.ico
%attr(644,-,-) %{htmldir}/_rhn_proxy/*.png

# $Id: proxy.spec,v 1.290 2007/08/08 07:03:05 msuchy Exp $
%changelog
* Thu May 15 2008 Miroslav Suchy <msuchy@redhat.com> 5.2.0-5
- Fix attr of files

* Fri Apr 11 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

