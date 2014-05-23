Name:           momentjs
Version:        2.6.0
Release:        0%{?dist}
Summary:        A javascript date library for parsing, validating, manipulating, and formatting dates

Group:          Development/Libraries
License:        MIT
URL:            http://momentjs.com/

Source0:        http://momentjs.com/downloads/moment-with-langs.js
Source1:        http://momentjs.com/downloads/moment-with-langs.min.js
Source2:        http://momentjs.com/downloads/moment.min.js

Source3:        httpd-momentjs.conf
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
A javascript date library for parsing, validating, manipulating, and formatting dates.

%prep

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_sysconfdir}/httpd/conf.d
install -d -m 755 %{buildroot}%{_datadir}/momentjs

install -m 644 %{SOURCE0} %{buildroot}%{_datadir}/momentjs/moment-with-langs.js
install -m 644 %{SOURCE1} %{buildroot}%{_datadir}/momentjs/moment-with-langs.min.js
install -m 644 %{SOURCE2} %{buildroot}%{_datadir}/momentjs/moment.min.js

install -m 644 %{SOURCE3} %{buildroot}%{_sysconfdir}/httpd/conf.d/momentjs.conf


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_sysconfdir}/httpd/conf.d/momentjs.conf
%{_datadir}/momentjs/


%changelog
