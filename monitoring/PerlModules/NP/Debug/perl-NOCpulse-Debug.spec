Name:         perl-NOCpulse-Debug
Version:      2.2.0
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
%config(noreplace) %{_sysconfdir}/nocpulse/logging.ini
%dir %{perl_vendorlib}/NOCpulse
%{perl_vendorlib}/NOCpulse/*
%{_mandir}/man3/*
%doc LICENSE

%changelog
* Tue Jul 19 2011 Jan Pazdziora 1.23.17-1
- Updating the copyright years.

* Fri Feb 18 2011 Jan Pazdziora 1.23.16-1
- Use three-parameter opens.

