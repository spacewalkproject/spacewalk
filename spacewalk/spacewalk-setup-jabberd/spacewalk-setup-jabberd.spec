Name:           spacewalk-setup-jabberd
Version:        1.4.0
Release:        1%{?dist}
Summary:        Tools to setup jabberd for Spacewalk
Group:          Applications/System
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:  perl
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildArch:      noarch
Requires:       perl
Requires:       libxslt
Requires:       jabberd

%description
Script, which setup Jabberd for Spacewalk. Used during installation of
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
%defattr(-,root,root,-)
%doc LICENSE
%{_bindir}/spacewalk-setup-jabberd
%{_mandir}/man1/*
%dir %{_datadir}/spacewalk
%{_datadir}/spacewalk/*
%dir %{_sysconfdir}/pki/spacewalk
%dir %{_sysconfdir}/pki/spacewalk/jabberd

%changelog
* Tue Dec 14 2010 Jan Pazdziora 1.3.2-1
- We need to check the return value of GetOptions and die if the parameters
  were not correct.
- spacewalk-setup-jabberd should own /usr/share/spacewalk (msuchy@redhat.com)

* Thu Nov 25 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.3.1-1
- sm.xsl for jabberd ver. 2.2.11

* Tue Nov 02 2010 Jan Pazdziora 1.2.2-1
- Update copyright years in the rest of the repo.

* Fri Sep 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.2.1-1
- point c2s to server.pem contained in the rhn-org-* pkg

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

* Thu Feb 18 2010 Miroslav Suchy <msuchy@redhat.com> 0.9.1-1
- Split from package spacewalk-setup.

