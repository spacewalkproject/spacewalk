Name:           perl-Term-Size 
Version:        0.207
Release:        14%{?dist}.1
License:        GPL+ or Artistic 
Summary:        Simple way to get terminal size 
Source0:        http://search.cpan.org/CPAN/authors/id/F/FE/FERREIRA/Term-Size-%{version}.tar.gz
Url:            http://search.cpan.org/dist/Term-Size
# see http://rt.cpan.org/Public/Bug/Display.html?id=38594
Patch0:         %{name}-0.207-perlio.patch
# Build
BuildRequires:  findutils
BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  perl
BuildRequires:  perl-devel
BuildRequires:  perl(ExtUtils::MakeMaker)
# Runtime
BuildRequires:  perl(AutoLoader)
BuildRequires:  perl(Carp)
BuildRequires:  perl(DynaLoader)
BuildRequires:  perl(Exporter)
BuildRequires:  perl(strict)
BuildRequires:  perl(vars)
# Tests only
BuildRequires:  perl(Test::More)
# Optional tests only
BuildRequires:  perl(Test::Pod) >= 1.18
Requires:       perl(:MODULE_COMPAT_%(eval "$(perl -V:version)"; echo $version))

%description
Term::Size is a Perl module which provides a straightforward way to
retrieve the terminal size.

Both functions take an optional filehandle argument, which defaults
to *STDIN{IO}. They both return a list of two values, which are the
current width and height, respectively, of the terminal associated with
the specified filehandle.

Term::Size::chars returns the size in units of characters, whereas
Term::Size::pixels uses units of pixels.

%prep
%setup -q -n Term-Size-%{version}
%patch0 -p1

%build
perl Makefile.PL INSTALLDIRS=vendor OPTIMIZE="%{optflags}" NO_PACKLIST=1
make %{?_smp_mflags}

%install
make pure_install DESTDIR=%{buildroot}
find %{buildroot} -type f -name '*.bs' -a -size 0 -delete
%{_fixperms} %{buildroot}/*

%check
make test

%files
%doc Changes README Copyright
%{perl_vendorarch}/Term*
%{perl_vendorarch}/auto
%{_mandir}/man3/*

%changelog
* Tue Apr 11 2017 Tomas Kasparek <tkasparek@redhat.com> 0.207-14.1
- 1440818 - add a patch and fix package version

* Tue Apr 11 2017 Tomas Kasparek <tkasparek@redhat.com> 0.207.1-14
- new package built with tito

* Sun May 15 2016 Jitka Plesnikova <jplesnik@redhat.com> - 0.207-14
- Perl 5.24 rebuild

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 0.207-13
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Mon Nov 30 2015 Petr Šabata <contyk@redhat.com> - 0.207-12
- Package cleanup
- Enable the test suite; it works in the modern mock & koji

* Thu Jun 18 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.207-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Wed Jun 03 2015 Jitka Plesnikova <jplesnik@redhat.com> - 0.207-10
- Perl 5.22 rebuild

* Tue Aug 26 2014 Jitka Plesnikova <jplesnik@redhat.com> - 0.207-9
- Perl 5.20 rebuild

* Sun Aug 17 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.207-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.207-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.207-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Wed Jul 17 2013 Petr Pisar <ppisar@redhat.com> - 0.207-5
- Perl 5.18 rebuild

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.207-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Fri Jul 20 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.207-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Mon Jun 11 2012 Petr Pisar <ppisar@redhat.com> - 0.207-2
- Perl 5.16 rebuild

* Fri Jan 13 2012 Petr Šabata <contyk@redhat.com> - 0.207-1
- 0.207 bump

* Mon Jun 20 2011 Petr Sabata <contyk@redhat.com> - 0.2-9
- Perl mass rebuild
- Removing now obsolete Buildroot and defattr

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.2-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Wed Dec 22 2010 Marcela Maslanova <mmaslano@redhat.com> - 0.2-7
- 661697 rebuild for fixing problems with vendorach/lib

* Thu May 06 2010 Marcela Maslanova <mmaslano@redhat.com> - 0.2-6
- Mass rebuild with perl-5.12.0

* Fri Dec  4 2009 Stepan Kasal <skasal@redhat.com> - 0.2-5
- rebuild against perl 5.10.1

* Sun Jul 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.2-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Thu Mar 26 2009 Chris Weyl <cweyl@alumni.drew.edu> - 0.2-3
- Stripping bad provides of private Perl extension libs

* Thu Feb 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Mon Sep 29 2008 Chris Weyl <cweyl@alumni.drew.edu> 0.2-1
- initial RPM packaging
- generated with cpan2dist (CPANPLUS::Dist::RPM version 0.0.1)
