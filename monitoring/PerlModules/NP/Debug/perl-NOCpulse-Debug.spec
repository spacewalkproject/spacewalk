Name:         perl-NOCpulse-Debug
Version:      1.23.12
Release:      1%{?dist}
Summary:      Perl debug output package
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     nocpulse-common
BuildRequires: nocpulse-common perl(Error) perl(Class::MethodMaker) perl(ExtUtils::MakeMaker)
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires(pre):     perl(Class::MethodMaker)
Group:        Development/Libraries
License:      GPLv2
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
NOCpulse provides application, network, systems and transaction monitoring,
coupled with a comprehensive reporting system including availability,
historical and trending reports in an easy-to-use browser interface.

This package provides an API for generating varying levels of debugging output
on various output streams.

%prep
%setup -q

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p %{buildroot}%{_sysconfdir}/nocpulse
install -m644 logging.ini %{buildroot}%{_sysconfdir}/nocpulse/logging.ini

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
%dir %{_sysconfdir}/nocpulse
%config(noreplace) %{_sysconfdir}/nocpulse/logging.ini
%dir %{perl_vendorlib}/NOCpulse
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*

%changelog
* Thu Jan 29 2009 Miroslav Suchy <msuchy@redhat.com> 1.23.12-1
- own %%{perl_vendorlib}/NOCpulse
- silent rpmlint by $RPM_BUILD_ROOT prefix to %%install
- move logging.ini from Makefile.PL to spec

* Wed Jan 28 2009 Dennis Gilmore <dennis@ausil.us> 1.23.10-1
- fix up spec so we can build

* Tue Jan 27 2009 Dennis Gilmore <dennis@ausil.us> 1.23.9-1
- BR perl(ExtUtils::MakeMaker)

* Fri Oct 17 2008 Milan Zazrivec 1.23.8-1
- fixed build-time issues

* Tue Oct 14 2008 Miroslav Suchy <msuchy@redhat.com>
- edit comment before url and fix dependecy

* Tue Aug 19 2008 Miroslav Suchy <msuchy@redhat.com> 1.23.7-1
- edit spec to comply with Fedora Guidelines

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.23.4-7
- fixed file permissions

* Wed May 28 2008 Jan Pazdziora 1.23.4-6
- rebuild in dist-cvs
