Name:         eventReceivers
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      2.20.10
Release:      1%{?dist}
Summary:      Command Center Event Receivers
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Group:        Applications/Internet
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
# smtpdaemon or mailx. I picked up smtpdaemon
Requires:     smtpdaemon

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
install -m644 *.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(-,root,root,-)
%{perl_vendorlib}/*
%doc LICENSE

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Feb 24 2009 Miroslav Suchý <msuchy@redhat.com>
- add LICENSE
- add Requires smtpdaemon

* Wed Feb 11 2009 Miroslav Suchý <msuchy@redhat.com> 2.20.10-1
- remove dead code (apachereg)

* Fri Sep 12 2008 Miroslav Suchy <msuchy@redhat.com> 2.20.9-1
- spec cleanup for Fedora

* Fri Jun  6 2008 Milan Zazrivec <mzazrivec@redhat.com> 2.20.8-11
- cvs.dist import
