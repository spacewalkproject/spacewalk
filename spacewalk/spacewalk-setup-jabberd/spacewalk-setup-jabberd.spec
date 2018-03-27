Name:           spacewalk-setup-jabberd
Version:        2.8.4
Release:        1%{?dist}
Summary:        Tools to setup jabberd for Spacewalk
License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
%if 0%{?fedora} && 0%{?fedora} > 26
BuildRequires:  perl-interpreter
%else
BuildRequires:  perl
%endif
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildArch:      noarch
%if 0%{?fedora} && 0%{?fedora} > 26
Requires:       perl-interpreter
%else
Requires:       perl
%endif
Requires:       libxslt
Requires:       jabberd
Requires:       sqlite
Requires:       %{_datadir}/spacewalk

%description
Script, which sets up Jabberd for Spacewalk. Used during installation of
Spacewalk server or Spacewalk proxy.

%prep
%setup -q


%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}


%install
rm -rf %{buildroot}
make pure_install PERL_INSTALL_ROOT=%{buildroot}
find %{buildroot} -type f -name .packlist -exec rm -f {} ';'
find %{buildroot} -type d -depth -exec rmdir {} 2>/dev/null ';'
chmod -R u+w %{buildroot}/*
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/jabberd
install -m 0644 share/jabberd/* %{buildroot}/%{_datadir}/spacewalk/setup/jabberd/

# jabberd ssl cert location
install -d -m 755 %{buildroot}/%{_sysconfdir}/pki/spacewalk/jabberd

%check
make test


%clean
rm -rf %{buildroot}


%files
%doc LICENSE
%{_bindir}/spacewalk-setup-jabberd
%{_mandir}/man1/*
%{_datadir}/spacewalk/*
%{_sysconfdir}/pki/spacewalk

%changelog
* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.4-1
- 1533052 - Add FQDN detection to setup and config utilities.

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Nov 27 2017 Jan Dobes <jdobes@redhat.com> 2.8.2-1
- sqlite is not installed by default on Fedora

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Wed Aug 16 2017 Eric Herget <eherget@redhat.com> 2.7.4-1
- SW 2.7 Release prep - update copyright year (3rd pass)

* Mon Aug 14 2017 Eric Herget <eherget@redhat.com> 2.7.3-1
- 1480697 - Need to initialize the jabberd sqlite database during setup

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.2-1
- 1479849 - Requires: perl has been renamed to perl-interpreter on Fedora 27
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Fri May 05 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.1-1
- use sqlite as default osad database backend
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Thu Mar 19 2015 Grant Gainey 2.3.2-1
- Updating copyright info for 2015

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

