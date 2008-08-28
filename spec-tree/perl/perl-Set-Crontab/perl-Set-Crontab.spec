Name:           perl-Set-Crontab
Version:        1.02
Release:        1%{?dist}
Summary:        Set-Crontab perl module

Group:          Development/Libraries
License:        GPL+ or Artistic
URL:            http://search.cpan.org/dist/Set-Crontab/
Source0:        http://search.cpan.org/CPAN/authors/id/A/AM/AMS/Set-Crontab-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Set-Crontab perl module

%prep
%setup -q -n Set-Crontab-%{version}


%build
%{__perl} Makefile.PL INSTALLDIRS=vendor 
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} ';'
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null ';'
chmod -R u+w $RPM_BUILD_ROOT/*


%check
make test


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc README
%{perl_vendorlib}/*
%{_mandir}/man3/*.3*


%changelog
* Thu Aug 28 2008 Dennis Gilmore <dgilmore@redhat.com> - 1.02-1
- initial packaging

