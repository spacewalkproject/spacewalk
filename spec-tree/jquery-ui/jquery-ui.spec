Name:           jquery-ui
Version:        1.10.4.custom
Release:        0%{?dist}
Summary:        jQuery UI is a curated set of user interface elements built on top of the jQuery JavaScript Library.

Group:          Applications/Internet
License:        MIT
URL:            http://jqueryui.com/
Source0:        http://jqueryui.com/download/#!version=1.10.4&components=1110000010000000000000000000000000&filename=%{name}-%{version}.zip
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:      noarch

%description
jQuery UI is a curated set of user interface interactions, effects, widgets, and themes built on top of the jQuery JavaScript Library. Whether you're building highly interactive web applications or you just need to add a date picker to a form control, jQuery UI is the perfect choice.

%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_var}/www/html/javascript
install -m 644 js/%{name}-%{version}.min.js %{buildroot}%{_var}/www/html/javascript/

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_var}/www/html/javascript/*



%changelog
