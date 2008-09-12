
Summary: Meta-package that pulls in all of the RHN monitoring packages
Name: rhns-proxy-monitoring
Source2: sources
%define main_source %(awk '{ print $2 ; exit }' %{SOURCE2})
Source0: %{main_source}
Source1: version
Version: %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE1}`)%{?dist}
URL: http://rhn.redhat.com/
License: RHN Subscription License
Group: RHN/Server
BuildArch: noarch
Conflicts: rhnmd
Requires: oracle_perl 
Requires: ConfigPusher-general 
Requires: eventReceivers 
Requires: MessageQueue 
Requires: NOCpulsePlugins 
Requires: NPalert 
Requires: np-config 
Requires: NPusers 
Requires: nslogs 
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
%if "%{version}" >= "5.1.0"
Requires: mod_perl
%else
Requires: rhn-modperl
%endif
Buildroot: %{_tmppath}/%{name}-%{version}-root

%description
This package pulls in all of the RHN Monitoring packages, including all MOC and Scout functionality.

%prep
%define build_sub_dir %(echo %{main_source} | sed 's/\.tar\.gz$//')
%setup -n %build_sub_dir

%install
rm -Rf $RPM_BUILD_ROOT

#/etc/satname needs to be created on the proxy box, with the contents of '1'       
mkdir -p $RPM_BUILD_ROOT/etc
echo 1 > $RPM_BUILD_ROOT/etc/satname

%clean
rm -rf $RPM_BUILD_ROOT

%files
%attr(644,root,root) /etc/satname

%changelog
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
