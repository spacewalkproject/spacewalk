%if 0%{?fedora}
%{!?pylint_check: %global pylint_check 1}
%endif

Name: spacewalk-proxy-installer
Summary: Spacewalk Proxy Server Installer
Group:   Applications/Internet
License: GPLv2
Version: 2.5.1
Release: 1%{?dist}
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch

Requires: rhncfg-client
Requires: rhncfg
Requires: rhncfg-management
Requires: rhncfg-actions
Requires: glibc-common
Requires: chkconfig
Requires: libxslt
Requires: spacewalk-certs-tools >= 1.6.4
%if 0%{?pylint_check}
BuildRequires: spacewalk-pylint
%endif
BuildRequires: /usr/bin/docbook2man
%if 0%{?fedora} || 0%{?rhel} > 5
BuildRequires: rhnlib
BuildRequires: rhn-client-tools
%endif

Obsoletes: proxy-installer < 5.3.0
Provides: proxy-installer = 5.3.0

%define defaultdir %{_usr}/share/doc/proxy/conf-template/

%description
The Spacewalk Proxy Server allows package proxying/caching
and local package delivery services for groups of local servers from
Spacewalk Server. This service adds flexibility and economy of
resources to package update and deployment.

This package includes command line installer of Spacewalk Proxy Server.
Run configure-proxy.sh after installation to configure proxy.

%prep
%setup -q

%build
/usr/bin/docbook2man rhn-proxy-activate.sgml
/usr/bin/gzip rhn-proxy-activate.8
/usr/bin/docbook2man configure-proxy.sh.sgml
/usr/bin/gzip configure-proxy.sh.8

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
mkdir -p $RPM_BUILD_ROOT/%{_mandir}/man8
mkdir -p $RPM_BUILD_ROOT/%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT/%{_usr}/share/rhn/installer/jabberd
install -m 755 -d $RPM_BUILD_ROOT%{defaultdir}
install -m 644 squid.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 rhn.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 cobbler-proxy.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 755 configure-proxy.sh $RPM_BUILD_ROOT/%{_usr}/sbin
install -m 755 rhn-proxy-activate $RPM_BUILD_ROOT%{_bindir}
install -m 644 rhn_proxy_activate.py $RPM_BUILD_ROOT%{_usr}/share/rhn/installer
install -m 644 get_system_id.xslt $RPM_BUILD_ROOT%{_usr}/share/rhn/
install -m 644 __init__.py $RPM_BUILD_ROOT%{_usr}/share/rhn/installer/
install -m 644 rhn-proxy-activate.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 644 configure-proxy.sh.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 640 jabberd/sm.xml jabberd/c2s.xml $RPM_BUILD_ROOT%{_usr}/share/rhn/installer/jabberd

%clean
rm -rf $RPM_BUILD_ROOT

%check
%if 0%{?pylint_check}
# check coding style
export PYTHONPATH=$RPM_BUILD_ROOT/usr/share/rhn:/usr/share/rhn
spacewalk-pylint $RPM_BUILD_ROOT/usr/share/rhn
%endif

