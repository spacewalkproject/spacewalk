Name:       spacewalk-branding
Version:    0.2
Release:    4%{?dist}
Summary:    Spacewalk branding data

Group:      Applications/Internet
License:    GPLv2
URL:        https://fedorahosted.org/spacewalk/
Source0:    %{name}-%{version}.tar.gz
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:  noarch

Requires:   spacewalk-html


%description
Spacewalk specific branding, CSS, and images.


%prep
%setup -q


%build


%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}/%{_var}/www/html
cp -R css %{buildroot}/%{_var}/www/html/
cp -R img %{buildroot}/%{_var}/www/html/


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%dir /%{_var}/www/html/css
/%{_var}/www/html/css/*
%dir /%{_var}/www/html/img
/%{_var}/www/html/img/*


%changelog
* Mon Aug 04 2008  Miroslav Suchy <msuchy@redhat.com>
- fix dependecies

* Wed Jul 30 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-2
- Adding images.

* Tue Jul 29 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-1
- Initial packaging.

