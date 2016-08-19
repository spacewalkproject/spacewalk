%if 0%{?suse_version}
%global apacheconfd %{_sysconfdir}/apache2/conf.d
%else
%global apacheconfd %{_sysconfdir}/httpd/conf.d
%endif

Name:           momentjs
Version:        2.6.0
Release:        4%{?dist}
Summary:        A javascript date library for parsing, validating, manipulating, and formatting dates

Group:          Development/Libraries
License:        MIT
URL:            http://momentjs.com/

Source0:        http://momentjs.com/downloads/moment-with-langs.js
Source1:        http://momentjs.com/downloads/moment-with-langs.min.js
Source2:        http://momentjs.com/downloads/moment.min.js

Source3:        httpd-momentjs.conf

%if 0%{?suse_version}
Requires(pre):  apache2
%endif
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
A javascript date library for parsing, validating, manipulating, and formatting dates.

%prep

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apacheconfd}
install -d -m 755 %{buildroot}%{_datadir}/momentjs

install -m 644 %{SOURCE0} %{buildroot}%{_datadir}/momentjs/moment-with-langs.js
install -m 644 %{SOURCE1} %{buildroot}%{_datadir}/momentjs/moment-with-langs.min.js
install -m 644 %{SOURCE2} %{buildroot}%{_datadir}/momentjs/moment.min.js

install -m 644 %{SOURCE3} %{buildroot}%{apacheconfd}/momentjs.conf


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{apacheconfd}/momentjs.conf
%{_datadir}/momentjs


%changelog
* Tue May 10 2016 Grant Gainey 2.6.0-4
- momentjs: build on openSUSE

* Fri Jan 16 2015 Matej Kollar <mkollar@redhat.com> 2.6.0-3
- Fix copy&paste error in httpd config. This fixes 403 error in apache 2.4.

* Thu Jun 19 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.6.0-2
- add alias for momentjs

* Fri May 23 2014 Stephen Herr <sherr@redhat.com> 2.6.0-1
- new package built with tito

