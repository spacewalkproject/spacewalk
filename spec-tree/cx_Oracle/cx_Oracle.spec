%define name cx_Oracle
%define version 5.0.4
%define release 1

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

%description
Python interface to Oracle conforming to the Python DB API 2.0 specification.
See http://www.python.org/topics/database/DatabaseAPI-2.0.html.

%prep
%setup

%build
env CFLAGS="$RPM_OPT_FLAGS" %{__python} setup.py build

%install
%{__python} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)
%doc LICENSE.txt README.txt BUILD.txt HISTORY.txt html samples test
