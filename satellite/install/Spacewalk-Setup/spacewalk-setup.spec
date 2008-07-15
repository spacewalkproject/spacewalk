Name:           spacewalk-setup
Version:        0.01
Release:        3%{?dist}
Summary:        Initial setup tools for Red Hat Spacewalk

Group:          Applications/System
License:        GPLv2
URL:            http://spacewalk.redhat.com
Source0:        %{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  perl
## non-core
#BuildRequires:  perl(Getopt::Long), perl(Pod::Usage)
#BuildRequires:  perl(Test::Pod::Coverage), perl(Test::Pod)

BuildArch: noarch
Requires:  perl
Requires:  perl-Params-Validate


%description
A collection of post-installation scripts for managing Spacewalk's initial
setup tasks, re-installation, and upgrades.


%prep
%setup -q -n Spacewalk-Setup


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
install -m 0755 share/install-db.sh %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0755 share/remove-db.sh %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0755 share/upgrade-db.sh %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0755 share/embedded_diskspace_check.py %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/defaults.conf %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/sudoers.base %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/sudoers.rhn %{buildroot}/%{_datadir}/spacewalk/setup/
install -m 0644 share/spacewalk-public.cert %{buildroot}/%{_datadir}/spacewalk/setup/

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
* Wed Jun  4 2008 Devan Goodwin <dgoodwin@redhat.com> 0.01-1
- Initial packaging.

