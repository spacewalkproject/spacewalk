%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           jquery-timepicker
Version:        1.3.3
Release:        2%{?dist}
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
install -d -m 755 %{buildroot}%{apachedocroot}/css
install -d -m 755 %{buildroot}%{apachedocroot}/javascript
install -m 644 jquery.timepicker.css %{buildroot}%{apachedocroot}/css/
install -m 644 jquery.timepicker.js %{buildroot}%{apachedocroot}/javascript/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{apachedocroot}/css/*
%{apachedocroot}/javascript/*
%if 0%{?suse_version}
%dir %{apachedocroot}/css
%dir %{apachedocroot}/javascript
%endif


%changelog
* Tue May 10 2016 Grant Gainey 1.3.3-2
- jquery-timepicker: build on openSUSE

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.3-1
- initial build of jquery-timepicker

