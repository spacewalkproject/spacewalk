Name:           oracle-lib-compat
Version:        10.7
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
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)
Requires:       oracle-instantclient-basic >= 10.2.0
Requires(post): ldconfig

%ifarch x86_64
%define lib64 ()(64bit)
%endif
Provides:       libocci.so.10.1%{?lib64}   = 10.2.0
Provides:       libnnz10.so%{?lib64}       = 10.2.0
Provides:       libocijdbc10.so%{?lib64}   = 10.2.0
Provides:       libclntsh.so.10.1%{?lib64} = 10.2.0
Provides:       libociei.so%{?lib64}       = 10.2.0
Provides:       ojdbc14                    = 10.2.0
Obsoletes:      rhn-oracle-jdbc           <= 1.0
Requires:       libstdc++.so.5%{?lib64}

%description
Compatibility package so that perl-DBD-Oracle will install.

# do not replace /usr/lib with _libdir macro here
# oracle installs there even on 64bit platforms
%define oraclelibdir            /usr/lib/oracle
%define instantclientbase       %{oraclelibdir}/10.2.0.4

%ifarch x86_64 s390x
%define clientdir       client64
%else  # i386 s390
%define clientdir       client
%endif

%define instantclienthome       %{instantclientbase}/%{clientdir}
%define oraclexeserverhome      %{oraclelibdir}/xe/app/oracle/product/10.2.0/server

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{oraclelibdir}

ln -s %{instantclientbase} $RPM_BUILD_ROOT%{oraclelibdir}/10.2.0

install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d
echo %{instantclienthome}/lib  >>$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/%{name}.conf
echo %{oraclexeserverhome}/lib >>$RPM_BUILD_ROOT%{_sysconfdir}/ld.so.conf.d/%{name}.conf

mkdir -p $RPM_BUILD_ROOT%{_bindir}
ln -s %{instantclienthome}/bin/sqlplus $RPM_BUILD_ROOT%{_bindir}/sqlplus

mkdir -p $RPM_BUILD_ROOT/%{_javadir}
ln -s %{instantclienthome}/lib/ojdbc14.jar $RPM_BUILD_ROOT/%{_javadir}/ojdbc14.jar

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_bindir}/sqlplus
%{oraclelibdir}/10.2.0
%config %{_sysconfdir}/ld.so.conf.d/%{name}.conf
%{_javadir}/ojdbc14.jar

%post
ldconfig


%changelog
* Fri Dec  5 2008 Michael Mraka <michael.mraka@redhat.com> 10.7-1
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

