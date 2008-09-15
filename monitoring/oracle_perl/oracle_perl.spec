Name:         oracle_perl
Source0:      %{name}-%{version}.tar.gz
Version:      3.6.1
Release:      1%{?dist}
Summary:      NOCpulse bindings for database to insert and fetch data
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/oracle_perl
# make test-srpm
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package contains Perl bindings for database used by the NOCpulse TSDB and 
SCDB classes to insert and fetch data out of a database.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/
install -m644 Oracle.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Sep 12 2008 Miroslav Suchy <msuchy@redhat.com> 3.6.1-1
- spec cleanup for Fedora

* Fri Jun  6 2008 Milan Zazrivec <mzazrivec@redhat.com> 3.6.0-6
- cvs.dist import
