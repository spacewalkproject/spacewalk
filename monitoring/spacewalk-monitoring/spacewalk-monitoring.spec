Summary:      Spacewalk monitoring
Name:         spacewalk-monitoring
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      0.4.0
Release:      1%{?dist}
URL:          https://fedorahosted.org/spacewalk
License:      GPLv2
Group:        Applications/System
BuildArch:    noarch

Conflicts: rhnmd

# Monitoring support
# FIXME: do we need this? isn't it automaticaly req. by perl(foo) pragma?
Requires:       perl-Apache-Admin-Config
Requires:       perl-Apache-DBI
Requires:       perl-Class-MethodMaker
Requires:       perl-Config-IniFiles
Requires:       perl-Crypt-GeneratePassword
Requires:       perl-FreezeThaw
Requires:       perl-HTML-TableExtract
Requires:       perl-IO-Capture
Requires:       perl-IO-Socket-SSL
Requires:       perl-IO-stringy
Requires:       perl-Mail-Alias
Requires:       perl-MailTools
Requires:       perl-MIME-tools
Requires:       perl-Net-SNMP
Requires:       perl-Network-IPv4Addr
Requires:       perl-XML-Generator
Requires:       perl-CGI-mp20

# Monitoring packages
Requires:       bdb_perl
Requires:       nocpulse-db-perl
Requires:       eventReceivers
Requires:       MessageQueue
Requires:       NOCpulsePlugins
Requires:       NPalert
Requires:       nocpulse-common
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
Requires:       scdb_accessor_perl
Requires:       SNMPAlerts
Requires:       SputLite-client
Requires:       SputLite-server
Requires:       ssl_bridge
Requires:       status_log_acceptor
Requires:       tsdb
Requires:       tsdb_accessor_perl

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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root,root,-)
%config %{_initrddir}/*
%{_sbindir}/*
%doc LICENSE

%changelog
* Tue Nov 18 2008 Miroslav Suchý <msuchy@redhat.com>
- Initial build
