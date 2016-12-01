%if 0%{?suse_version}
%global htmldir /srv/www/htdocs
%else
%global htmldir %{_var}/www/html
%endif

Name: spacewalk-proxy-html
Summary: The HTML component for Spacewalk Proxy
Group:   Applications/Internet
License: GPLv2
URL:     https://fedorahosted.org/spacewalk 
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 2.7.0
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch
Obsoletes: rhns-proxy-html < 5.3.0
Provides: rhns-proxy-html = 5.3.0
Requires: httpd

%description
This package contains placeholder html pages, which the Spacewalk Server
displays, if you navigate to it using your browser.

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
%dir %{htmldir}/_rhn_proxy
%config %{htmldir}/_rhn_proxy/index.html
%{htmldir}/_rhn_proxy/*.ico
%{htmldir}/_rhn_proxy/*.png
%doc LICENSE
%if 0%{?suse_version}
%dir %dir %{htmldir}/_rhn_proxy
%endif

%changelog
* Fri May 20 2016 Grant Gainey 2.5.1-1
- spacewalk-proxy-html: build on openSUSE
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Mon Mar 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- %%defattr is not needed since rpm 4.4

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Wed Nov 18 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.2-1
- 494292 - use %%global instead of %%define

* Tue Nov 17 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.1-1
- 494292 - address issues with spec file during Fedora package review

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

