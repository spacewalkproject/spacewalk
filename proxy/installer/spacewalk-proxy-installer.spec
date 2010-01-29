Name: spacewalk-proxy-installer
Summary: Spacewalk Proxy Server Installer
Group:   Applications/Internet
License: GPLv2
Version: 0.8.2
Release: 1%{?dist}
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root-%(%{__id_u} -n)
BuildArch: noarch

Summary: Command Line Installer of Spacewalk Proxy Server
Group:    Applications/Internet
Requires: rhncfg-client
Requires: rhncfg
Requires: rhncfg-management
Requires: rhncfg-actions
Requires: glibc-common
Requires: chkconfig
Requires: libxslt
BuildRequires: /usr/bin/docbook2man
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
# default access_log is already set on RHEL4
%if 0%{?rhel} == 4
perl -i -pe 's/access_log \S+ squid//;' squid.conf
%endif

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
mkdir -p $RPM_BUILD_ROOT/%{_mandir}/man8
mkdir -p $RPM_BUILD_ROOT/%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT/%{_usr}/share/rhn/installer
install -m 755 -d $RPM_BUILD_ROOT%{defaultdir}
install -m 644 c2s.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 sm.xml $RPM_BUILD_ROOT%{defaultdir}
install -m 644 cluster.ini $RPM_BUILD_ROOT%{defaultdir}
install -m 644 squid.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 644 rhn.conf $RPM_BUILD_ROOT%{defaultdir}
install -m 755 configure-proxy.sh $RPM_BUILD_ROOT/%{_usr}/sbin
install -m 755 rhn-proxy-activate $RPM_BUILD_ROOT%{_bindir}
install -m 644 rhn_proxy_activate.py $RPM_BUILD_ROOT%{_usr}/share/rhn/installer
install -m 644 get_system_id.xslt $RPM_BUILD_ROOT%{_usr}/share/rhn/
install -m 644 __init__.py $RPM_BUILD_ROOT%{_usr}/share/rhn/installer/
install -m 644 rhn-proxy-activate.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/
install -m 644 configure-proxy.sh.8.gz $RPM_BUILD_ROOT%{_mandir}/man8/

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%dir %{defaultdir}
%{defaultdir}/c2s.xml
%{defaultdir}/sm.xml
%{defaultdir}/cluster.ini
%{defaultdir}/squid.conf
%{defaultdir}/rhn.conf
%{_usr}/sbin/configure-proxy.sh
%{_mandir}/man8/*
%dir %{_usr}/share/rhn/installer
%{_usr}/share/rhn/installer/__init__.py*
%{_usr}/share/rhn/installer/rhn_proxy_activate.py*
%{_usr}/share/rhn/get_system_id.xslt
%{_bindir}/rhn-proxy-activate
%doc LICENSE answers.txt

%changelog
* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.8.2-1
- 543879 - adding support to the proxy side to redirect to a url 
  that will rewrite kickstarts with the proxy name for /cblr 
  urls (jsherril@redhat.com)

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rebuild for spacewalk 0.8

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.2-1
- 516624 - allow upgrade proxy using CLI to 5.3 from 5.0

* Wed Aug 12 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.1-1
- 503187 - upgrade after activation

* Wed Jul 29 2009 John Matthews <jmatthew@redhat.com> 0.6.21-1
- 493060 - do not send email "RHN Monitoring Scout started" by default
  (msuchy@redhat.com)

* Mon Jul 20 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.20-1
- 496615 - take up 1 as yes

* Mon Jul 13 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.19-1
- 509450 - install our jabberd ssl cert during proxy installation

* Mon Jul 06 2009 John Matthews <jmatthew@redhat.com> 0.6.18-1
- 509522 - remove conflicts and put provides to spacewalk-proxy-management
  (msuchy@redhat.com)

* Thu Jul  2 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.17-1
- 509417 - do not bother with monitoring if our parent is hosted

* Tue Jun 23 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.16-1
- suggest sane default value of proxy for spacewalk too

* Wed Jun 17 2009 Michael Mraka <michael.mraka@redhat.com> 0.6.15-1
- fixed sgml errors in %%build
- removed access_log directive on RHEL4

* Tue Jun 16 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.14-1
- 499399 - print scout shared key on output

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.13-1
- 505325 - pass two parameters as two parameters

* Wed Jun 10 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.12-1
- runtime error - global name 's' is not defined
- 504660 - fix typo in message

* Fri Jun 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.11-1
- 499399 - read SCOUT_SHARED_KEY value from api call
  proxy.createMonitoringScout (msuchy@redhat.com)
- enable services (msuchy@redhat.com)
- 499399 - update rhn-proxy-activate man page (msuchy@redhat.com)
- fix docbook warnings (msuchy@redhat.com)
- 499399 - call proxy.createMonitoringScout during proxy activation
  (msuchy@redhat.com)
- 500151 - do not insist on presence of sslbuildir if we force own CA
  (msuchy@redhat.com)
- 500151 - flip the condition, so force-own-ca do what it should do
  (msuchy@redhat.com)
- 499789 - check for /root/ssl-build separately and fix scp command
  (msuchy@redhat.com)
- 502103 - fix syntax error (msuchy@redhat.com)

* Tue May 19 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.10-1
- 498251 - suggest as default proxy version latest version available on parent

* Thu May 14 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.9-1
- 497892 - create access.log on rhel5

* Tue May 12 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.8-1
- 500151 - add --force-own-ca option
- 500215 - we need rhn-ca-openssl.cnf as well
- 499789 - say user to create $SSL_BUILD_DIR and make $SSL_BUILD_DIR relalocatable

* Mon May 11 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.7-1
- 489607 - add command flag for every option in the answer file

* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.6-1
- be precise in terminology: it -> monitoring scout (msuchy@redhat.com)

* Tue May  5 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.5-1
- 497929 - use parent CA

* Wed Apr 15 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.3-1
- 495194 - install cluster.ini only if monitoring is enabled
  (msuchy@redhat.com)
- 469060 - do not try to deactivate if we are not proxy (msuchy@redhat.com)

* Tue Apr  7 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.2-1
- fix various errors in configure-proxy.sh

* Mon Apr 06 2009 Miroslav Suchý <msuchy@redhat.com> 0.6.1-1
- 494290 - change ownership after apache is installed (msuchy@redhat.com)
- bump Versions to 0.6.0 (jesusr@redhat.com)

* Mon Mar 30 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.25-1
- 492871 - do not depend on apache user when it not yet available

* Mon Mar 30 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.24-1
- reformated configure-proxy.sh

* Thu Mar 26 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.23-1
- 486125 - if some option is present in answer file, use it even if empty
- remove dependency on httpd which conflict with older proxies, let
  httpd be downloaded through spacewalk-proxy-management

* Wed Mar 18 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.21-1
- 489669 - fixed non-interactive mode

* Thu Mar 12 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.19-1
- 489674 - warn if user select rhn.redhat.com as parent without xmlrpc. prefix

* Mon Mar  2 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.17-1
- enable scout by default if monitoring is enabled

* Wed Feb 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.16-1
- 486126 - deactivate proxy if installer fail

* Mon Feb 23 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.13-1
- 486125 - populate answers file with all options

* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.12-1
- 479541, 483867 - replaced runuser with /sbin/runuser

* Thu Jan 29 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.11-1
- rewritten configure-proxy.sh

* Tue Jan 27 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.8-1
- 469035 - populate configuration channel with new version of configuration files
- 468924 - die and warn if CA CERT is not readable by apache user
- 468041 - parse sslCACert correctly

* Fri Jan 23 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.4-1
- 469059 - add --non-interactive option
- add LICENSE to %%doc
- add example of answer file

* Thu Jan 22 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.3-1
- 469059 - add --answer-file option

* Tue Jan 20 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.2-1
- 480328 - enable services after installation

* Mon Jan 19 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.1-1
- 480341 - /etc/init.d/rhn-proxy should be in /etc/rc.d/init.d/rhn-proxy

* Fri Dec 19 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.4-1
- add man page for configure-proxy.sh and --help option

* Mon Dec  8 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.3-1
- fixed Obsoletes: rhns-* < 5.3.0

* Fri Nov 14 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.2-1
- BZ 470381 - conflict with older rhns-proxy-tools

* Fri Oct 17 2008 Miroslav Suchý <msuchy@redhat.com> 0.3.3-1
- BZ 467383 -  Force to cache rpm files for one year

* Tue Oct  7 2008 Miroslav Suchý <msuchy@redhat.com> 0.3.2-1
- BZ 465524 - squid cache should be in MB

* Wed Oct  1 2008 Miroslav Suchý <msuchy@redhat.com> 0.3.1-1
- move rhn-proxy-activate to installer

* Tue Sep  9 2008 Miroslav Suchý 0.2.3-1
- replace certs in ssl.conf

* Thu Sep  4 2008 Miroslav Suchý 0.2.2-1
- add SSL support
- add " around params

* Tue Sep  2 2008 Milan Zazrivec 0.2.1-1
- Fixed package requirements

* Thu Aug  7 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-2
- rename to spacewalk-proxy-installer
- rewrite %%description

* Tue Aug  6 2008 Miroslav Suchy <msuchy@redhat.com> 0.1-1
- rename to spacewalk
- clean up spec

* Tue Jun 17 2008 Miroslav Suchy <msuchy@redhat.com>
- initial version

