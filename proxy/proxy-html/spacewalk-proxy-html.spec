Name: spacewalk-proxy-html
Summary: The HTML component for Spacewalk Proxy
Group:   Applications/Internet
License: GPLv2
URL:     https://fedorahosted.org/spacewalk 
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 0.7.0
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch
Obsoletes: rhns-proxy-html < 5.3.0
Provides: rhns-proxy-html = 5.3.0
Requires: httpd

%define htmldir %{_var}/www/html

%description
This package contains placeholder html pages, which the Spacewalk Server
display, if you navigate to it using your browser.

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -m 755 -d $RPM_BUILD_ROOT%{htmldir}
install -m 755 -d $RPM_BUILD_ROOT%{htmldir}/_rhn_proxy
install -m 644 _rhn_proxy/* $RPM_BUILD_ROOT%{htmldir}/_rhn_proxy/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{htmldir}/_rhn_proxy
%config %{htmldir}/_rhn_proxy/index.html
%{htmldir}/_rhn_proxy/*.ico
%{htmldir}/_rhn_proxy/*.png
%doc LICENSE

%changelog
* Mon Dec  8 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.2-1
- fixed Obsoletes: rhns-* < 5.3.0

* Wed Nov  5 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.1-1
- rebuild due BZ 470009
- point Source0 to real url
- fix obsoletes
- added LICENSE

* Mon Sep  8 2008 Miroslav Suchy <msuchy@redhat.com> 0.2-1
- change graphics to Spacewalk style

* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-2
- rename to spacewalk-proxy-html

* Wed Jul 30 2008 Jan Pazdziora
- discontinue the use of external version file

* Thu May 15 2008 Miroslav Suchy <msuchy@redhat.com> 5.2.0-5
- Fix attr of files

* Fri Apr 11 2008 Miroslav Suchy <msuchy@redhat.com>
- Isolate from rhns-proxy

