Name:         perl-NOCpulse-Utils
Version:      2.2.0
Release:      1%{?dist}
Summary:      NOCpulse utility packages
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: /usr/bin/pod2man

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides miscellaneous utility modules.

%prep
%setup -q

%build
# Nothing to build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Utils/test

install -m 444 Module.pm          $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Module.pm 
#install -m 444 TestRunner.pm      $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Utils/TestRunner.pm
install -m 444 Error.pm           $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Utils/Error.pm
#install -m 755 -D runtest.pl      $RPM_BUILD_ROOT/%{_bindir}/runtest.pl
install -m 444 XML.pm          $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Utils/XML.pm
mkdir -p $RPM_BUILD_ROOT%{_mandir}/man3/
/usr/bin/pod2man $RPM_BUILD_ROOT%{perl_vendorlib}/NOCpulse/Module.pm |gzip > $RPM_BUILD_ROOT%{_mandir}/man3/NOCpulse::Module.3pm.gz

%files 
%dir %{perl_vendorlib}/NOCpulse
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Mon Feb 18 2013 Miroslav Suchý <msuchy@redhat.com> 1.14.12-1
- Buildrequire pod2man
- %%defattr is not needed since rpm 4.4

