Name:           select2
Version:        3.4.5
Release:        0%{?dist}
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
install -d -m 755 %{buildroot}%{_var}/www/html/javascript/select2
install -m 644 select2.css %{buildroot}%{_var}/www/html/javascript/select2
install -m 644 select2.js %{buildroot}%{_var}/www/html/javascript/select2
install -m 644 select2.png %{buildroot}%{_var}/www/html/javascript/select2
install -m 644 select2-spinner.gif %{buildroot}%{_var}/www/html/javascript/select2
install -m 644 select2x2.png %{buildroot}%{_var}/www/html/javascript/select2

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_var}/www/html/javascript/select2
%{_var}/www/html/javascript/select2/*


%changelog
