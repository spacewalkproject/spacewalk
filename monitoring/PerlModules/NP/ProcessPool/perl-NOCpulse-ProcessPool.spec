Name:         perl-NOCpulse-ProcessPool
Version: 	  2.3.0
Release: 	  1%{?dist}
Summary:      Perl implementation of a process pool
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version)) 
BuildRequires: perl(FreezeThaw) perl(ExtUtils::MakeMaker)
BuildRequires: perl(NOCpulse::Debuggable)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides an API for using a pool of processes to execute jobs.

%prep
%setup -q

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor OPTIMIZE="$RPM_OPT_FLAGS"
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
%{perl_vendorlib}/NOCpulse/*

%changelog
* Thu Aug 11 2011 Jan Pazdziora 1.6.1-1
- Localization of STDOUT and STDERR was overoptimistic.

* Fri Feb 18 2011 Jan Pazdziora 1.4.1-1
- Localize the filehandle globs; also use three-parameter opens.

