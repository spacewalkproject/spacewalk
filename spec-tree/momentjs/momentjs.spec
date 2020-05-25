%if 0%{?suse_version}
%global apacheconfd %{_sysconfdir}/apache2/conf.d
%else
%global apacheconfd %{_sysconfdir}/httpd/conf.d
%endif

Name:           momentjs
Version:        2.6.0
Release:        7%{?dist}
Summary:        A javascript date library for parsing, validating, manipulating, and formatting dates

License:        MIT
URL:            http://momentjs.com/

Source0:        https://raw.githubusercontent.com/moment/moment/%{version}/min/moment-with-langs.js 
Source1:        https://raw.githubusercontent.com/moment/moment/%{version}/min/moment-with-langs.min.js
Source2:        https://raw.githubusercontent.com/moment/moment/%{version}/min/moment.min.js

Source3:        https://raw.githubusercontent.com/spacewalkproject/spacewalk/momentjs-%{version}-6/spec-tree/momentjs/httpd-momentjs.conf

%if 0%{?suse_version}
Requires(pre):  apache2
%endif
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
%{apacheconfd}/momentjs.conf
%{_datadir}/momentjs


%changelog
* Mon May 25 2020 Michael Mraka <michael.mraka@redhat.com> 2.6.0-7
- Updated source url

* Wed Mar 11 2020 Stefan Bluhm <stefan.bluhm@clacee.eu> 2.6.0-6
- Updated momentjs SourceX links.

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.6.0-5
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue May 10 2016 Grant Gainey 2.6.0-4
- momentjs: build on openSUSE

* Fri Jan 16 2015 Matej Kollar <mkollar@redhat.com> 2.6.0-3
- Fix copy&paste error in httpd config. This fixes 403 error in apache 2.4.

* Thu Jun 19 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.6.0-2
- add alias for momentjs

* Fri May 23 2014 Stephen Herr <sherr@redhat.com> 2.6.0-1
- new package built with tito

