%if 0%{?rhel} && 0%{?rhel} < 6
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%endif

%if 0%{?fedora} >= 23
%{!?python3_sitelib: %global python3_sitelib %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%global python3rhnroot %{python3_sitelib}/spacewalk
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
BuildArch: noarch

Provides:	spacewalk-backend-usix = %{version}-%{release}
Obsoletes: spacewalk-backend-usix < 2.8
BuildRequires: python-devel

%description
Library for writing code that runs on Python 2 and 3

%if 0%{?fedora} >= 23

%package -n python3-%{name}
Summary: Spacewalk client micro six library
Group: Applications/Internet
Provides: python3-spacewalk-backend-usix = %{version}-%{release}
Obsoletes: python3-spacewalk-backend-usix < 2.8
BuildRequires: python3-devel

%description -n python3-%{name}
Library for writing code that runs on Python 2 and 3

%endif

%prep
%setup -q


%build
%define debug_package %{nil}

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT%{pythonrhnroot}/common
install -m 0644 usix.py* $RPM_BUILD_ROOT%{pythonrhnroot}/common/usix.py

%if 0%{?fedora} && 0%{?fedora} >= 23
install -d $RPM_BUILD_ROOT%{python3rhnroot}/common
cp $RPM_BUILD_ROOT%{pythonrhnroot}/common/usix.py $RPM_BUILD_ROOT%{python3rhnroot}/common
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%check
%if 0%{?fedora} && 0%{?fedora} >= 23
rm -r -f $RPM_BUILD_ROOT%{python3rhnroot}/__pycache__
rm -r -f $RPM_BUILD_ROOT%{python3rhnroot}/common/__pycache__
%endif

%files
%dir %{pythonrhnroot}
%dir %{pythonrhnroot}/common
%{pythonrhnroot}/common/usix.py*

%if 0%{?fedora} && 0%{?fedora} >= 23

%files -n python3-%{name}
%dir %{python3rhnroot}
%dir %{python3rhnroot}/common
%{python3rhnroot}/common/usix.py*
%endif

%changelog
* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.1-1
- new package built with tito


