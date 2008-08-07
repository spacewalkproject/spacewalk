%{!?__redhat_release:%define __redhat_release UNKNOWN}

Name: spacewalk-proxy-html
Summary: The HTML component for Spacewalk Proxy
Group: RHN/Server
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Version: 0.1
Release: 1%{?dist}
BuildRoot: /var/tmp/%{name}-%{version}-root
BuildArch: noarch

Requires: httpd

%define htmldir /var/www/html

%description
This package contains placeholder html pages, which the Spacewalk Server
display, if you navigate to it using your browser.

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
* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com>
- rename to spacewalk-proxy-html

* Wed Jul 30 2008 Jan Pazdziora
- discontinue the use of external version file

* Thu May 15 2008 Miroslav Suchy <msuchy@redhat.com> 5.2.0-5
- Fix attr of files

* Fri Apr 11 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

