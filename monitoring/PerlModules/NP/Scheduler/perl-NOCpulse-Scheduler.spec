Name:         perl-NOCpulse-Scheduler
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      1.58.11
Release:      1%{?dist}
Summary:      NOCpulse Event Scheduler
URL:          https://fedorahosted.org/spacewalk
Requires:     nocpulse-common, ProgAGoGo
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(ExtUtils::MakeMaker)
BuildArch:    noarch
Group:        Development/Libraries 
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

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
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/nocpulse/NPkernel.out

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
%attr(755,nocpulse,nocpulse) %{_var}/lib/nocpulse/NPkernel.out

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Mar 11 2009 Miroslav Suchy <msuchy@redhat.com> 1.58.11-1
- kernel.pl should create and own NPkernel.out

* Wed Jan 28 2009 Dennis Gilmore <dennis@ausil.us> 1.58.10-1
- BR perl(ExtUtils::MakeMaker)

* Wed Nov 26 2008 Miroslav Suchy <msuchy@redhat.com> 1.58.9-1
- add missing semicolon to kernel.pl

* Tue Oct 21 2008 Miroslav Suchý <msuchy@redhat.com> 1.58.8-1
- 467441 - fix namespace

* Wed Sep  3 2008 Miroslav Suchý <msuchy@redhat.com> 1.58.5-1
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Tue Jun 10 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.58.4-7
- cvs.dist import
