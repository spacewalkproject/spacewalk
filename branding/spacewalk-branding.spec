Name:		spacewalk-branding
Version:    0.2
Release:	1%{?dist}
Summary:	Spacewalk branding data.

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk/
Source0:	%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

#BuildRequires:
Requires:	rhn-html

%description


%prep
%setup -q


#%build
#%configure
#make %{?_smp_mflags}


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/var/www/html/css
install -m 644 -t %{buildroot}/var/www/html/css css/*


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
#%doc


%changelog
* Tue Jul 29 2008  0.2-1
- Initial packaging.

