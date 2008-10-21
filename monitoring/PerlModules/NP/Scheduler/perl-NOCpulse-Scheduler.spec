Name:         perl-NOCpulse-Scheduler
Source0:      %{name}-%{version}.tar.gz
Version:      1.58.8
Release:      1%{?dist}
Summary:      NOCpulse Event Scheduler
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/PerlModules/NP/Scheduler
# make srpm
URL:          https://fedorahosted.org/spacewalk
Requires:     nocpulse-common
Requires:	  ProgAGoGo
BuildArch:    noarch
Group:        Development/Libraries 
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package implements an event scheduler system and a framework for 
defining event types.

%prep
%setup -q

%build
#Nothing to build

%install
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/nocpulse

install -m 644 Scheduler.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install -m 644 Event.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install -m 644 Event/ProbeEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install -m 644 Event/TestEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install -m 644 Event/TimeoutEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install -m 644 Event/StatePushEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install -m 644 Message.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install -m 644 MessageDictionary.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install -m 644 Statistics.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install -m 755 kernel.pl $RPM_BUILD_ROOT%{_bindir}

%files 
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*
%{_bindir}/kernel.pl
%attr(755,nocpulse,nocpulse) %{_var}/lib/nocpulse

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Oct 21 2008 Miroslav Suchý <msuchy@redhat.com> 1.58.8-1
- 467441 - fix namespace

* Wed Sep  3 2008 Miroslav Suchý <msuchy@redhat.com> 1.58.5-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Tue Jun 10 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.58.4-7
- cvs.dist import
