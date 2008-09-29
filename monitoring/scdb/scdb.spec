Name:         scdb
Source0:      %{name}-%{version}.tar.gz
Version:      1.15.5
Release:      1%{?dist}
Summary:      State Change Database
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/scdb
# make srpm
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Group:        Applications/Databases
License:      GPLv2
BuildRoot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     nocpulse-common

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package contains State Change Database.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
# Make sure the 'bdb' directory exists
mkdir -p  $RPM_BUILD_ROOT/nocpulse/scdb/bdb

# Copy the module
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse
install -m 644 SCDB.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse

# Add registry entries
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/rc.d/np.d/apachereg/
install -m 644  Apache.scdb $RPM_BUILD_ROOT%{_sysconfdir}/rc.d/np.d/apachereg/

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(-,root,root,-)
%attr(755,apache,apache) %dir /nocpulse/scdb/bdb
%{_sysconfdir}/rc.d/np.d/apachereg/Apache.scdb
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Mon Sep 29 2008 Miroslav Suchý <msuchy@redhat.com> 1.15.5-1
- NOCpulse::Oracle is renamed to NOCpulse::Database

* Tue Sep 23 2008 Miroslav Suchý <msuchy@redhat.com> 1.15.4-1
- spec cleanup for Fedora

* Tue Jun 10 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.15.3-12
- cvs.dist import
