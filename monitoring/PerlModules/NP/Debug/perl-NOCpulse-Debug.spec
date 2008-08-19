Name:         perl-NOCpulse-Debug
Version:      1.23.5
Release:      0%{?dist}
Summary:      Perl debug output package
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/PerlModules/NP/Debug
# make test-srpm
URL:          https://fedorahosted.org/spacewalk
Source0:      %{name}-%{version}.tar.gz
BuildArch:    noarch
Requires(pre): nocpulse-common
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
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
* Tue Aug 19 2008 Miroslav Suchy <msuchy@redhat.com>
- edit spec to comply with Fedora Guidelines

* Thu Jun 19 2008 Miroslav Suchy <msuchy@redhat.com>
- migrating nocpulse home dir (BZ 202614)

* Wed Jun  4 2008 Milan Zazrivec <mzazrivec@redhat.com> 1.23.4-7
- fixed file permissions

* Wed May 28 2008 Jan Pazdziora 1.23.4-6
- rebuild in dist-cvs
