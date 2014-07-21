Summary:      Spacewalk monitoring
Name:         spacewalk-monitoring
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.3.0
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
Requires: spacewalk-monitoring-selinux

%if 0%{?fedora}
BuildRequires: systemd
%else
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
%endif

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

%if 0%{?fedora}
mkdir -p $RPM_BUILD_ROOT/%{_unitdir}
install Monitoring.service $RPM_BUILD_ROOT%{_unitdir}
install MonitoringScout.service $RPM_BUILD_ROOT%{_unitdir}
%else
mkdir -p $RPM_BUILD_ROOT/%{_initrddir}
install Monitoring $RPM_BUILD_ROOT%{_initrddir}
install MonitoringScout $RPM_BUILD_ROOT%{_initrddir}
%endif
ln -s /etc/rc.d/np.d/sysvStep $RPM_BUILD_ROOT/%{_sbindir}/Monitoring
ln -s /etc/rc.d/np.d/sysvStep $RPM_BUILD_ROOT/%{_sbindir}/MonitoringScout


%post
if [ -x /etc/init.d/Monitoring ] ; then
    /sbin/chkconfig --add Monitoring
fi
if [ -x /etc/init.d/MonitoringScout ] ; then
    /sbin/chkconfig --add MonitoringScout
fi
if [ -r %{_unitdir}/Monitoring.service ] ; then
    /usr/bin/systemctl enable Monitoring.service
fi
if [ -r %{_unitdir}/MonitoringScout.service ] ; then
    /usr/bin/systemctl enable MonitoringScout.service
fi

%preun
if [ $1 = 0 ] ; then
    if [ -x /etc/init.d/MonitoringScout ] ; then
        /sbin/service MonitoringScout stop >/dev/null 2>&1
        /sbin/chkconfig --del MonitoringScout
    fi
    if [ -x /etc/init.d/Monitoring ] ; then
        /sbin/service Monitoring stop >/dev/null 2>&1
        /sbin/chkconfig --del Monitoring
    fi
    if [ -f %{_unitdir}/MonitoringScout.service ] ; then
        /usr/bin/systemctl --no-reload disable MonitoringScout.service > /dev/null 2>&1 || :
        /usr/bin/systemctl stop MonitoringScout.service > /dev/null 2>&1 || :
    fi
    if [ -f %{_unitdir}/Monitoring.service ] ; then
        /usr/bin/systemctl --no-reload disable Monitoring.service > /dev/null 2>&1 || :
        /usr/bin/systemctl stop Monitoring.service > /dev/null 2>&1 || :
    fi
fi


%clean
rm -rf $RPM_BUILD_ROOT

%files
%if 0%{?fedora}
%{_unitdir}/*
%else
%{_initrddir}/*
%endif
%{_sbindir}/*
%doc LICENSE

%changelog
* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- spec file polish

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 03 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.1-1
- make monitoring build-able on F19
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Feb 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- old Fedoras don't have systemd_* macros defined

* Tue Feb 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.4-1
- corrected monitoring service type
- enable monitoring services in systemd by default

* Wed Feb 13 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.3-1
- fixing rpm build failure

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.1-1
- created systemd services for monitoring
- %%defattr is not needed since rpm 4.4

* Wed Mar 30 2011 Jan Pazdziora 1.4.1-1
- RHEL 4 is no longer a target version for Spacewalk, fixing .spec to Require
  spacewalk-monitoring-selinux.

* Fri Oct 08 2010 Jan Pazdziora 1.2.1-1
- Since the package SatConfig-dbsynch is gone, remove dependencies that were
  requiring it.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

