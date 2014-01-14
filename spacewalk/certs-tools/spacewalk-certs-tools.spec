Name: spacewalk-certs-tools
Summary: Spacewalk SSL Key/Cert Tool
Group: Applications/Internet
License: GPLv2
Version: 2.1.6
Release: 1%{?dist}
URL:      https://fedorahosted.org/spacewalk 
Source0:  https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: openssl rpm-build
Requires: rhn-client-tools
Requires: tar
Requires: spacewalk-backend-libs >= 0.8.28
Requires: /usr/bin/sudo
BuildRequires: docbook-utils
BuildRequires: python
Obsoletes: rhns-certs < 5.3.0
Obsoletes: rhns-certs-tools < 5.3.0
# can not provides = %{version} since some old packages expect > 3.6.0
Provides:  rhns-certs = 5.3.0
Provides:  rhns-certs-tools = 5.3.0

%description
This package contains tools to generate the SSL certificates required by 
Spacewalk.

%global rhnroot %{_datadir}/rhn

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{rhnroot}/certs
make -f Makefile.certs install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}
chmod 755 $RPM_BUILD_ROOT/%{rhnroot}/certs/{rhn_ssl_tool.py,client_config_update.py,rhn_bootstrap.py}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%dir %{rhnroot}/certs
%{rhnroot}/certs/*.py*
%attr(755,root,root) %{rhnroot}/certs/sign.sh
%attr(755,root,root) %{rhnroot}/certs/gen-rpm.sh
%attr(755,root,root) %{_bindir}/rhn-sudo-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-ssl-tool
%attr(755,root,root) %{_bindir}/rhn-bootstrap
%doc %{_mandir}/man1/rhn-*.1*
%doc LICENSE
%doc ssl-howto-simple.txt ssl-howto.txt
%{_var}/www/html/pub/bootstrap/client_config_update.py*

%changelog
* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.6-1
- Updating the copyright years info

* Fri Jan 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.5-1
- 1040682 - older Proxies don't implement PRODUCT_NAME

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- cleaning up old svn Ids

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- removed trailing whitespaces

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- Grammar error occurred

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in cert-tools dir
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- updating copyright years

* Wed Jun 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.7-1
- product name fix

* Tue Jun 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.6-1
- simplify product name logic

* Tue Jun 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- minor branding cleanup

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.4-1
- branding fixes in man pages
- more branding cleanup

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.3-1
- rebranding RHN Proxy to Red Hat Proxy
- rebrading RHN Satellite to Red Hat Satellite

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.2-1
- misc branding clean up

* Mon Mar 25 2013 Jan Dobes <jdobes@redhat.com> 1.10.1-1
- Adding sudo Requires for spacewalk-certs-tools package
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.5-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.4-1
- Updating copyright for 2012

* Mon Feb 11 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.3-1
- cleanup old CVS files

* Tue Jan 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.2-1
- tar isn't installed by default on Fedora 18

* Wed Oct 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.1-1
- 862349 - create rpms compatible with RHEL5

* Wed Oct 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.4-1
- download CA cert via http

* Tue Oct 30 2012 Jan Pazdziora 1.8.3-1
- Update the copyright year.

* Wed Jul 04 2012 Jan Pazdziora 1.8.2-1
- 693290 - observe the --set-hostname parameter.
- %%defattr is not needed since rpm 4.4

* Wed Mar 21 2012 Jan Pazdziora 1.8.1-1
- Always regenerate server.pem for jabberd.

* Fri Mar 02 2012 Jan Pazdziora 1.7.3-1
- Update the copyright year info.

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.2-1
- we are now just GPL

* Fri Feb 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.1-1
- code cleanup

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.7-1
- update copyright info

* Wed Oct 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.6-1
- removed dead function getCertValidityRange()
- removed dead function getCertValidityDates()
- removed dead function getExistingOverridesConfig()

* Fri Sep 30 2011 Jan Pazdziora 1.6.5-1
- 689939 - allow rhn-ssl-tool to work with --set-hostname='*.example.com'.

* Wed Aug 24 2011 Miroslav Suchý 1.6.4-1
- if subjectAltName is used, hostname must be present in dNSName

* Tue Aug 23 2011 Miroslav Suchý 1.6.3-1
- do not fail if --set-cname is not specified

* Mon Aug 22 2011 Miroslav Suchý 1.6.2-1
- ability to generate multihost ssl certificate

* Fri Aug 19 2011 Miroslav Suchý 1.6.1-1
- code cleanup

* Tue Jul 19 2011 Jan Pazdziora 1.5.3-1
- Updating the copyright years.

* Fri May 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.2-1
- 704979 - use https:// for fetching org ca cert

* Fri Apr 15 2011 Jan Pazdziora 1.5.1-1
- support zypper in bootstrap script and allow multiple GPG keys (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 1.4.1-1
- Bumping package versions for 1.4 (tlestach@redhat.com)
- updating Copyright years for year 2011 (tlestach@redhat.com)

* Tue Jan 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- fixed rpmlint errors
- Updating the copyright years to include 2010.

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- removed unused imports

* Tue Nov 02 2010 Jan Pazdziora 1.2.2-1
- Update copyright years in the rest of the repo.

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.1-1
- replaced local copy of compile.py with standard compileall module
- removed dead code

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

