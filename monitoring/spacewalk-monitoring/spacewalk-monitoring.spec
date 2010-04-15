%define require_selinux 1

# No Selinux for RHEL 4:
%if 0%{?rhel} == 4
%define require_selinux 0
%endif

Summary:      Spacewalk monitoring
Name:         spacewalk-monitoring
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      1.1.0
Release:      1%{?dist}
URL:          https://fedorahosted.org/spacewalk
License:      GPLv2
Group:        Applications/System
BuildArch:    noarch

# Monitoring support
#we need this package for EL4
#Requires:       perl-CGI-mp20

# Monitoring packages
#we need to be sure that nocpulse home is correct
Requires(pre): nocpulse-common

Requires:       nocpulse-db-perl
Requires:       eventReceivers
Requires:       MessageQueue
Requires:       NOCpulsePlugins
Requires:       NPalert
Requires:       perl-NOCpulse-CLAC
Requires:       perl-NOCpulse-Debug
Requires:       perl-NOCpulse-Gritch
Requires:       perl-NOCpulse-Object
Requires:       perl-NOCpulse-OracleDB
Requires:       perl-NOCpulse-PersistentConnection
Requires:       perl-NOCpulse-Probe
Requires:       perl-NOCpulse-ProcessPool
Requires:       perl-NOCpulse-Scheduler
Requires:       perl-NOCpulse-SetID
Requires:       perl-NOCpulse-Utils
Requires:       ProgAGoGo
Requires:       SatConfig-bootstrap
Requires:       SatConfig-bootstrap-server
Requires:       SatConfig-cluster
Requires:       SatConfig-dbsynch
Requires:       SatConfig-generator
Requires:       SatConfig-installer
Requires:       SatConfig-spread
Requires:       scdb
Requires:       SNMPAlerts
Requires:       SputLite-client
Requires:       SputLite-server
Requires:       ssl_bridge
Requires:       status_log_acceptor
Requires:       tsdb

%if %{require_selinux}
Requires: spacewalk-monitoring-selinux
%endif

Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

Obsoletes: LongLegs < 1.11.0
Obsoletes: Time-System < 1.7.0

Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package pulls in all of the Spacewalk Monitoring packages, including all
Backend and Scout functionality. And will install SysV init scripts.

%prep
%setup -q

%build
# nothing to do

%install
rm -Rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_sbindir}
mkdir -p $RPM_BUILD_ROOT/%{_initrddir}

ln -s /etc/rc.d/np.d/sysvStep $RPM_BUILD_ROOT/%{_sbindir}/Monitoring
ln -s /etc/rc.d/np.d/sysvStep $RPM_BUILD_ROOT/%{_sbindir}/MonitoringScout

install Monitoring $RPM_BUILD_ROOT%{_initrddir}
install MonitoringScout $RPM_BUILD_ROOT%{_initrddir}

%post
/sbin/chkconfig --add Monitoring
/sbin/chkconfig --add MonitoringScout

%preun
if [ $1 = 0 ] ; then
    /sbin/service MonitoringScout stop >/dev/null 2>&1
    /sbin/chkconfig --del MonitoringScout
    /sbin/service Monitoring stop >/dev/null 2>&1
    /sbin/chkconfig --del Monitoring
fi


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root,root,-)
%{_initrddir}/*
%{_sbindir}/*
%doc LICENSE

%changelog
* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Thu Aug 20 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.1-1
- 516624 - allow upgrade proxy using CLI to 5.3 from 5.0

* Mon Jul 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.7-1
- Re-enable spacewalk-monitoring-selinux dependency for F11.
  (dgoodwin@redhat.com)

* Tue Jul 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.6-1
- Disabling requires on spacewalk-monitoring-selinux. (temporary)
  (dgoodwin@redhat.com)

* Mon May 11 2009 Jan Pazdziora 0.6.4-1
- Move Req of oracle-instantclient-selinux to spacewalk-monitoring-selinux

* Mon May 11 2009 Jan Pazdziora 0.6.3-1
- no need to Require oracle-nofcontext-selinux here

* Wed May  6 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.2-1
- monitoring should require selinux modules

* Mon Apr 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.1-1
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Wed Mar 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.4-1
- be sure that nocpulse home is correct

* Wed Mar 18 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.3-1
- 489573 - we do not conflict with rhnmd any more

* Thu Mar  5 2009 Milan Zazrivec 0.5.2-1
- obsolete LongLegs, Time-System

* Mon Feb 16 2009 Miroslav Suchý <msuchy@redhat.com> 0.4.4-1
- remove perl-Apache-Admin-Config packages
- remove support packages, which are installed by transitive hulk

* Tue Nov 18 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.3-1
- Initial build