%files
%dir %{defaultdir}
%{defaultdir}/squid.conf
%{defaultdir}/rhn.conf
%{defaultdir}/cobbler-proxy.conf
%{_usr}/sbin/configure-proxy.sh
%{_mandir}/man8/*
%dir %{_usr}/share/rhn/installer
%{_usr}/share/rhn/installer/__init__.py*
%{_usr}/share/rhn/installer/rhn_proxy_activate.py*
%{_usr}/share/rhn/installer/jabberd/*.xml
%{_usr}/share/rhn/get_system_id.xslt
%{_bindir}/rhn-proxy-activate
%doc LICENSE answers.txt

%changelog
* Tue Nov 24 2015 Jan Dobes 2.5.1-1
- rhn_proxy_activate: remove error conditions linked to provisioning
  entitlements
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.6-1
- Bumping copyright year.

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.5-1
- remove Except KeyboardInterrupt from imports

* Wed May 27 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.4-1
- fix pylint warning on Fedora 22

* Mon May 11 2015 Stephen Herr <sherr@redhat.com> 2.4.3-1
- 1220531 - don't cache debian Packages.gz repodata file for a year

* Thu Apr 30 2015 Stephen Herr <sherr@redhat.com> 2.4.2-1
- 1216100 - proxy config channels have extra space at the end

* Fri Apr 24 2015 Matej Kollar <mkollar@redhat.com> 2.4.1-1
- remove whitespace from .sgml files
- Bumping package versions for 2.4.

* Mon Mar 23 2015 Grant Gainey 2.3.13-1
- Standardize pylint-check to only happen on Fedora

* Thu Mar 19 2015 Grant Gainey 2.3.12-1
- Updating copyright info for 2015

* Wed Mar 18 2015 Stephen Herr <sherr@redhat.com> 2.3.11-1
- 1191253 - update squid directives to use if-modified-since header

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.10-1
- drop monitoring from proxy setup

* Tue Feb 03 2015 Stephen Herr <sherr@redhat.com> 2.3.9-1
- 1178151 - make squid start correctly on rhel 7

* Wed Jan 21 2015 Matej Kollar <mkollar@redhat.com> 2.3.8-1
- Fix Pylint on Fedora 21

* Wed Jan 14 2015 Matej Kollar <mkollar@redhat.com> 2.3.7-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Nov 28 2014 Tomas Lestach <tlestach@redhat.com> 2.3.6-1
- spacewalk-proxy-installer: remove duplicate Summary and Group entries

* Fri Nov 21 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.5-1
- 1166045 - read systemid path from configuration

* Fri Oct 31 2014 Stephen Herr <sherr@redhat.com> 2.3.4-1
- Disable pylint warning so things can build

* Thu Oct 30 2014 Stephen Herr <sherr@redhat.com> 2.3.3-1
- 1158916 - proxy installer should use http proxy to get version number
- 1158692 - minor usability updates to proxy installer

* Fri Oct 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- 1011455 - fixed missing function parameter

* Fri Oct 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- 1011455 - don't hardcode systemid path in rhn-proxy-activate

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- spec file polish

* Wed Oct 09 2013 Matej Kollar <mkollar@redhat.com> 2.1.6-1
- Honour behavior described in help
- Revert "Removed set_value as getopt made it redundant"
- Removing unhealthy options RHN_PARENT and CA_CHAIN
- fixed typo

* Mon Oct 07 2013 Matej Kollar <mkollar@redhat.com> 2.1.5-1
- Removed set_value as getopt made it redundant
- 516296 - Allow truly non-interactive proxy install
- Order list of options in help
- Allow user to save entered data as answer file
- There is no up2date anymore
- Eliminating eval where possible
- Some seemingly unimportant spaces
- Tabs vs. Spaces War

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- removed trailing whitespaces

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- refer systemIdPath from up2date config

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- Grammar error occurred

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in proxy dir
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.9-1
- updating copyright years

* Tue Jul 09 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- fixing spacewalk-proxy-installer BuildRequires

* Thu Jun 27 2013 Dimitar Yordanov <dyordano@redhat.com> 1.10.7-1
- 979038 - Obtain default options from up2date
- Revert "979038 - Obtain default options from up2date"

* Thu Jun 27 2013 Dimitar Yordanov <dyordano@redhat.com> 1.10.6-1
- 979038 - Obtain default options from up2date

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.5-1
- removed old CVS/SVN version ids
- branding fixes in man pages

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- rebranding RHN Proxy to Red Hat Proxy
- rebrading RHN Satellite to Red Hat Satellite

* Tue May 14 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.3-1
- 901732 - set default ip to monitoring_parent primary ip
- 901732 - fixed typo in MONITORING_PARENT name

* Wed Apr 03 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- 896125 - fixed missing arguments issue

* Fri Mar 29 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- 896125 - make Y/N values optional
- 896125 - report extra commandline arguments
- 896125 - fail if answer file is not readable
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.2-1
- made proxy installer systemd ready

* Mon Jan 28 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.1-1
- 896125 - use standard option parser

* Thu Jul 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.4-1
- make sure username/password is correct

* Fri May 11 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.3-1
- make pylint happy

* Thu May 10 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.2-1
- 695276 - if koan is requesting anything from /cobbller_api replace hostname
  of server with hostname of first proxy in chain

* Wed Mar 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.1-1
- do not run pylint check on RHEL5 and old Fedoras

* Fri Mar 02 2012 Jan Pazdziora 1.7.6-1
- Update the copyright year info.

* Fri Mar 02 2012 Jan Pazdziora 1.7.5-1
- remove duplicate entry (msuchy@redhat.com)

* Wed Feb 15 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.4-1
- fixed pylint errors
- use spacewalk-pylint for coding style check

* Mon Feb 13 2012 Miroslav Suchý 1.7.3-1
- add rhnlib as buildrequires

* Fri Feb 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.2-1
- added pylint check to specfile
- fixed pylint errors/warnings
* Fri Feb 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.1-1
- code cleanup

* Wed Oct 26 2011 Miroslav Suchý 1.6.7-1
- there is no rhn-proxy-debug for some time

* Mon Oct 24 2011 Miroslav Suchý 1.6.6-1
- increase maximum_object_size_in_memory
- comment some squid directives

* Wed Sep 21 2011 Miroslav Suchý 1.6.5-1
- 737853 - if rhn-ca-openssl.cnf does not exist, then check should succeed
- 737853 - do not print output of awk, we care just about exit code

* Tue Sep 13 2011 Miroslav Suchý 1.6.4-1
- require rhn-ssl-tool which can handle --set-cname option

* Mon Aug 29 2011 Miroslav Suchý 1.6.3-1
- check if "copy_extension=copy" is in correct section
- do not ask for SSL_CNAME if it set in answer file to empty array
- fail if CA configuration file do not copy extension

* Mon Aug 22 2011 Miroslav Suchý 1.6.2-1
- allow proxy installer to set cname alias

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.

* Fri Jul 15 2011 Miroslav Suchý 1.5.3-1
- optparse is here since python 2.3 - remove optik (msuchy@redhat.com)

* Thu Apr 28 2011 Miroslav Suchý 1.5.2-1
- 648868 - do not put proxy_broker.conf and proxy_redirect.conf to
  configuration channel (mmello@redhat.com)

* Mon Apr 18 2011 Miroslav Suchý 1.5.1-1
- 696918 - honor hostedWhitelist during Proxy installation
- Bumping package versions for 1.5

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.5-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- remove redundant comment (msuchy@redhat.com)

* Tue Jan 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.4-1
- fixed pylint errors
- Updating the copyright years to include 2010.

* Wed Dec 08 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.3-1
- 660344 - do not use spacwalk-setup-jabberd in RHN Proxy 5.3 and older

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- removed unused imports

* Wed Nov 10 2010 Jan Pazdziora 1.2.3-1
- remove escaping (msuchy@redhat.com)

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.2-1
- install cobbler-proxy.conf (msuchy@redhat.com)

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.1-1
- add cobbler-proxy.conf (msuchy@redhat.com)
- cut free cobbler-proxy.conf  from inline in configure-proxy.sh to regular
  file (msuchy@redhat.com)
- 648868 - do not put rhn_proxy.conf to configuration channel
  (msuchy@redhat.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.2-1
- check if repodata are fresh more often

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

