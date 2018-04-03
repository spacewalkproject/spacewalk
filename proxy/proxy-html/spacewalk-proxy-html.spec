%if 0%{?suse_version}
%global htmldir /srv/www/htdocs
%else
%global htmldir %{_var}/www/html
%endif

Name: spacewalk-proxy-html
Summary: The HTML component for Spacewalk Proxy
Version: 2.9.0
Release: 1%{?dist}
License: GPLv2
URL:     https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
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
install -m 755 -d $RPM_BUILD_ROOT%{htmldir}
install -m 755 -d $RPM_BUILD_ROOT%{htmldir}/_rhn_proxy
install -m 644 _rhn_proxy/* $RPM_BUILD_ROOT%{htmldir}/_rhn_proxy/

%clean

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
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.2-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 2.7.1-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Bumping package versions for 2.7.
- Bumping package versions for 2.6.

* Fri May 20 2016 Grant Gainey 2.5.1-1
- spacewalk-proxy-html: build on openSUSE
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

