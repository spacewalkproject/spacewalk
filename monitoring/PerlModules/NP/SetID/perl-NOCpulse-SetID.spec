Name:         perl-NOCpulse-SetID
Version: 	  1.5.2
Release:      6%{?dist}
Summary:      Provides api for correctly changing user identity
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/PerlModules/NP/SetID
# make srpm
Source0:      %{name}-%{version}.tar.gz
BuildArch:    noarch
Requires(pre): perl(Class::MethodMaker)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Group:        Development/Libraries
License:      GPLv2
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
 
%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides API for correctly changing user identity.

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
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*

%changelog
* Tue Sep  2 2008 Miroslav Suchý <msuchy@redhat.com> 
- spec cleanup for Fedora

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.5.2-6
- fixed file permissions

* Thu May 29 2008 Jan Pazdziora 1.5.2-5
- rebuild in dist-cvs
