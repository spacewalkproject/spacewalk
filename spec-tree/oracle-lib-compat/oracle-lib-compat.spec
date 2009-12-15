Name:           oracle-lib-compat
Version:        10.2
Release:        21%{?dist}
Summary:        Compatibility package so that perl-DBD-Oracle will install
Group:          Applications/Multimedia
License:        GPLv2
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd spec-tree/oracle-lib-compat
# make srpm
URL:            https://fedorahosted.org/spacewalk
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)

%ifarch s390 s390x
%define icversion 10.2.0.2
%else
%define icversion 10.2.0.4
%endif

Requires:       oracle-instantclient-basic = %{icversion}
Requires:       oracle-instantclient-sqlplus = %{icversion}
Requires(post): ldconfig
Requires(post): /usr/bin/execstack

%ifarch x86_64
%define lib64 ()(64bit)
%endif
Provides:       libocci.so.10.1%{?lib64}   = %{icversion}
Provides:       libnnz10.so%{?lib64}       = %{icversion}
Provides:       libocijdbc10.so%{?lib64}   = %{icversion}
Provides:       libclntsh.so.10.1%{?lib64} = %{icversion}
Provides:       libociei.so%{?lib64}       = %{icversion}
Provides:       ojdbc14                    = %{icversion}
Obsoletes:      rhn-oracle-jdbc           <= 1.0
Requires:       libstdc++.so.5%{?lib64}

%description
Compatibility package so that perl-DBD-Oracle will install.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d
echo %{_libdir}/oracle/%{icversion}/client/lib >>$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/%{name}.conf
# do not replace /usr/lib with _libdir macro here
# XE server is 32bit even on 64bit platforms
echo /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/lib >>$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/%{name}.conf

%ifarch x86_64 s390x
mkdir -p $RPM_BUILD_ROOT%{_bindir}
ln -s ../%{_lib}/oracle/%{icversion}/client/bin/sqlplus $RPM_BUILD_ROOT%{_bindir}/sqlplus

mkdir -p $RPM_BUILD_ROOT%{_libdir}/oracle/%{icversion}
ln -s ../../../lib/oracle/%{icversion}/client64 $RPM_BUILD_ROOT%{_libdir}/oracle/%{icversion}/client
%endif

mkdir -p $RPM_BUILD_ROOT/%{_javadir}
ln -s ../../%{_lib}/oracle/%{icversion}/client/lib/ojdbc14.jar $RPM_BUILD_ROOT/%{_javadir}/ojdbc14.jar

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%ifarch x86_64 s390x
%{_bindir}/sqlplus
%{_libdir}/oracle
%endif
%config(noreplace) %{_sysconfdir}/ld.so.conf.d/%{name}.conf
%{_javadir}/ojdbc14.jar

%post
ldconfig

# clear execstack on libs in oracle's provided instantclient rpm
find %{_prefix}/lib/oracle/%{icversion} \
        | xargs file | awk -F: '/ELF.*(executable|shared object)/ {print $1}' \
        | xargs execstack -c

%changelog
* Wed Sep 09 2009 Michael Mraka <michael.mraka@redhat.com> 10.2-21
- 506951 - clear exec stack on instantclient libs (fixes selinux avc denial)

* Tue Apr 07 2009 Michael Mraka <michael.mraka@redhat.com> 10.2-20
- specified exact version of instantclient

* Mon Mar 02 2009 Devan Goodwin <dgoodwin@redhat.com> 10.2-19
- Version bump to allow fresh dist-cvs tags.

* Mon Dec 15 2008 Michael Mraka <michael.mraka@redhat.com> 10.2-16
- added /usr/bin/sqlplus for 64bit platforms
- added filesystem standard compatible link /usr/lib64/oracle/10.2.0.4/client
- added Requires: libstdc++.so.5 to satisfy instantclient libs
- added Provides: ojdbc14, Obsoletes: rhn-oracle-jdbc
- fixed rpmlint warnings

* Wed Oct 22 2008 Michael Mraka <michael.mraka@redhat.com> 10.2-13
- resolved #461765 - oracle libs not loaded

* Thu Sep 25 2008 Milan Zazrivec 10.2-12
- merged changes from release-0.2 branch
- fixed s390x

* Thu Sep 11 2008 Jesus Rodriguez <jesusr@redhat.com> 10.2-11
- fix x86_64

* Thu Sep  4 2008 Michael Mraka <michael.mraka@redhat.com> 10.2-8
- fixed rpmlint errors and warnings
- built in brew/koji

* Mon Jul 29 2008 Mike McCune <mmccune@redhat.com>
- Removing uneeded Requires compat-libstdc++

* Tue Jul 2 2008 Mike McCune <mmccune@redhat.com>
- Adding ldconfig for the 64bit instantclient libs

* Tue Jul 1 2008 Mike McCune <mmccune@redhat.com>
- relaxing instantclient version requirement to be >= vs =

* Mon Jun 16 2008 Michael Mraka <michael.mraka@redhat.com>
- added 64bit libs macro

* Fri Jun 13 2008 Devan Goodwin <dgoodwin@redhat.com> 10.2-3
- Add symlink for to Oracle 10.2.0.4 libraries.

* Wed Jun 4 2008 Jesus Rodriguez <jmrodri at gmail dot com> 10.2-1
- initial compat rpm

