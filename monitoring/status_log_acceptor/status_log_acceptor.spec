Name:         status_log_acceptor
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.3.0
Release:      1%{?dist}
Summary:      Current state log acceptor
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:	  SatConfig-general
Group:        Applications/Internet
License:      GPLv2
Buildroot:     %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
Provides the cgi that accepts a status log, parses it, and stores the 
information.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
 
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
#mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/AcceptStatusLog/test
 
install -m 444 AcceptStatusLog.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
#install -m 444 test/TestAcceptStatusLog.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/AcceptStatusLog/test

%files
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Apr 24 2012 Stephen Herr <sherr@redhat.com> 0.12.11-1
- 815964 - update monitoring probes in small batches to reduce the chance of a
  deadlock

* Wed Feb 01 2012 Jan Pazdziora 0.12.10-1
- Make the Last update value not truncated to day which makes the probe state
  actually green.

* Wed Feb 01 2012 Jan Pazdziora 0.12.9-1
- Fixing inserts and updates for RHN_PROBE_STATE and RHN_SATELLITE_STATE.
- Use RHN::DBI instead of plain DBI with sc_db login parameters.

