%define db_dir %{_var}/lib/nocpulse
%define install_prefix %{perl_vendorlib}/NOCpulse/SatConfig

Name:         SatConfig-generator
Version:      2.29.14
Release:      1%{?dist}
Summary:      Satellite Configuration System - Server
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:     nocpulse-common
Group:        Applications/Internet
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

# We have removed SatConfig-dbsynch from the release, by
# Provides + Obsoletes we achieve removal of that package
# during upgrades.
Provides:     SatConfig-dbsynch = 1.3.3
Obsoletes:    SatConfig-dbsynch < 1.3.3

%description
SatConfig-generator is the cgi mechanism by which Netsaint configuration files
are generated and propagated.

%prep
%setup -q

%build
# Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p          $RPM_BUILD_ROOT%{install_prefix}
#mkdir -p          $RPM_BUILD_ROOT%{install_prefix}/test
mkdir -p          $RPM_BUILD_ROOT%{db_dir}

install -m 644 ConfigDocument.pm $RPM_BUILD_ROOT%{install_prefix}
install -m 644 GenerateConfig.pm $RPM_BUILD_ROOT%{install_prefix}
#install -m 644 TestGenerateConfig.pm $RPM_BUILD_ROOT%{install_prefix}/test

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%dir %{install_prefix}
%dir %attr(-,nocpulse,nocpulse) %{db_dir}
%{install_prefix}/ConfigDocument.pm
%{install_prefix}/GenerateConfig.pm

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Sep 30 2011 Michael Mraka <michael.mraka@redhat.com> 2.29.14-1
- 741782 - subquery in FROM must have an alias
- 741782 - replaced aliases with table names

* Mon May 02 2011 Jan Pazdziora 2.29.13-1
- No need to Disconnect, hopefully.
- Since RHN::DB sets FetchHashKeyName to NAME_uc and monitoring now uses
  RHN::DB, the column name is now uppercase.

* Fri Oct 08 2010 Jan Pazdziora 2.29.12-1
- Since the package SatConfig-dbsynch is gone, remove dependencies that were
  requiring it.

