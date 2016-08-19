%if 0%{?suse_version}
%global apachedocroot /srv/www/htdocs
%else
%global apachedocroot %{_var}/www/html
%endif

Name:           jquery-ui
Version:        1.10.4.custom
Release:        3%{?dist}
Summary:        jQuery UI is a curated set of user interface elements built on top of the jQuery JavaScript Library.

Group:          Applications/Internet
License:        MIT
URL:            http://jqueryui.com/
# The source zip can be downloaded from the following URL:
# http://jqueryui.com/download/#!version=1.10.4&components=1110000010000000000000000000000000&filename=%{name}-%{version}.zip
Source0:        %{name}-%{version}.zip
%if 0%{?suse_version}
BuildRequires:  unzip
%endif
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
jQuery UI is a curated set of user interface interactions, effects, widgets, and themes built on top of the jQuery JavaScript Library. Whether you're building highly interactive web applications or you just need to add a date picker to a form control, jQuery UI is the perfect choice.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{apachedocroot}/javascript
install -m 644 js/%{name}-%{version}.min.js %{buildroot}%{apachedocroot}/javascript/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{apachedocroot}/javascript/*
%if 0%{?suse_version}
%dir %{apachedocroot}/javascript
%endif


%changelog
* Tue May 10 2016 Grant Gainey 1.10.4.custom-3
- jquery-ui: build on openSUSE

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 1.10.4.custom-2
- fix jquery-ui source url

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 1.10.4.custom-1
- initial jquery-ui build

