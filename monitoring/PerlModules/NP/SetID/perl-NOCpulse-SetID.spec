Name:         perl-NOCpulse-SetID
Version:      1.6.10
Release:      1%{?dist}
Summary:      Provides api for correctly changing user identity
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(ExtUtils::MakeMaker)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
 
%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides API for correctly changing user identity.

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
#this require to be root - skip it
#make test

%clean
rm -rf $RPM_BUILD_ROOT
 
%files 
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*
%doc LICENSE

%changelog
* Tue Feb 17 2009 Miroslav Suchý <msuchy@redhat.com> 1.6.10-1
- 483567 - do not scan root dir
 
* Mon Feb  9 2009 Miroslav Suchý <msuchy@redhat.com> 1.6.9-1
- 466906 - apply comments from package review

* Mon Nov  3 2008 Miroslav Suchý <msuchy@redhat.com> 1.6.8-1
- add LICENSE file
- bump up version for new major release

* Thu Oct 30 2008 Miroslav Suchý <msuchy@redhat.com> 1.5.6-1
- add link to tgz file

* Tue Oct 14 2008 Miroslav Suchý <msuchy@redhat.com> 1.5.5-1
- add BuildRequires: perl(ExtUtils::MakeMaker)

* Tue Sep  2 2008 Miroslav Suchý <msuchy@redhat.com> 1.5.3-1
- spec cleanup for Fedora

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.5.2-6
- fixed file permissions

* Thu May 29 2008 Jan Pazdziora 1.5.2-5
- rebuild in dist-cvs
