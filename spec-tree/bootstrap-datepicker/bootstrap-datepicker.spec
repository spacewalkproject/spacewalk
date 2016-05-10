%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           bootstrap-datepicker
Version:        1.3.0
Release:        3%{?dist}
Summary:        Bootstrap-datepicker provides a flexible datepicker widget in the Twitter bootstrap style.

Group:          Applications/Internet
License:        Apache Software License v2
URL:            https://github.com/eternicode/bootstrap-datepicker/
Source0:        https://github.com/eternicode/bootstrap-datepicker/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
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
%defattr(-,root,root,-)
%{apachedocroot}/css/*
%{apachedocroot}/javascript/*
%if 0%{?suse_version}
%dir %{apachedocroot}/css
%dir %{apachedocroot}/javascript
%endif


%changelog
* Tue May 10 2016 Grant Gainey 1.3.0-3
- bootstrap-datepicker: build on openSUSE

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.0-2
- added missing directory

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.0-1
- initial build of bootstrap-datepicker

