
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
%define oracleicver 11.2.0.4.0
%endif
%endif


Summary: Python interface to Oracle
Name: cx_Oracle
Version: 5.3
Release: 5%{?dist}
Source0: https://github.com/oracle/python-%{name}/archive/%{version}.tar.gz#/python-%{name}-%{version}.tar.gz
License: Python Software Foundation License
Prefix: %{_prefix}
Url: http://cx-oracle.sourceforge.net
AutoReq: 0
Provides: python(:DBAPI:oracle) = 2.0
BuildRequires: python2-rpm-macros
BuildRequires: python2-devel
BuildRequires: gcc
BuildRequires: oracle-%{oracleicname}-devel
Requires: oracle-%{oracleicname}-basic = %{oracleicver}

%description
Python interface to Oracle conforming to the Python DB API 2.0 specification.
See http://www.python.org/topics/database/DatabaseAPI-2.0.html.

%prep
%setup -n python-%{name}-%{version}

#kinda ugly but we need ORACLE_HOME to be set
%if "%{_lib}" == "lib64"
%define oracle_home /usr/lib/oracle/%{oraclever}/client64
%else
%define oracle_home /usr/lib/oracle/%{oraclever}/client
%endif

%build
export ORACLE_HOME=%{oracle_home}
env CFLAGS="$RPM_OPT_FLAGS" %{__python2} setup.py build

%install
export ORACLE_HOME=%{oracle_home}
%{__python2} setup.py install --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%clean

%files -f INSTALLED_FILES
%doc LICENSE.txt README.txt BUILD.txt samples test

%changelog
* Tue Oct 01 2019 Michael Mraka <michael.mraka@redhat.com> 5.3-5
- we can use python2 packages and macros everywhere

* Tue Nov 13 2018 Michael Mraka <michael.mraka@redhat.com> 5.3-4
- gcc is not in default buildroot anymore

* Tue Nov 13 2018 Michael Mraka <michael.mraka@redhat.com> 5.3-3
- explicit use of python2 for Fedora 29+

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 5.3-2
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Jun 07 2017 Michael Mraka <michael.mraka@redhat.com> 5.3-1
- rebased to latest stable version

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 5.1.2-5
- we need to use the exact oracle instantclient version

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 5.1.2-4
- do not require exact version of oracle instantclient
- fixed tito build warning
- replace legacy name of Tagger with new one

* Fri Mar 15 2013 Michael Mraka <michael.mraka@redhat.com> 5.1.2-3
- fixed builder definition

* Mon Oct 22 2012 Michael Mraka
- Use the ReleaseTagger.
- rebuild with correct vendor

* Mon Oct 08 2012 Jan Pazdziora 5.1.2-1
- Rebase to cx_Oracle 5.1.2.

* Mon Oct 08 2012 Jan Pazdziora 5.0.4-2
- Require latest greatest oracle-instantclient11.2-*.
- %%defattr is not needed since rpm 4.4

* Fri Jan 07 2011 Jan Pazdziora <jpazdziora@redhat.com> 5.0.4-1
- cx_Oracle 5.0.4 with Oracle InstantClient 11g

