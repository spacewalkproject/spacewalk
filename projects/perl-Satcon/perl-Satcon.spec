%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:           perl-Satcon
Summary:        Framework for configuration files
Version:        2.9.0
Release:        1%{?dist}
License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
BuildArch:      noarch
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildRequires:  perl(ExtUtils::MakeMaker)
%if 0%{?fedora} && 0%{?fedora} >= 24
BuildRequires:  coreutils
BuildRequires:  findutils
BuildRequires:  make
%if 0%{?fedora} && 0%{?fedora} > 26
BuildRequires:  perl-interpreter
%else
BuildRequires:  perl
%endif
BuildRequires:  perl-generators
# Run-time:
# bytes not used at tests
# Data::Dumper not used at tests
# File::Find not used at tests
# File::Path not used at tests
# Getopt::Long not used at tests
BuildRequires:  perl(strict)
# Tests:
BuildRequires:  perl(Test)
%endif
Requires:       %{sbinpath}/restorecon

%description
Framework for generating config files during installation.
This package include Satcon perl module and supporting applications.

%prep
%setup -q

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean

%files
%doc README LICENSE 
%{perl_vendorlib}/*
%{_bindir}/*

%changelog
* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Mon Jul 17 2017 Jan Dobes 2.7.2-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Mon Jan 23 2017 Jan Dobes 2.7.1-1
- Specify all dependencies
- Bumping package versions for 2.7.

* Wed Jul 20 2016 Tomas Lestach <tlestach@redhat.com> 2.6.1-1
- let's BuildRequire perl-Test for perl-Satcon
- Bumping package versions for 2.6.
- Bumping package versions for 2.5.
- Bumping package versions for 2.4.

* Thu Mar 19 2015 Grant Gainey 2.3.2-1
- Updating copyright info for 2015

* Fri Jan 16 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.

