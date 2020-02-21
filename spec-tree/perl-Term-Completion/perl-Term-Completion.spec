Name:       perl-Term-Completion 
Version:    1.00
Release:    9%{?dist}.5
License:    GPL+ or Artistic 
Summary:    Read one line of user input, with convenience functions 
Source:     https://search.cpan.org/CPAN/authors/id/M/MA/MAREKR/Term-Completion-%{version}.tar.gz 
Url:        https://search.cpan.org/dist/Term-Completion
Requires:   perl(:MODULE_COMPAT_%(eval "`perl -V:version`"; echo $version))
BuildArch:  noarch
%if 0%{?fedora} && 0%{?fedora} > 26
BuildRequires: perl-interpreter
%else
BuildRequires: perl
%endif
BuildRequires: perl(base)
BuildRequires: perl(Carp)
BuildRequires: perl(Exporter)
BuildRequires: perl(ExtUtils::MakeMaker)
BuildRequires: perl(File::Spec)
BuildRequires: perl(IO::Handle)
BuildRequires: perl(IO::String)
BuildRequires: perl(POSIX)
BuildRequires: perl(strict)
BuildRequires: perl(Term::ReadKey) >= 2.3
BuildRequires: perl(Term::Size)
BuildRequires: perl(Test::More)
BuildRequires: perl(warnings)

Patch0:    space-handling.patch

%{?perl_default_filter}

%description
Term::Completion is an extensible, highly configurable replacement for
the venerable Term::Complete package. It is object-oriented and thus allows
subclassing. Two derived classes are Term::Completion::Multi and 
Term::Completion::Path. A prompt is printed and the user may enter one line
of input, submitting the answer by pressing the ENTER key. 

%prep
%setup -q -n Term-Completion-%{version}
%patch0 -p1
find . -type f -exec chmod -c -x {} \;
perl -pi -e 's|^#!/opt/perl_5.8.8/bin/perl|#!%{__perl}|' devel/tget.pl
for file in README Changes devel/*; do
    sed -i 's/\r//g' ${file}
done

%build
perl Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
make pure_install DESTDIR=%{buildroot}
find %{buildroot} -type f -name .packlist -exec rm -f {} ';'
%{_fixperms} %{buildroot}/*

%check
# needed for testing...
export COLUMNS=80
export LINES=25
make test

%files
%doc Changes README devel/
%{perl_vendorlib}/*
%{_mandir}/man3/*.3*

%changelog
* Fri Feb 21 2020 Stefan Bluhm <stefan.bluhm@clacee.eu> 1.00-9.5
- Updated source URLs to https.

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 1.00-9.4
- removed Group from specfile

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 1.00-9.3
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Fri Jun 02 2017 Tomas Kasparek <tkasparek@redhat.com> 1.00-9.2
- 1440818 - handle spaces at the end of input in more mannered way

* Tue Apr 11 2017 Tomas Kasparek <tkasparek@redhat.com> 1.00-9.1
- new package built with tito

* Sun May 15 2016 Jitka Plesnikova <jplesnik@redhat.com> - 1.00-9
- Perl 5.24 rebuild

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 1.00-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Thu Jun 18 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.00-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Thu Jun 04 2015 Jitka Plesnikova <jplesnik@redhat.com> - 1.00-6
- Perl 5.22 rebuild

* Wed Aug 27 2014 Jitka Plesnikova <jplesnik@redhat.com> - 1.00-5
- Perl 5.20 rebuild

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.00-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.00-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Thu Jul 18 2013 Petr Pisar <ppisar@redhat.com> - 1.00-2
- Perl 5.18 rebuild

* Wed Feb 27 2013 Petr Šabata <contyk@redhat.com> - 1.00-1
- 1.00 bump
- Spec cleanup

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.91-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Fri Jul 20 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.91-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Mon Jun 11 2012 Petr Pisar <ppisar@redhat.com> - 0.91-9
- Perl 5.16 rebuild

* Fri Jan 13 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.91-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Jun 21 2011 Marcela Mašláňová <mmaslano@redhat.com> - 0.91-7
- Perl mass rebuild

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.91-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Wed Dec 22 2010 Marcela Maslanova <mmaslano@redhat.com> - 0.91-5
- 661697 rebuild for fixing problems with vendorach/lib

* Thu May 06 2010 Marcela Maslanova <mmaslano@redhat.com> - 0.91-4
- Mass rebuild with perl-5.12.0

* Fri Dec  4 2009 Stepan Kasal <skasal@redhat.com> - 0.91-3
- rebuild against perl 5.10.1

* Sun Jul 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.91-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Fri May 01 2009 Chris Weyl <cweyl@alumni.drew.edu> 0.91-1
- submission

* Fri May 01 2009 Chris Weyl <cweyl@alumni.drew.edu> 0.91-0
- initial RPM packaging
- generated with cpan2dist (CPANPLUS::Dist::RPM version 0.0.8)

