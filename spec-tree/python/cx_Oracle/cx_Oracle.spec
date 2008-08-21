Summary: Python interface to Oracle
Name: cx_Oracle
Version:        4.2
Release:        1%{?dist}
Source0: %{name}-%{version}.tar.gz
Patch0: %{name}-instantclient.patch
License: BSD-style
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-buildroot
Prefix: %{_prefix}
Obsoletes: DCOracle
Provides: python(:DBAPI:oracle) = 2.0
BuildRequires: python-devel
BuildRequires: oracle-instantclient-devel
Url: http://sourceforge.net/projects/cx-oracle/

%description
Python interface to Oracle conforming to the Python DB API 2.0 specification.
See http://www.python.org/topics/database/DatabaseAPI-2.0.html.

%prep
%setup
%patch0 -p0 -b .instantclient

%build
env CFLAGS="$RPM_OPT_FLAGS" FORCE_RPATH=1 %{__python} setup.py build

%install
%{__python} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%clean
rm -rf $RPM_BUILD_ROOT

%files -f INSTALLED_FILES
%defattr(-,root,root)
%doc LICENSE.txt README.txt HISTORY.txt html test

%changelog
* Wed Aug 21 2008 Mike McCune <mmccune@redhat.com> 4.2.1
- Migrating to git and new Makefile structure
* Tue Jan 29 2008 Michael Mraka <michael.mraka@redhat.com> 4.2.1
- Updated to 4.2.1
- Adapted for oracle-instantclient
* Mon Jan 16 2006 Mihai Ibanescu <misa@redhat.com> 4.1.2-0
- Updated to 4.1.2
* Thu Aug 12 2004 Mihai Ibanescu <misa@redhat.com> 4.0.1-1.8
- Memory leak patched
* Tue Jun 29 2004 Mihai Ibanescu <misa@redhat.com> 4.0.1-1.5
- Patched to resize variables when executemany() is called
* Wed May 19 2004 Mihai Ibanescu <misa@redhat.com> 4.0.1-1.4
- Provides python(:DBAPI:oracle) = 2.0
