Name:         perl-NOCpulse-Scheduler
Source0:      %{name}-%{version}.tar.gz
Version:      1.58.4
Release:      7%{?dist}
Summary:      NOCpulse Event Scheduler
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/PerlModules/NP/Scheduler
# make srpm
URL:          https://fedorahosted.org/spacewalk
Requires:     nocpulse-common
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
mkdir -p $RPM_BUILD_ROOT%home/var/rw

install Scheduler.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install Event.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install Event/ProbeEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install Event/TestEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install Event/TimeoutEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install Event/StatePushEvent.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler/Event
install Message.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install MessageDictionary.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install Statistics.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Scheduler
install -m 755 kernel.pl $RPM_BUILD_ROOT%{_bindir}

%files 
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*
%{_bindir}/kernel.pl
%attr(755,nocpulse,nocpulse) %home/var/rw

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Sep  3 2008 Miroslav Suchý <msuchy@redhat.com> 
- spec cleanup for Fedora

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Tue Jun 10 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.58.4-7
- cvs.dist import
