Name:           perl-Crypt-OpenPGP
Version:        1.03
Release:        14%{?dist}
Summary:        Crypt-OpenPGP Perl module

Group:          Development/Libraries
License:        GPL+ or Artistic
URL:            http://search.cpan.org/~btrott/Crypt-OpenPGP-1.03/lib/Crypt/OpenPGP.pm
Source0:        http://search.cpan.org/CPAN/authors/id/B/BT/BTROTT/Crypt-OpenPGP-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(Module::Build)
BuildRequires:  perl(Data::Buffer)
BuildRequires:  perl(Math::Pari)
BuildRequires:  perl(Compress::Zlib)
BuildRequires:  perl(LWP::UserAgent)
BuildRequires:  perl(URI::Escape)
BuildRequires:  perl(Crypt::DSA)
BuildRequires:  perl(Crypt::RSA)
BuildRequires:  perl(Crypt::RIPEMD160)
BuildRequires:  perl(Crypt::Rijndael)
BuildRequires:  perl(Crypt::CAST5_PP)
Requires:  perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
#checking that these are picked up by RPM
#Requires: perl(Data::Buffer)
#Requires: perl(Crypt::RIPEMD160)
#Requires: perl(Crypt::RSA)
#Requires: perl(Crypt::DSA)
#Requires: perl(URI::Escape)
#Requires: perl(LWP::UserAgent)
#Requires: perl(Compress::Zlib)
#Requires: perl(Math::Pari)

%description
Crypt-OpenPGP Perl module

%prep
%setup -q


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
%doc README ToDo CREDITS Changes
%{perl_vendorlib}/*
%{_mandir}/man3/*.3*


%changelog
* Tue Aug 26 2008 Dennis Gilmore <dgilmore@redhat.com> - 1.03-14
- rewrite the old spec
