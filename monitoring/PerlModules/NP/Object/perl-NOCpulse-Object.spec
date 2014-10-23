Name:         perl-NOCpulse-Object
Version:      2.3.0
Release:      1%{?dist}
Summary:      NOCpulse Object abstraction for Perl
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(Config::IniFiles) perl(FreezeThaw) perl(NOCpulse::Debug) perl(ExtUtils::MakeMaker)
Requires:     perl(FreezeThaw)
Requires:     perl(Config::IniFiles)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package contain an abstract PERL class that tries and fails to cover up
the ugliness that is OO in Perl, amongst other things.

%prep
%setup -q

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -type f -name '*.bs' -size 0 -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%dir %{perl_vendorlib}/NOCpulse
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*
%doc LICENSE

%changelog
* Thu Aug 26 2010 Shannon Hughes <shughes@redhat.com> 1.26.12-1
- Automatic commit of package [perl-NOCpulse-Object] release [1.26.11-1].
  (shughes@redhat.com)

* Thu Aug 26 2010 Shannon Hughes <shughes@redhat.com> 1.26.11-1
-

