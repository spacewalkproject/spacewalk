Name:         perl-NOCpulse-CLAC
Version:      1.9.7
Release:      1%{?dist}
Summary:      NOCpulse Command Line Application framework for Perl
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(ExtUtils::MakeMaker)
BuildArch:    noarch
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This packages provides a framework for writing command line oriented 
applications.

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

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*
%doc LICENSE

%changelog
* Thu Feb 19 2009 Miroslav Suchý <msuchy@redhat.com>
- remove opt flags
- add LICENSE
- add GPL header to modules

* Thu Jan 22 2009 Dennis Gilmore <dgilmore@redhat.com> 1.9.7-1
- BuildRequires perl(ExtUtils::MakeMaker)

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.9.6-1
- 467441 - fix namespace

* Wed Sep  3 2008 Miroslav Suchý <msuchy@redhat.com> 1.9.5-1
- spec cleanup for Fedora
- move /opt dir away

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.9.4-11
- fixed file permissions

* Thu May 29 2008 Jan Pazdziora 1.9.4-10
- rebuild in dist-cvs
