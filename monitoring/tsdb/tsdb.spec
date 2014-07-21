%if 0%{!?_initddir:1}
%define _initddir %{_sysconfdir}/rc.d/init.d
%endif

%define init_script %{_initddir}/tsdb_local_queue
%define lqdir       %{_var}/log/nocpulse/TSDBLocalQueue
%define bdbdir      %{_var}/lib/nocpulse/tsdb/bdb
%define npbin       %{_bindir}
Name:         tsdb
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.3.0
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
* Wed Aug 01 2012 Jan Pazdziora 1.27.29-1
- 844992 - force the array context so that Class::MethodMaker behaves the same
  in both versions 1 and 2.
- %%defattr is not needed since rpm 4.4

* Tue Mar 13 2012 Michael Mraka <michael.mraka@redhat.com> 1.27.28-1
- fixed error: %%changelog entries must start with *

* Wed Feb 15 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.27.27-1
- time_series revamped: tsdb to use new table names

* Tue Feb 07 2012 Jan Pazdziora 1.27.26-1
- scdb: use /var/lib/nocpulse directory (mzazrivec@redhat.com)

* Thu Feb 02 2012 Jan Pazdziora 1.27.25-1
- removing non-working debugging scripts (michael.mraka@redhat.com)

* Thu Aug 11 2011 Jan Pazdziora 1.27.24-1
- Properly dereference the array references for old and new files so logfiles
  contain the number of files in the queue and not strings like
  "ARRAY(0x12323)" (david.nutter@bioss.ac.uk)

* Fri Feb 18 2011 Jan Pazdziora 1.27.23-1
- Localize the filehandle globs; also use three-parameter opens.

