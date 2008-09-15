%define release_name Alpha

Source1:        version
Name:           spacewalk
Version:        %(echo `awk '{ print $1 }' %{SOURCE1}`)
Release:        %(echo `awk '{ print $2 }' %{SOURCE1}`)
Summary:        Spacewalk Systems Management Application
Group:          Spacewalk/Server
License:        GPLv2
URL:            http://fedorahosted.org/gitme
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  python
Requires:       python >= 2.3
Requires:       spacewalk-setup

# Java
Requires:       rhn-java-sat
Requires:       taskomatic-sat

# Perl
Requires:       rhn-html
Requires:       rhn-base
Requires:       rhn-dobby
Requires:       rhn-cypress
Requires:       rhn-grail
Requires:       rhn-pxt
Requires:       rhn-sniglets
Requires:       rhn-moon

# Python
Requires:       rhns
Requires:       rhns-app
Requires:       rhns-applet
Requires:       rhns-certs-tools
Requires:       rhns-config-files
Requires:       rhns-config-files-common
Requires:       rhns-config-files-tool
Requires:       rhns-package-push-server
Requires:       rhns-satellite-tools
Requires:       rhns-server
Requires:       rhns-sql
Requires:       rhns-xml-export-libs
Requires:       rhns-xmlrpc
Requires:       rhns-xp
Requires:       rhnpush


# Misc
Requires:       rhn-satellite-schema
Requires:       rhn-satellite-config

# Requires:       osa-dispatcher
# Requires:       jabberpy

# Monitoring support 

# Requires:       perl-Apache-Admin-Config
# Requires:       perl-Apache-DBI
# Requires:       perl-Class-MethodMaker
# Requires:       perl-Config-IniFiles
# Requires:       perl-Crypt-GeneratePassword
# Requires:       perl-FreezeThaw
# Requires:       perl-HTML-TableExtract
# Requires:       perl-IO-Capture
# Requires:       perl-IO-Socket-SSL
# Requires:       perl-IO-stringy
# Requires:       perl-Mail-Alias
# Requires:       perl-MailTools
# Requires:       perl-MIME-tools
# Requires:       perl-Net-SNMP
# Requires:       perl-Network-IPv4Addr
# Requires:       perl-XML-Generator
# Requires:       perl-CGI-mp20

# Monitoring packages
# Requires:       bdb_perl
# Requires:       oracle_perl
# Requires:       ConfigPusher-general
# Requires:       eventReceivers
# Requires:       MessageQueue
# Requires:       NOCpulsePlugins
# Requires:       NPalert
# Requires:       np-config
# Requires:       NPusers
# Requires:       nslogs
# Requires:       perl-NOCpulse-CLAC
# Requires:       perl-NOCpulse-Debug
# Requires:       perl-NOCpulse-Gritch
# Requires:       perl-NOCpulse-Object
# Requires:       perl-NOCpulse-OracleDB
# Requires:       perl-NOCpulse-PersistentConnection
# Requires:       perl-NOCpulse-Probe
# Requires:       perl-NOCpulse-ProcessPool
# Requires:       perl-NOCpulse-Scheduler
# Requires:       perl-NOCpulse-SetID
# Requires:       perl-NOCpulse-Utils
# Requires:       ProgAGoGo
# Requires:       SatConfig-bootstrap
# Requires:       SatConfig-bootstrap-server
# Requires:       SatConfig-cluster
# Requires:       SatConfig-dbsynch
# Requires:       SatConfig-generator
# Requires:       SatConfig-installer
# Requires:       SatConfig-spread
# Requires:       scdb
# Requires:       scdb_accessor_perl
# Requires:       SNMPAlerts
# Requires:       SputLite-client
# Requires:       SputLite-server
# Requires:       ssl_bridge
# Requires:       status_log_acceptor
# Requires:       tsdb
# Requires:       tsdb_accessor_perl

# Solaris
# Requires:       rhn-solaris-bootstrap
# Requires:       rhn_solaris_bootstrap_5_1_0_3



%description
Spacewalk is a systems management application that will 
inventory, provision, update and control your Linux and 
Solaris machines.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/etc
echo "Spacewalk release %{version} (%{release_name})" > $RPM_BUILD_ROOT/etc/spacewalk-release

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/etc/spacewalk-release

%changelog
* Tue Jun 3 2008 Jesus Rodriguez <mmccune at redhat dot com> 0.1
- initial rpm release
