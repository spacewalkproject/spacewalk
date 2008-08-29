Name:           perl-Set-Crontab
Version:        1.02
Release:        1%{?dist}
Summary:        Expand crontab(5)-style integer lists
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Set-Crontab/
Source0:        http://www.cpan.org/modules/by-module/Set/Set-Crontab-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Set::Crontab parses crontab-style lists of integers and defines some
utility functions to make it easier to deal with them.

%prep
%setup -q -n Set-Crontab-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes README
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Thu Jul 31 2008 Miroslav Suchý <msuchy@redhat.com> 1.02-1
- Change license to "as Perl itself"

* Sun Jun 22 2008 Michael Stahnke <mastahnke@gmail.com> - 1.00-1
- Repackaging from Spacewalk repo to aid in Fedora packaging

