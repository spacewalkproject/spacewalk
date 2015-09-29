Name:           spacewalk-setup-jabberd
Version:        2.5.0
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
* Thu Mar 19 2015 Grant Gainey 2.3.2-1
- Updating copyright info for 2015

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.1-1
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files
- Bumping package versions for 2.3.
- Bumping package versions for 2.2.
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Fri Jan 04 2013 Jan Pazdziora 1.9.1-1
- 858689 - simplify the code
- 858689 - correct check for /proc/net/if_inet6 size

* Tue Oct 30 2012 Jan Pazdziora 1.8.7-1
- Update the copyright year.

* Thu Sep 20 2012 Jan Pazdziora 1.8.6-1
- 857284 - don't setup ipv6 if /proc/net/if_inet6 is empty

* Mon Aug 27 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.5-1
- 807479 - correct description

* Wed Aug 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.4-1
- 800297 - s2s: enable resolve-ipv6

* Mon Jun 11 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.3-1
- there's no spacewalk-branding in spacewalk-proxy

* Mon May 21 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.1-1
- %%defattr is not needed since rpm 4.4
- 807479 - simplify pki declaration
- 807479 - require spacewalk-branding
- Bumping package versions for 1.8.

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.5-1
- update copyright info

* Wed Oct 26 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.4-1
- s2s.xml: no need to setup /s2s/local/resolver

* Wed Oct 19 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.3-1
- spacewalk-setup-jabberd: update router.xml configuration

* Fri Oct 07 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.2-1
- 715299 - jabberd IPv6 configuration

* Mon Aug 01 2011 Jan Pazdziora 1.6.1-1
- 726708 - change interval & keepalive only when different from default values
  (mzazrivec@redhat.com)
- 726708 - jabberd: set keepalive and interval to 60 (mzazrivec@redhat.com)

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

