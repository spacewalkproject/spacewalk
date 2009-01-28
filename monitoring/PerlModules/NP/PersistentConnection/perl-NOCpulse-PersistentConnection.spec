Name:         perl-NOCpulse-PersistentConnection
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:      1.5.4
Release:      1%{?dist}
Summary:      Persistent HTTP connection over SSL
URL:          https://fedorahosted.org/spacewalk
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:     nocpulse-common
BuildRequires: perl(ExtUtils::MakeMaker)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides persistent HTTP connection over SSL.

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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*

%changelog
* Wed Jan 28 2009 Dennis Gilmore <dennis@ausil.us> 1.5.4-1
- BR perl(ExtUtils::MakeMaker)

* Tue Nov 25 2008 Miroslav Suchý <msuchy@redhat.com> 1.5.3-1
- require nocpulse-common since we suppose existence of ~nocpulse

* Wed Sep  3 2008 Miroslav Suchý <msuchy@redhat.com> 1.5.2-1
- spec cleanup for Fedora

* Fri Jun  6 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.5.1-5
- cvs.dist import
