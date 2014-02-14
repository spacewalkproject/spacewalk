Name:           bootstrap-datepicker
Version:        1.3.0
Release:        2%{?dist}
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
install -d -m 755 %{buildroot}%{_var}/www/html/css
install -d -m 755 %{buildroot}%{_var}/www/html/javascript
install -m 644 js/bootstrap-datepicker.js %{buildroot}%{_var}/www/html/javascript/
install -m 644 css/datepicker3.css %{buildroot}%{_var}/www/html/css/bootstrap-datepicker.css 

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_var}/www/html/css/*
%{_var}/www/html/javascript/*



%changelog
* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.0-2
- added missing directory

* Fri Feb 14 2014 Michael Mraka <michael.mraka@redhat.com> 1.3.0-1
- initial build of bootstrap-datepicker

