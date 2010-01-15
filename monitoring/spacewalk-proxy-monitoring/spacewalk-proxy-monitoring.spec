
Summary:      Meta-package that pulls in all of the Spacewalk monitoring packages
Name:         spacewalk-proxy-monitoring
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      0.8.1
Release:      1%{?dist}
URL:          https://fedorahosted.org/spacewalk
License:      GPLv2
Group:        Applications/System
BuildArch:    noarch
Obsoletes:    rhns-proxy-monitoring < 5.3.0
Provides:     rhns-proxy-monitoring
#we need to be sure that nocpulse home is correct
Requires(pre): nocpulse-common

Requires: nocpulse-db-perl 
Requires: eventReceivers 
Requires: MessageQueue 
Requires: NOCpulsePlugins 
Requires: NPalert 
Requires: perl-NOCpulse-CLAC 
Requires: perl-NOCpulse-Debug 
Requires: perl-NOCpulse-Gritch 
Requires: perl-NOCpulse-Object 
Requires: perl-NOCpulse-OracleDB 
Requires: perl-NOCpulse-PersistentConnection 
Requires: perl-NOCpulse-Probe 
Requires: perl-NOCpulse-ProcessPool 
Requires: perl-NOCpulse-Scheduler 
Requires: perl-NOCpulse-SetID 
Requires: perl-NOCpulse-Utils 
Requires: ProgAGoGo 
Requires: SatConfig-bootstrap 
Requires: SatConfig-bootstrap-server 
Requires: SatConfig-cluster 
Requires: SatConfig-dbsynch 
Requires: SatConfig-general 
Requires: SatConfig-generator 
Requires: SatConfig-installer 
Requires: SatConfig-spread 
Requires: scdb 
Requires: SNMPAlerts
Requires: SputLite-client 
Requires: SputLite-server 
Requires: ssl_bridge 
Requires: status_log_acceptor 
Requires: tsdb 
Requires: mod_perl
%if 0%{?rhel} == 4
#for rhel4 we have no selinux policy, everything else should have
%else
Requires: spacewalk-monitoring-selinux
%endif
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Obsoletes: np-config < 2.111.0
Provides:  np-config = %{version}
Obsoletes: rhn-modperl < 1.30
Provides:  rhn-modperl = %{version}

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package pulls in all of the Spacewalk Monitoring packages, including all 
MOC and Scout functionality.

%prep
%setup -q

%build
# nothing to do

%install
rm -Rf $RPM_BUILD_ROOT

#/etc/satname needs to be created on the proxy box, with the contents of '1'       
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}
mkdir -p $RPM_BUILD_ROOT/%{_sbindir}
mkdir -p $RPM_BUILD_ROOT/%{_initrddir}

ln -s /etc/rc.d/np.d/sysvStep $RPM_BUILD_ROOT/%{_sbindir}/MonitoringScout

install satname $RPM_BUILD_ROOT%{_sysconfdir}/satname
install MonitoringScout $RPM_BUILD_ROOT%{_initrddir}

%post
/sbin/chkconfig --add MonitoringScout

%preun
if [ $1 = 0 ] ; then
    /sbin/service MonitoringScout stop >/dev/null 2>&1
    /sbin/chkconfig --del MonitoringScout
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root,root,-)
%config %{_sysconfdir}/satname
%{_initrddir}/*
%{_sbindir}/*
%doc README

%changelog
* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.1-1
- bumping Version to 0.7.0 (jmatthew@redhat.com)
- 516624 - allow upgrade proxy using CLI to 5.3 from 5.0

* Mon May 11 2009 Jan Pazdziora 0.6.4-1
- Move Req of oracle-instantclient-selinux to spacewalk-monitoring-selinux

* Mon May 11 2009 Jan Pazdziora 0.6.3-1
- no need to Require oracle-nofcontext-selinux here

* Thu May  7 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.2-1
- require selinux packages

* Thu Apr 30 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.1-1
- bump up version to 0.6 

* Tue Apr 28 2009 Miroslav Suchý <msuchy@redhat.com> 0.4.5-1
- 497998 - add init.d script

* Wed Mar 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.4.4-1
- be sure that nocpulse home is correct

* Thu Mar 12 2009 Miroslav Suchý <msuchy@redhat.com> 0.4.3-1
- 489573 - rhnmd do not conflict with monitoring anymore

* Mon Dec  8 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.2-1
- fixed Obsoletes: rhns-proxy-monitoring

* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 0.3.2-1
- rename oracle_perl to nocpulse-db-perl

* Thu Sep 25 2008 Miroslav Suchy <msuchy@redhat.com>
- removed nslogs

* Fri Sep 12 2008 Miroslav Suchy <msuchy@redhat.com> 0.3.1-1
- removed ConfigPusher-general
- renamed to spacewalk-proxy-monitoring
- clean up to comply with Fedora Guidelines
- add documentation

* Thu Jul  3 2008 Milan Zazrivec <mzazrivec@redhat.com> 5.2.0-2
- removed dependencies on FcntlLock, SatConfig-ApacheDepot, scdb_accessor_perl,
  Time-System, tsdb_accessor_perl
* Tue Jun 17 2008 Milan Zazrivec <mzazrivec@redhat.com> 5.2.0-1
- cvs.dist import
- rhns-proxy-monitoring does not depend on bdb_perl anymore (bz #450687)
* Fri Oct 12 2007 Miroslav Suchy <msuchy@redhat.com>
- modified for modperl2
* Thu Jun 09 2005 Nick Hansen <nhansen@redhat.com>
- added a conflict on rhnmd and specified noarch
* Mon May 23 2005 Nick Hansen <nhansen@redhat.com>
- Bumped version to 4.0.0
* Wed Oct 20 2004 Nick Hansen <nhansen@redhat.com>
- added the /etc/satname file for creation on scout-on-proxy systems
  and added a version file
* Mon Oct 18 2004 Nick Hansen <nhansen@redhat.com>
- dropped the timesync-server and timesync-client packages 
* Sun Oct 17 2004 Nick Hansen <nhansen@redhat.com>
- upped version to match the RHN release in which this will go out 
* Wed Sep 22 2004 Mihai Ibanescu <misa@redhat.com>
- Initial build
