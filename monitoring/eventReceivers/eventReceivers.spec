Name:         eventReceivers
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.20.9
Release:      1%{?dist}
Summary:      Command Center Event Receivers
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Group:        Applications/Internet
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))


%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package contains handler, which receive events from scouts.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/rc.d/np.d/apachereg
install MonitoringAccessHandler.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install EventHandler.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install HttpsMX.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install ApacheSSL.eventReceivers $RPM_BUILD_ROOT%{_sysconfdir}/rc.d/np.d/apachereg
install ApacheSSL.eventReceivers-proxies $RPM_BUILD_ROOT%{_sysconfdir}/rc.d/np.d/apachereg

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(644,root,root,-)
%{perl_vendorlib}/NOCpulse/*
%config %{_sysconfdir}/rc.d/np.d/apachereg/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Sep 12 2008 Miroslav Suchy <msuchy@redhat.com> 2.20.9-1
- spec cleanup for Fedora

* Fri Jun  6 2008 Milan Zazrivec <mzazrivec@redhat.com> 2.20.8-11
- cvs.dist import
