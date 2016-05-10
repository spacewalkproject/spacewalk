%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           select2
Version:        3.4.5
Release:        3%{?dist}
Summary:        Select2 is a jQuery based replacement for select boxes.

Group:          Applications/Internet
License:        Apache Software License v2
URL:            http://ivaynberg.github.io/select2/
Source0:        https://github.com/ivaynberg/%{name}/archive/%{version}.tar.gz#/%{name}-%{version}.tar.gz
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
Select2 is a jQuery based replacement for select boxes. It supports searching, remote data sets, and infinite scrolling of results.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apachedocroot}/javascript/select2
install -m 644 select2.css %{buildroot}%{apachedocroot}/javascript/select2
install -m 644 select2.js %{buildroot}%{apachedocroot}/javascript/select2
install -m 644 select2.png %{buildroot}%{apachedocroot}/javascript/select2
install -m 644 select2-spinner.gif %{buildroot}%{apachedocroot}/javascript/select2
install -m 644 select2x2.png %{buildroot}%{apachedocroot}/javascript/select2

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{apachedocroot}/javascript/select2
%if 0%{?suse_version}
%dir %{apachedocroot}/javascript
%endif

%changelog
* Tue May 10 2016 Grant Gainey 3.4.5-3
- select2: build on openSUSE

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 3.4.5-2
- fix packaging warnings

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 3.4.5-1
- initial select2 build

