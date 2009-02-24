%{!?python_sitearch: %define python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(1)")}

# different arches have differnet oracle versions
%ifarch s390 s390x
%define oraclever 10.2.0.2
%else
%define oraclever 10.2.0.4
%endif

Summary: Python interface to Oracle
Name: cx_Oracle
Version: 4.2.1
Release: 6%{?dist}
Source0: %{name}-%{version}.tar.gz
Patch0: cx_Oracle-instantclient.patch
License: BSD-style
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-buildroot
Obsoletes: DCOracle
Provides: python(:DBAPI:oracle) = 2.0
BuildRequires: python-devel
BuildRequires: oracle-instantclient-devel
Url: http://sourceforge.net/projects/cx-oracle/

%description
Python interface to Oracle conforming to the Python DB API 2.0 specification.
See http://www.python.org/topics/database/DatabaseAPI-2.0.html.

%prep
%setup -q
%patch0 -p1 -b .instantclient

#kinda ugly but we need ORACLE_HOME to be set
%if "%{_lib}" == "lib64"
%define oracle_home /usr/lib/oracle/%{oraclever}/client64/
%else
%define oracle_home /usr/lib/oracle/%{oraclever}/client/
%endif

%build
export ORACLE_HOME=%{oracle_home}
env CFLAGS="$RPM_OPT_FLAGS" FORCE_RPATH=1 %{__python} setup.py build

%install
rm -rf $RPM_BUILD_ROOT
export ORACLE_HOME=%{oracle_home}
%{__python} setup.py install --root=$RPM_BUILD_ROOT 

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc LICENSE.txt README.txt HISTORY.txt html test
%{python_sitearch}/*

%changelog
* Wed Feb 18 2009 Dennis Gilmore <dennis@ausil.us> 4.2.1-6
- define oraclever since different arches have different versions of oracle

* Fri Oct 24 2008 Milan Zazrivec 4.2.1-5
- bumping release to be above the one in spacewalk 0.2

* Mon Aug 25 2008 Dennis Gilmore <dgilmore@redhat.com> 4.2.1-2
- add disttag define ORACLE_HOME
- builds in koji
- setup %%files correctly 

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
