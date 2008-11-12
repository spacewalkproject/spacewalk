Name:           spacewalk-setup
Version:        0.4.2
Release:        1%{?dist}
Summary:        Initial setup tools for Red Hat Spacewalk

Group:          Applications/System
License:        GPLv2
URL:            http://spacewalk.redhat.com
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  perl
BuildRequires:  perl(ExtUtils::MakeMaker)
## non-core
#BuildRequires:  perl(Getopt::Long), perl(Pod::Usage)
#BuildRequires:  perl(Test::Pod::Coverage), perl(Test::Pod)

BuildArch:      noarch
Requires:       perl
Requires:       perl-Params-Validate
Requires:       spacewalk-schema
Requires:       /sbin/restorecon

%description
A collection of post-installation scripts for managing Spacewalk's initial
setup tasks, re-installation, and upgrades.


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
install -m 0755 share/embedded_diskspace_check.py %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/defaults.conf %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/sudoers.base %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/sudoers.rhn %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/spacewalk-public.cert %{buildroot}/%{_datadir}/spacewalk/setup/

# Oracle specific stuff, possible candidate for sub-package down the road:
install -d -m 755 %{buildroot}/%{_datadir}/spacewalk/setup/oracle/
install -m 0755 share/oracle/install-db.sh %{buildroot}/%{_datadir}/spacewalk/setup/oracle
install -m 0755 share/oracle/remove-db.sh %{buildroot}/%{_datadir}/spacewalk/setup/oracle
install -m 0755 share/oracle/upgrade-db.sh %{buildroot}/%{_datadir}/spacewalk/setup/oracle


%check
make test


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc Changes README
%{perl_vendorlib}/*
%{_bindir}/spacewalk-setup
%{_mandir}/man[13]/*.[13]*
%{_datadir}/spacewalk/*


%changelog
* Tue Nov 18 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.2-1
- enable Monitoring services (#471220)

* Thu Oct 30 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.1-1
- resolved #455421

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.6-1
- resolves #467877 - use runuser instead of su

* Tue Oct 21 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.5-1
- Remove dependency on spacewalk-dobby. (only needed for embedded Oracle installations)

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.4-1
- resolves #467717 - fixed sysvinit scripts

* Mon Sep 22 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.3-1
- Remove explicit chmod/chown on /var/log/rhn/.

* Thu Sep 18 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.2-1
- Fix bug with /var/log/rhn/ permissions.

* Wed Sep  3 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.2.4-1
- include correct namespace when invoking system_debug()
- build-require perl(ExtUtils::MakeMaker) rather than package name

* Fri Aug 22 2008 Mike McCune <mmccune@redhat.com 0.2.2-2
- adding BuildRequires perl-ExtUtils-MakeMaker

* Wed Aug 20 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.2-1
- Updating build for spacewalk 0.2.

* Wed Jun  4 2008 Devan Goodwin <dgoodwin@redhat.com> 0.01-1
- Initial packaging.

