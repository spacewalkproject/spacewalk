%define name cx_Oracle
%define version 5.0.4
%define release 1

# different arches have differnet oracle versions
%define oracleicname instantclient
%ifarch ppc ppc64
%define oraclever 10.2.0.2
%define oracleicver %{oraclever}
%else
%ifarch ia64
%define oraclever 10.2.0.3
%define oracleicver %{oraclever}
%else
%define oraclever 11.2
%define oracleicname instantclient%{oraclever}
%define oracleicver 11.2.0.2.0
%endif
%endif

Summary: Python interface to Oracle
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
Source0: %{name}-%{version}.tar.gz
License: Python Software Foundation License
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
Vendor: Anthony Tuininga <anthony.tuininga@gmail.com>
Url: http://cx-oracle.sourceforge.net
AutoReq: 0
Provides: python(:DBAPI:oracle) = 2.0
BuildRequires: python-devel
BuildRequires: oracle-%{oracleicname}-devel
Requires: oracle-%{oracleicname}-basic = %{oracleicver}

%description
Python interface to Oracle conforming to the Python DB API 2.0 specification.
See http://www.python.org/topics/database/DatabaseAPI-2.0.html.

%prep
%setup

#kinda ugly but we need ORACLE_HOME to be set
%if "%{_lib}" == "lib64"
%define oracle_home /usr/lib/oracle/%{oraclever}/client64
%else
%define oracle_home /usr/lib/oracle/%{oraclever}/client
%endif

%build
export ORACLE_HOME=%{oracle_home}
env CFLAGS="$RPM_OPT_FLAGS" %{__python} setup.py build

%install
export ORACLE_HOME=%{oracle_home}
%{__python} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)
%doc LICENSE.txt README.txt BUILD.txt HISTORY.txt html samples test

%changelog
* Fri Jan 07 2011 Jan Pazdziora <jpazdziora@redhat.com> 5.0.4-1
- cx_Oracle 5.0.4 with Oracle InstantClient 11g

