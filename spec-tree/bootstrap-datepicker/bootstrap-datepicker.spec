%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           bootstrap-datepicker
Version:        1.3.0
Release:        4%{?dist}
Summary:        Bootstrap-datepicker provides a flexible datepicker widget in the Twitter bootstrap style.

License:        Apache Software License v2
URL:            https://github.com/eternicode/bootstrap-datepicker/
Source0:        https://github.com/eternicode/bootstrap-datepicker/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz
BuildArch:      noarch

%description
Bootstrap-datepicker provides a flexible datepicker widget in the Twitter bootstrap
style.


%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apachedocroot}/css
install -d -m 755 %{buildroot}%{apachedocroot}/javascript
install -m 644 js/bootstrap-datepicker.js %{buildroot}%{apachedocroot}/javascript/
install -m 644 css/datepicker3.css %{buildroot}%{apachedocroot}/css/bootstrap-datepicker.css

%clean
rm -rf %{buildroot}


%files
%{apachedocroot}/css/*
%{apachedocroot}/javascript/*
%if 0%{?suse_version}
%dir %{apachedocroot}/css
%dir %{apachedocroot}/javascript
%endif


%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.3.0-4
- removed %%%%defattr from specfile
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue May 10 2016 Grant Gainey 1.3.0-3
- bootstrap-datepicker: build on openSUSE

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.0-2
- added missing directory

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.0-1
- initial build of bootstrap-datepicker

