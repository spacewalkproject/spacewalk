Name:         perl-NOCpulse-Gritch
Version:      2.3.0
Release:      1%{?dist}
Summary:      Perl throttled email notification for Spacewalk
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildArch:    noarch
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires: perl(NOCpulse::Config)
BuildRequires: perl(NOCpulse::Debug) perl(ExtUtils::MakeMaker)
BuildRequires: perl(Mail::Send)
BuildRequires: perl-libwww-perl
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
%{perl_vendorlib}/*
%{_mandir}/man3/*
%doc LICENSE

%changelog
* Tue Feb 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- 1069332 - ifconfig without agrs showed only UP intefaces
- 1069332 - ifconfig don't show Infiniband addresses properly

* Mon Jul 30 2012 Jan Pazdziora 1.27.11-1
- 636211 - Mail::Send does not handle From as special case, need to set with
  set.
- %%defattr is not needed since rpm 4.4

* Thu May 03 2012 Michael Mraka <michael.mraka@redhat.com> 1.27.10-1
- 768188 - return mac address of the first available interface

* Wed Mar 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.27.9-1
- LWP::UserAgent is required by tesl.pl (tests run in buildtime)
- 493028 - get_sendmail() has been already removed

