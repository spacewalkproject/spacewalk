%if 0%{!?_initddir:1}
%define _initddir %{_sysconfdir}/rc.d/init.d
%endif

%define init_script %{_initddir}/tsdb_local_queue
%define lqdir       %{_var}/log/nocpulse/TSDBLocalQueue
%define bdbdir      %{_var}/lib/nocpulse/tsdb/bdb
%define npbin       %{_bindir}
Name:         tsdb
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      1.27.21
Release:      1%{?dist}
Summary:      Time Series Database
URL:          https://fedorahosted.org/spacewalk
Requires:     perl-NOCpulse-Utils perl(NOCpulse::Debug) perl(IO::Stringy) perl(Class::MethodMaker) perl(Date::Manip)
BuildArch:    noarch
Group:        Applications/Databases
License:      GPLv2
Vendor:       Red Hat, Inc.
Requires:     nocpulse-common
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:     SatConfig-general
Requires:	  httpd
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Time Series Database

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

# Directories
install -d $RPM_BUILD_ROOT/%{perl_vendorlib}/NOCpulse/TSDB/LocalQueue
mkdir -p $RPM_BUILD_ROOT%bdbdir
mkdir -p $RPM_BUILD_ROOT%lqdir
mkdir -p $RPM_BUILD_ROOT%lqdir/queue
mkdir -p $RPM_BUILD_ROOT%lqdir/archive
mkdir -p $RPM_BUILD_ROOT%lqdir/failed
#mkdir -p $RPM_BUILD_ROOT%npbin/tsdb_test
mkdir -p $RPM_BUILD_ROOT%{_bindir}

# Code
install -m 644 TSDB.pm $RPM_BUILD_ROOT/%{perl_vendorlib}/NOCpulse
install -m 644 LocalQueue/*.pm $RPM_BUILD_ROOT/%{perl_vendorlib}/NOCpulse/TSDB/LocalQueue
#install -m 644 LocalQueue/test/*.pm $RPM_BUILD_ROOT/%{perl_vendorlib}/NOCpulse/TSDB/LocalQueue/test
install -m 755 LocalQueue/TSDBLocalQueue.pl $RPM_BUILD_ROOT%npbin/TSDBLocalQueue.pl
#install -m 755 LocalQueue/test/enqueue.pl   $RPM_BUILD_ROOT%npbin/tsdb_test/enqueue.pl
#install -m 755 LocalQueue/test/replaylog.pl $RPM_BUILD_ROOT%npbin/tsdb_test/replaylog.pl

# Ops utilities
install -m 755 LocalQueue/drainer $RPM_BUILD_ROOT%{_bindir}
install -m 755 LocalQueue/rebalance_cron $RPM_BUILD_ROOT%{_bindir}

# Local queue init script (temporary, will be superseded by sysv stuff)
install -D -m 755 LocalQueue/init_script $RPM_BUILD_ROOT%{init_script}

%pre
if [ -d %{init_script} -a %{init_script} != "/" ]; then
  rm -rf %{init_script}
fi

%post
if [ $1 -eq 2 ]; then
  ls /opt/nocpulse/TSDBLocalQueue/TSDBLocalQueue.log 2>/dev/null | xargs -I file mv file %lqdir
  ls /opt/nocpulse/TSDBLocalQueue/queuefile.positions 2>/dev/null | xargs -I file mv file %lqdir
  ls /opt/nocpulse/TSDBLocalQueue/archive/* 2>/dev/null | xargs -I file mv file %lqdir/archive
  ls /opt/nocpulse/TSDBLocalQueue/failed/* 2>/dev/null | xargs -I file mv file %lqdir/failed
  ls /opt/nocpulse/TSDBLocalQueue/queue/* 2>/dev/null | xargs -I file mv file %lqdir/queue
fi

%files
%defattr(-,root,root,-)
%{init_script}
%{_bindir}/*
%attr(755,apache,apache) %dir %bdbdir
%attr(755,apache,apache) %dir %lqdir
%attr(755,apache,apache) %dir %lqdir/queue
%attr(755,apache,apache) %dir %lqdir/archive
%attr(755,apache,apache) %dir %lqdir/failed
%dir %{perl_vendorlib}/NOCpulse/TSDB
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Oct  7 2009 Miroslav Suchý <msuchy@redhat.com> 1.27.21-1
- Fix tsdb to install the init script properly (joshua.roys@gtri.gatech.edu)

* Mon May 11 2009 Milan Zazrivec <mzazrivec@redhat.com> 1.27.20-1
- 498257 - migrate existing files into new nocpulse homedir

* Wed Feb 11 2009 Miroslav Suchý <msuchy@redhat.com> 1.27.19-1
- remove dead code (apachereg)
* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 1.27.18-1
- rebuild
- 479541, 483867 - replaced runuser with /sbin/runuser
- change Source0 to point to fedorahosted.org

* Tue Nov 25 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.27.17-1
- 465546: work around for empty queuefile.positions

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 1.27.16-1
- resolves #467877 - use runuser instead of su

* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 1.27.15-1
- NOCpulse::Oracle is renamed to NOCpulse::Database

* Thu Sep 25 2008 Miroslav Suchý <msuchy@redhat.com> 1.27.14-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Tue Jun 10 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.27.13-19
- cvs.dist import
