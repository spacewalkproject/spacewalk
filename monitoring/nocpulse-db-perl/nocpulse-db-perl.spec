Name:         nocpulse-db-perl
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      3.6.5
Release:      1%{?dist}
Summary:      NOCpulse bindings for database to insert and fetch data
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Obsoletes:    oracle_perl <= 3.6.1

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
install -m644 Database.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Fri Mar 02 2012 Jan Pazdziora 3.6.5-1
- Update the copyright year info.

* Wed Feb 15 2012 Milan Zazrivec <mzazrivec@redhat.com> 3.6.4-1
- time_series revamped: monitoring to use new table names

