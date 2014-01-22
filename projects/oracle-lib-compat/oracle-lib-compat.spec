Name:           oracle-lib-compat
Version:        11.2.0.9
Release:        1%{?dist}
Summary:        Compatibility package so that perl-DBD-Oracle will install
Group:          Applications/Multimedia
License:        GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spec-tree/oracle-lib-compat
# make srpm
URL:            https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)

%ifarch s390 s390x
%define icversion 10.2.0.4
%define icdir %{icversion}
Requires:       oracle-instantclient-basic = %{icversion}
Requires:       oracle-instantclient-sqlplus = %{icversion}
%define soversion 10
%else
%define icversion 11.2.0.3.0
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
Requires:       libstdc++.so.5%{?lib64}

%description
Compatibility package so that perl-DBD-Oracle will install.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
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
rm -rf $RPM_BUILD_ROOT

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
* Wed Jan 22 2014 Michael Mraka <michael.mraka@redhat.com> 11.2.0.9-1
- LD_PRELOAD setup has been moved to spacewalk-setup-tomcat
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Dec 04 2012 Jan Pazdziora 11.2.0.8-1
- On Fedoras, start to use tomcat >= 7.

* Mon Oct 08 2012 Jan Pazdziora 11.2.0.7-1
- Require latest greatest oracle-instantclient11.2-*.
- %%defattr is not needed since rpm 4.4

* Fri Feb 03 2012 Jan Pazdziora 11.2.0.6-1
- Avoid cat: write error: Broken pipe when calling tomcat service under trap ''
  PIPE

* Mon May 16 2011 Jan Pazdziora 11.2.0.5-1
- Both tomcat5 and tomcat6 which needs the LD_PRELOAD set.

* Wed May 04 2011 Jan Pazdziora 11.2.0.4-1
- We unset LD_PRELOAD to force ldd to show the libldap line with => even if
  LD_PRELOAD was already set.

* Mon Jan 17 2011 Jan Pazdziora 11.2.0.3-1
- Set diag_adr_enabled to off.

* Mon Jan 10 2011 Jan Pazdziora 11.2.0.2-1
- On x86_64, require 64bit version of libaio for InstantClient 11g.

* Fri Jan 07 2011 Jan Pazdziora 11.2.0.1-1
- Have separate ld.so.conf.d for InstantClient and for XE server.
- InstantClient 11 contains ojdbc5 and ojdbc6, we will change the target of the
  symlink for now.
- Need to use the "11" in .so Provides as well.
- Switch to Oracle InstantClient 11 in oracle-lib-compat.

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 10.2.0.25-1
- instantclient on s390(x) upgraded to 10.2.0.4
- switched to default VersionTagger

* Thu Sep 23 2010 Jan Pazdziora 10.2-24
- 623115 - file lookup using just the linker name (libldap.so) fails if
  openldap-devel is not installed.

* Mon Sep 13 2010 Jan Pazdziora 10.2-23
- 623115 - force tomcat to use the stock openldap, overriding the ldap_*
  symbols in libclntsh.so*.

