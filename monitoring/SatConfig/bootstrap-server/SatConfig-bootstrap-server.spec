Name:         SatConfig-bootstrap-server
Version:      2.3.0
Release:      1%{?dist}
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Summary:      Provides scout info for boostrap
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

This package dole out ID's and descriptions to bootstrapping scouts.

%prep
%setup -q

%build
#Nothing to build

%install
rm -rf $RPM_BUILD_ROOT

# CGI bin
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/SatConfig
install -m 644 Bootstrap.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/SatConfig
install -m 644 TranslateKey.pm $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/SatConfig

%{_fixperms} $RPM_BUILD_ROOT/*

%files
%{perl_vendorlib}/NOCpulse/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Thu Jan 26 2012 Jan Pazdziora 1.13.5-1
- Rollback the session to avoid IDLE in transaction for /cgi-
  bin/translate_key.cgi.

* Fri Sep 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.13.4-1
- 741782 - replaced aliases with table names

