Name:           jquery-timepicker
Version:        1.3.3
Release:        1%{?dist}
Summary:        A lightweight, customizable jQuery timepicker plugin inspired by Google Calendar.

Group:          Applications/Internet
License:        Apache Software License v2
URL:            http://jonthornton.github.io/jquery-timepicker/
Source0:        https://github.com/jonthornton/jquery-timepicker/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
A lightweight, customizable jQuery timepicker plugin inspired by Google Calendar.


%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_var}/www/html/css
install -d -m 755 %{buildroot}%{_var}/www/html/javascript
install -m 644 jquery.timepicker.css %{buildroot}%{_var}/www/html/css/
install -m 644 jquery.timepicker.js %{buildroot}%{_var}/www/html/javascript/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_var}/www/html/css/*
%{_var}/www/html/javascript/*



%changelog
* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.3-1
- initial build of jquery-timepicker

