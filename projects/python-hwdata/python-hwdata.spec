Name:		python-hwdata
Version:	1.0
Release:	1%{?dist}
Summary:	Python bindings to hwdata package
BuildArch:  noarch
Group:		Development/Libraries
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: python-devel
Requires:	hwdata

%description
Provide python interface to database stored in hwdata package.
It allows you to get human readable description of USB and PCI devices.

%prep
%setup -q


%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{python_sitelib}
install -p -m 644 hwdata.py $RPM_BUILD_ROOT/%{python_sitelib}

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc LICENSE example.py
%doc html*
%{python_sitelib}/*


%changelog
* Fri Apr 23 2010 Miroslav Suchý <msuchy@redhat.com> 1.0-1
- initial release
