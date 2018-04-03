%if 0%{?fedora} || 0%{?rhel} >= 7
%{!?pylint_check: %global pylint_check 1}
%endif

%if 0%{?fedora}
%global build_py3   1
%endif

Name: spacewalk-proxy-installer
Summary: Spacewalk Proxy Server Installer
License: GPLv2
Version: 2.9.0
Release: 1%{?dist}
URL:     https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch

Requires: rhncfg-client
Requires: rhncfg
Requires: rhncfg-management
Requires: rhncfg-actions
Requires: glibc-common

%if 0%{?fedora}
Requires: hostname
%endif
%if 0%{?rhel} > 5
Requires: net-tools
%endif

Requires: chkconfig
Requires: libxslt
Requires: spacewalk-certs-tools >= 1.6.4
%if 0%{?pylint_check}
BuildRequires: spacewalk-python2-pylint
BuildRequires: python2-rhn-client-tools
%endif
BuildRequires: /usr/bin/docbook2man

%if 0%{?fedora} || 0%{?rhel} > 5
Requires: rhnlib
Requires: rhn-client-tools > 2.8.4
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
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
mkdir -p $RPM_BUILD_ROOT/%{_mandir}/man8
mkdir -p $RPM_BUILD_ROOT/%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT/%{_usr}/share/rhn/installer/jabberd
install -m 755 -d $RPM_BUILD_ROOT%{defaultdir}
install -m 644 squid.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 rhn.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 cobbler-proxy.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 insights-proxy.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 755 configure-proxy.sh $RPM_BUILD_ROOT/%{_usr}/sbin
install -m 644 get_system_id.xslt $RPM_BUILD_ROOT%{_usr}/share/rhn/
install -m 644 rhn-proxy-activate.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 644 configure-proxy.sh.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 640 jabberd/sm.xml jabberd/c2s.xml $RPM_BUILD_ROOT%{_usr}/share/rhn/installer/jabberd

%if 0%{?build_py3}
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' rhn-proxy-activate.py
%endif
install -m 755 rhn-proxy-activate.py $RPM_BUILD_ROOT%{_bindir}/rhn-proxy-activate

%clean

%check
%if 0%{?pylint_check}
# check coding style
spacewalk-python2-pylint .
%endif

%files
%dir %{defaultdir}
%{defaultdir}/squid.conf
%{defaultdir}/rhn.conf
%{defaultdir}/cobbler-proxy.conf
%{defaultdir}/insights-proxy.conf
%{_usr}/sbin/configure-proxy.sh
%{_mandir}/man8/*
%dir %{_usr}/share/rhn/installer
%{_usr}/share/rhn/installer/jabberd/*.xml
%{_usr}/share/rhn/get_system_id.xslt
%{_bindir}/rhn-proxy-activate
%doc LICENSE answers.txt

%changelog
* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 2.8.6-1
- Update to use newly separated spacewalk-python[2|3]-pylint packages

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Sun Oct 15 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.4-1
- fix dependencies for spacewalk-proxy-installer

* Thu Oct 05 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- remove python2 code from confgure-proxy.sh
- hostname may not be installed by default in containers
- make rhn-proxy-activate python3 compatible
- use python3 on Fedora
- removed unnecessary wrapper around the actual rhn-proxy-activate code
- pylint requires rhncfg-client

* Wed Oct 04 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.2-1
- 1459901 - write all answers into answer file, not just fresh ones

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.6-1
- update copyright year

* Thu Jul 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.5-1
- more pylint fixes

* Thu Jul 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.4-1
- fixed pylint warnings

* Mon May 29 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.3-1
- 1390665 - disable config channel population by default in non-interactive
  mode
- add some small pep8 fixes for proxy code
- wrong-import-position is not present in pylint on Fedora 23

* Wed Mar 15 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.2-1
- Fixing wrong-import-position (C0413) for proxy_installer
- 1188508 - fix typos
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Mon Jan 09 2017 Gennadii Altukhov <galt@redhat.com> 2.7.1-1
- 1410395 - add options for rhn-user and rhn-password
- Bumping package versions for 2.7.

* Tue Nov 01 2016 Gennadii Altukhov <galt@redhat.com> 2.6.5-1
- 1390665 - ask user for credentials only if configuration script works in
  interactive mode

* Fri Sep 23 2016 Jan Dobes 2.6.4-1
- fix bz1340031 - yes_no: command not found

* Thu Sep 15 2016 Jan Dobes 2.6.3-1
- fixing pylint: misplaced-bare-raise

* Wed Sep 14 2016 Gennadii Altukhov <galt@redhat.com> 2.6.2-1
- 1367918 - Add httpd config for Insights Service on RHN Proxy

* Mon Jun 27 2016 Tomas Lestach <tlestach@redhat.com> 2.6.1-1
- fix import order
- Bumping package versions for 2.6.

* Thu Feb 25 2016 Jan Dobes 2.5.2-1
- 647105 - filter only existing config files

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

