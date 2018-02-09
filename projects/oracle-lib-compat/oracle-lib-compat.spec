Name:           oracle-lib-compat
Version:        11.2.0.16
Release:        1%{?dist}
Summary:        Compatibility package so that perl-DBD-Oracle will install
License:        GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone https://github.com/spacewalkproject/spacewalk.git
# cd spec-tree/oracle-lib-compat
# make srpm
URL:            https://github.com/spacewalkproject/spacewalk
Source0:	https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz

%define debug_package %{nil}

%ifarch s390 s390x
%define icversion 10.2.0.4
%define icdir %{icversion}
Requires:       oracle-instantclient-basic = %{icversion}
Requires:       oracle-instantclient-sqlplus = %{icversion}
%define soversion 10
%else
%define icversion 11.2.0.4.0
%define icdir 11.2
Requires:       oracle-instantclient11.2-basic = %{icversion}
Requires:       oracle-instantclient11.2-sqlplus = %{icversion}
%define soversion 11
%endif

Requires(post): ldconfig
Requires(post): /usr/bin/execstack
Requires(post): /usr/bin/file
Requires(post): /usr/bin/xargs

%ifarch x86_64
%define lib64 ()(64bit)
Requires:       libaio.so.1%{lib64}
%endif
Provides:       libocci.so.%{soversion}.1%{?lib64}   = %{icversion}
Provides:       libnnz%{soversion}.so%{?lib64}       = %{icversion}
Provides:       libocijdbc%{soversion}.so%{?lib64}   = %{icversion}
Provides:       libclntsh.so.%{soversion}.1%{?lib64} = %{icversion}
Provides:       libociei.so%{?lib64}       = %{icversion}
Provides:       ojdbc14                    = %{icversion}
Obsoletes:      rhn-oracle-jdbc           <= 1.0
Requires:       libstdc++.so.6%{?lib64}

%description
Compatibility package so that perl-DBD-Oracle will install.

%prep
%setup -q

%build

%install
mkdir -p $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d
echo %{_libdir}/oracle/%{icdir}/client/lib >>$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/oracle-instantclient-%{icdir}.conf

# do not replace /usr/lib with _libdir macro here
# XE server is 32bit even on 64bit platforms
echo /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/lib >>$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/oracle-xe.conf

%ifarch x86_64 s390x
mkdir -p $RPM_BUILD_ROOT%{_bindir}
ln -s ../%{_lib}/oracle/%{icdir}/client/bin/sqlplus $RPM_BUILD_ROOT%{_bindir}/sqlplus

mkdir -p $RPM_BUILD_ROOT%{_libdir}/oracle/%{icdir}
ln -s ../../../lib/oracle/%{icdir}/client64 $RPM_BUILD_ROOT%{_libdir}/oracle/%{icdir}/client

mkdir -p $RPM_BUILD_ROOT/usr/lib/oracle/11.2/client64/lib/network/admin
echo 'diag_adr_enabled = off' > $RPM_BUILD_ROOT/usr/lib/oracle/11.2/client64/lib/network/admin/sqlnet.ora
%else
mkdir -p $RPM_BUILD_ROOT/usr/lib/oracle/11.2/client/lib/network/admin
echo 'diag_adr_enabled = off' > $RPM_BUILD_ROOT/usr/lib/oracle/11.2/client/lib/network/admin/sqlnet.ora
%endif

mkdir -p $RPM_BUILD_ROOT/%{_javadir}
ln -s ../../%{_lib}/oracle/%{icdir}/client/lib/ojdbc6.jar $RPM_BUILD_ROOT/%{_javadir}/ojdbc14.jar

%clean

%files
%ifarch x86_64 s390x
%{_bindir}/sqlplus
%{_libdir}/oracle
/usr/lib/oracle/11.2/client64/lib/network/admin/sqlnet.ora
%else
/usr/lib/oracle/11.2/client/lib/network/admin/sqlnet.ora
%endif
%config(noreplace) %{_sysconfdir}/ld.so.conf.d/oracle-instantclient-%{icdir}.conf
%config(noreplace) %{_sysconfdir}/ld.so.conf.d/oracle-xe.conf
%{_javadir}/ojdbc14.jar

%post
ldconfig

# clear execstack on libs in oracle's provided instantclient rpm
find %{_prefix}/lib/oracle/%{icdir} \
        | xargs file | awk -F: '/ELF.*(executable|shared object)/ {print $1}' \
        | xargs execstack -c

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 11.2.0.16-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 11.2.0.15-1
- purged changelog entries for Spacewalk 2.0 and older

* Mon Jul 17 2017 Jan Dobes 11.2.0.14-1
- Remove more fedorahosted links
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Tue Nov 10 2015 Tomas Kasparek <tkasparek@redhat.com> 11.2.0.13-1
- don't build debug package for oracle-lib-compat

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 11.2.0.12-1
- we need to use the exact oracle instantclient version

* Thu Jan 29 2015 Tomas Lestach <tlestach@redhat.com> 11.2.0.11-1
- do not require exact version of oracle instantclient

* Wed Oct 22 2014 Michael Mraka <michael.mraka@redhat.com> 11.2.0.10-1
- oracle-instantclient11.2 requires libstdc++.so.6

* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 11.2.0.9-1
- LD_PRELOAD setup has been moved to spacewalk-setup-tomcat
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

