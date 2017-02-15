%if 0%{?rhel} && 0%{?rhel} < 6
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%endif

%if 0%{?fedora} >= 23
%{!?python3_sitelib: %global python_sitelib %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%endif

%global pythonrhnroot %{python_sitelib}/spacewalk

Name:	    spacewalk-usix
Version:	2.7.1
Release:	1%{?dist}
Summary:	Spacewalk server and client nano six library

Group:		Applications/Internet
License:	GPLv2
URL:		  https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Provides:	spacewalk-backend-usix = %{version}-%{release}
Obsoletes: spacewalk-backend-usix < 2.8

%description
Library for writing code that runs on Python 2 and 3

%prep
%setup -q


%build
%define debug_package %{nil}

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT%{pythonrhnroot}/common
install -m 0644 usix.py* $RPM_BUILD_ROOT%{pythonrhnroot}/common/usix.py

%clean
rm -rf $RPM_BUILD_ROOT

%files
%dir %{pythonrhnroot}
%dir %{pythonrhnroot}/common
%{pythonrhnroot}/common/usix.py*


%changelog

