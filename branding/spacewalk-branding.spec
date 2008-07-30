Name:		spacewalk-branding
Version:    0.2
Release:	2%{?dist}
Summary:	Spacewalk branding data.

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk/
Source0:	%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:	rhn-html


%description
Spacewalk specific branding, CSS, and images.


%prep
%setup -q


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/var/www/html
cp -R css %{buildroot}/var/www/html/
cp -R img %{buildroot}/var/www/html/
#chmod -R 644 %{buildroot}/var/www/html/


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
#%doc
%dir /var/www/html/css
/var/www/html/css/*
%dir /var/www/html/img
/var/www/html/img/*


%changelog
* Wed Jul 30 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-2
- Adding images.

* Tue Jul 29 2008  Devan Goodwin <dgoodwin@redhat.com> 0.2-1
- Initial packaging.

