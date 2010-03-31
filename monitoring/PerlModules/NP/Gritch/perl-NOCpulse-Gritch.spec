Name:         perl-NOCpulse-Gritch
Version:      1.27.5
Release:      1%{?dist}
Summary:      Perl throttled email notification for Spacewalk
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(NOCpulse::Config)
BuildRequires: perl(NOCpulse::Debug) perl(ExtUtils::MakeMaker)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides throttled email notification for Spacewalk.

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
%defattr(-,root,root,-)
%{perl_vendorlib}/*
%{_mandir}/man3/*
%doc LICENSE

%changelog
* Wed Mar 31 2010 Miroslav Suchý <msuchy@redhat.com> 1.27.5-1
- do not care about sending email, transfer the worries to perl-MailTools

* Tue Feb 24 2009 Miroslav Suchý <msuchy@redhat.com> 1.27.4-1
- add LICENSE

* Wed Jan 28 2009 Dennis Gilmore <dennis@ausil.us> 1.27.3-1
- BR perl(ExtUtils::MakeMaker)

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.27.2-1
- 467441 - fix namespace

* Tue Sep  2 2008 Miroslav Suchý <msuchy@redhat.com> 1.27.1-1
- edit spec to comply with Fedora Guidelines

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.16.1-6
- fixed file permissions

* Wed May 28 2008 Jan Pazdziora 1.16.1-5
- rebuild in dist-cvs
