Name: spacewalk-proxy
Summary: Spacewalk Proxy Server
Group:   Applications/Internet
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 2.1.13
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n) 
BuildRequires: python
BuildArch: noarch
Requires: httpd
%if 0%{?fedora} > 15 || 0%{?rhel} > 5
# pylint check
BuildRequires: spacewalk-pylint
BuildRequires: rhnpush >= 5.5.52
BuildRequires: spacewalk-backend-libs >= 1.7.24
BuildRequires: spacewalk-backend >= 1.7.24
%endif

%define rhnroot %{_usr}/share/rhn
%define destdir %{rhnroot}/proxy
%define rhnconf %{_sysconfdir}/rhn
%define httpdconf %{_sysconfdir}/httpd/conf.d

%description
This package is never built.

%package management
Summary: Packages required by the SpacewalkManagement Proxy
Group:   Applications/Internet
Requires: squid
Requires: spacewalk-backend >= 1.7.24
# python-hashlib is optional for spacewalk-backend-libs
# but we need made it mandatory here
Requires: python-hashlib
Requires: spacewalk-base-minimal-config
Requires: %{name}-broker = %{version}
Requires: %{name}-redirect = %{version}
Requires: %{name}-common >= %{version}
Requires: %{name}-docs
Requires: %{name}-html
Requires: spacewalk-proxy-selinux
Requires: jabberd spacewalk-setup-jabberd
Requires: httpd
Requires: sos
Requires(preun): initscripts
Obsoletes: rhns-proxy < 5.3.0
Obsoletes: rhns-proxy-management < 5.3.0
BuildRequires: /usr/bin/docbook2man
Obsoletes: rhns-proxy-tools < 5.3.0
Provides: rhns-proxy-tools = 5.3.0
Obsoletes: spacewalk-proxy-tools < 0.5.3
Provides: spacewalk-proxy-tools = %{version}
Obsoletes: rhns-auth-daemon < 5.2.0
Provides: rhns-auth-daemon = 1:%{version}
Obsoletes: rhn-modssl < 2.9.0
Provides: rhn-modssl = 1:%{version}
Obsoletes: rhn-modpython < 2.8.0
Provides: rhn-modpython = 1:%{version}
Obsoletes: rhn-apache < 1.4.0
Provides: rhn-apache = 1:%{version}

%description management
This package require all needed packages for Spacewalk Proxy Server.

%package broker
Group:   Applications/Internet
Summary: The Broker component for the Spacewalk Proxy Server
Requires: squid
Requires: spacewalk-certs-tools
Requires: spacewalk-proxy-package-manager
Requires: spacewalk-ssl-cert-check
Requires: httpd
Requires: mod_ssl
Requires: mod_wsgi
Requires(post): %{name}-common
Conflicts: %{name}-redirect < %{version}-%{release}
Conflicts: %{name}-redirect > %{version}-%{release}
# We don't want proxies and satellites on the same box
Conflicts: rhns-satellite-tools
Obsoletes: rhns-proxy-broker < 5.3.0


%description broker
The Spacewalk Proxy Server allows package caching
and local package delivery services for groups of local servers from
Spacewalk Server. This service adds flexibility and economy of 
resources to package update and deployment.

This package includes module, which request is cache-able and should
be sent to Squid and which should be sent directly to parent Spacewalk
server.

%package redirect
Group:   Applications/Internet
Summary: The SSL Redirect component for the Spacewalk Proxy Server
Requires: spacewalk-proxy-broker = %{version}-%{release}
Requires: httpd
Obsoletes: rhns-proxy-redirect < 5.3.0

%description redirect
The Spacewalk Proxy Server allows package caching
and local package delivery services for groups of local servers from
Spacewalk Server. This service adds flexibility and economy of
resources to package update and deployment.

This package includes module, which handle request passed through squid
and assures a fully secure SSL connection is established and maintained 
between an Spacewalk Proxy Server and parent Spacewalk server.

%package common
Group:   Applications/Internet
Summary: Modules shared by Spacewalk Proxy components
Requires: mod_ssl
Requires: mod_wsgi
Requires: %{name}-broker >= %{version}
Requires: spacewalk-backend >= 1.7.24
Requires: policycoreutils
Obsoletes: rhns-proxy-common < 5.3.0

%description common
The Spacewalk Proxy Server allows package caching
and local package delivery services for groups of local servers from
Spacewalk Server. This service adds flexibility and economy of
resources to package update and deployment.

This package contains the files shared by various
Spacewalk Proxy components.

%package package-manager
Summary: Custom Channel Package Manager for the Spacewalk Proxy Server
Group:   Applications/Internet
Requires: spacewalk-backend >= 1.7.24
Requires: rhnlib >= 2.5.56
Requires: python
Requires: rhnpush
BuildRequires: /usr/bin/docbook2man
BuildRequires: python-devel
Obsoletes: rhn_package_manager < 5.3.0
Obsoletes: rhns-proxy-package-manager < 5.3.0

%description package-manager
The Spacewalk Proxy Server allows package caching
and local package delivery services for groups of local servers from
Spacewalk Server. This service adds flexibility and economy of
resources to package update and deployment.

This package contains the Command rhn_package_manager, which  manages 
an Spacewalk Proxy Server's custom channel.

%prep
%setup -q

%build
make -f Makefile.proxy

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.proxy install PREFIX=$RPM_BUILD_ROOT
install -d -m 750 $RPM_BUILD_ROOT/%{_var}/cache/rhn/proxy-auth
install -d -m 750 $RPM_BUILD_ROOT/%{_datadir}/spacewalk

mkdir -p $RPM_BUILD_ROOT/%{_var}/spool/rhn-proxy/list

touch $RPM_BUILD_ROOT/%{httpdconf}/cobbler-proxy.conf

%clean
rm -rf $RPM_BUILD_ROOT

%check
%if 0%{?fedora} > 15 || 0%{?rhel} > 5
# check coding style
export PYTHONPATH=$RPM_BUILD_ROOT/usr/share/rhn:$RPM_BUILD_ROOT%{python_sitelib}:/usr/share/rhn
spacewalk-pylint $RPM_BUILD_ROOT/usr/share/rhn
%endif

%post broker
if [ -f %{_sysconfdir}/sysconfig/rhn/systemid ]; then
    chown root.apache %{_sysconfdir}/sysconfig/rhn/systemid
    chmod 0640 %{_sysconfdir}/sysconfig/rhn/systemid
fi
/sbin/service httpd condrestart > /dev/null 2>&1

# In case of an upgrade, get the configured package list directory and clear it
# out.  Don't worry; it will be rebuilt by the proxy.

RHN_CONFIG_PY=%{rhnroot}/common/rhnConfig.py
RHN_PKG_DIR=%{_var}/spool/rhn-proxy

if [ -f $RHN_CONFIG_PY ] ; then

    # Check whether the config command supports the ability to retrieve a
    # config variable arbitrarily.  Versions of  < 4.0.6 (rhn) did not.

    python $RHN_CONFIG_PY proxy.broker > /dev/null 2>&1
    if [ $? -eq 1 ] ; then
        RHN_PKG_DIR=$(python $RHN_CONFIG_PY get proxy.broker pkg_dir)
    fi
fi

rm -rf $RHN_PKG_DIR/list/*

# Make sure the scriptlet returns with success
exit 0

%post redirect
/sbin/service httpd condrestart > /dev/null 2>&1
# Make sure the scriptlet returns with success
exit 0

%post management
# The spacewalk-proxy-management package is also our "upgrades" package.
# We deploy new conf from configuration channel if needed
# we deploy new conf only if we install from webui and conf channel exist
if rhncfg-client verify %{_sysconfdir}/rhn/rhn.conf 2>&1|grep 'Not found'; then
     %{_bindir}/rhncfg-client get %{_sysconfdir}/rhn/rhn.conf
fi > /dev/null 2>&1
if rhncfg-client verify %{_sysconfdir}/squid/squid.conf | grep -E '(modified|missing)'; then
    rhncfg-client get %{_sysconfdir}/squid/squid.conf 
    rm -rf %{_var}/spool/squid/*
    %{_usr}/sbin/squid -z
    /sbin/service squid condrestart
fi > /dev/null 2>&1

exit 0

%preun broker
if [ $1 -eq 0 ] ; then
    # nuke the cache
    rm -rf %{_var}/cache/rhn/*
fi

%preun
if [ $1 = 0 ] ; then
    /sbin/service httpd condrestart >/dev/null 2>&1
fi

%posttrans common
if [ -n "$1" ] ; then # anything but uninstall
    mkdir /var/cache/rhn/proxy-auth 2>/dev/null
    chown apache:root /var/cache/rhn/proxy-auth
    restorecon /var/cache/rhn/proxy-auth
fi


%files broker
%dir %{destdir}
%{destdir}/broker/__init__.py*
%{destdir}/broker/rhnBroker.py*
%{destdir}/broker/rhnRepository.py*
%attr(750,apache,apache) %dir %{_var}/spool/rhn-proxy
%attr(750,apache,apache) %dir %{_var}/spool/rhn-proxy/list
%attr(770,root,apache) %dir %{_var}/log/rhn
%config(noreplace) %{_sysconfdir}/logrotate.d/rhn-proxy-broker
# config files
%attr(644,root,apache) %{_prefix}/share/rhn/config-defaults/rhn_proxy_broker.conf

%files redirect
%dir %{destdir}
%{destdir}/redirect/__init__.py*
%{destdir}/redirect/rhnRedirect.py*
%attr(770,root,apache) %dir %{_var}/log/rhn
%config(noreplace) %{_sysconfdir}/logrotate.d/rhn-proxy-redirect
# config files
%attr(644,root,apache) %{_prefix}/share/rhn/config-defaults/rhn_proxy_redirect.conf

%files common
%dir %{destdir}
%{destdir}/__init__.py*
%{destdir}/apacheServer.py*
%{destdir}/apacheHandler.py*
%{destdir}/rhnShared.py*
%{destdir}/rhnConstants.py*
%{destdir}/responseContext.py*
%{destdir}/rhnAuthCacheClient.py*
%{destdir}/rhnProxyAuth.py*
%{destdir}/rhnAuthProtocol.py*
%attr(750,apache,apache) %dir %{_var}/spool/rhn-proxy
%attr(750,apache,apache) %dir %{_var}/spool/rhn-proxy/list
%attr(770,root,apache) %dir %{_var}/log/rhn
%attr(755,root,apache) %dir %{_datadir}/spacewalk
# config files
%attr(755,root,apache) %dir %{rhnconf}
%attr(645,root,apache) %config %{rhnconf}/rhn.conf
%attr(644,root,apache) %{_prefix}/share/rhn/config-defaults/rhn_proxy.conf
%attr(644,root,apache) %config %{httpdconf}/spacewalk-proxy.conf
# this file is created by either cli or webui installer
%ghost %config %{httpdconf}/cobbler-proxy.conf
%attr(644,root,apache) %config %{httpdconf}/spacewalk-proxy-wsgi.conf
%{rhnroot}/wsgi/xmlrpc.py*
%{rhnroot}/wsgi/xmlrpc_redirect.py*
# the cache
%attr(750,apache,root) %dir %{_var}/cache/rhn
%attr(750,apache,root) %dir %{_var}/cache/rhn/proxy-auth

%files package-manager
# config files
%attr(644,root,apache) %{_prefix}/share/rhn/config-defaults/rhn_proxy_package_manager.conf
%{_bindir}/rhn_package_manager
%{rhnroot}/PackageManager/rhn_package_manager.py*
%{rhnroot}/PackageManager/__init__.py*
%{_mandir}/man8/rhn_package_manager.8.gz

%files management
# dirs
%dir %{destdir}
# start/stop script
%attr(755,root,root) %{_sbindir}/rhn-proxy
# mans
%{_mandir}/man8/rhn-proxy.8*


%changelog
* Thu Dec 19 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.13-1
- Fixed client registration via proxy

* Tue Oct 01 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.12-1
- fixed pylint deprecated-lambda warning

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.11-1
- removed trailing whitespaces

* Fri Aug 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.10-1
- fixed pylint error

* Fri Aug 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.9-1
- 1002007 - don't send empty data
- 1002007 - python 2.4 HTTPConnection can't read directly from object

* Fri Aug 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.8-1
- 1002007 - use mod_wsgi even on RHEL5

* Wed Aug 28 2013 Tomas Lestach <tlestach@redhat.com> 2.1.7-1
- 1001997 - let spacewalk-proxy-management require spacewalk-base-minimal-
  config

* Fri Aug 23 2013 Stephen Herr <sherr@redhat.com> 2.1.6-1
- 1000586 - fixing line lenth error

* Fri Aug 23 2013 Stephen Herr <sherr@redhat.com> 2.1.5-1
- 1000586 - pylint errors

* Fri Aug 23 2013 Stephen Herr <sherr@redhat.com> 2.1.4-1
- 1000586 - fix checkstyle errors

* Fri Aug 23 2013 Stephen Herr <sherr@redhat.com> 2.1.3-1
- 1000586 - /etc/hosts doesn't work with proxies

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.2-1
- typo fix

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in proxy dir
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- updating copyright years

* Tue Jun 25 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.7-1
- minor branding cleanup

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.6-1
- removed old CVS/SVN version ids
- branding fixes in man pages
- more branding cleanup

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- rebranding few more strings

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- rebranding RHN Proxy to Red Hat Proxy
- rebrading RHN Satellite to Red Hat Satellite

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.3-1
- misc branding clean up

* Fri May 03 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- Do not read response data into memory
- do not read data into memory which should be send to the server

* Tue Apr 02 2013 Stephen Herr <sherr@redhat.com> 1.10.1-1
- 947639 - make Proxy timeouts configurable
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.8-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Wed Feb 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.7-1
- fixed permission on /var/log/rhn

* Wed Feb 13 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.6-1
- fixing pylint warnings

* Mon Feb 11 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- cleanup old CVS files

* Mon Dec 17 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.4-1
- fixed pylint warnings

* Mon Dec 17 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.3-1
- fixed indentation

* Fri Dec 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.2-1
- 873541 - switch back to /XP handler if /APP is not available

* Fri Nov 02 2012 Stephen Herr <sherr@redhat.com> 1.9.1-1
- 872721 - keep the proxy from trying to auth as 127.0.0.1
- Bumping package versions for 1.9.

* Tue Oct 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.14-1
- _processFile() prototype has changed

* Tue Oct 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.13-1
- _processFile() from uploadLib is static

* Mon Oct 22 2012 Jan Pazdziora 1.8.12-1
- bump up proxy version to 5.5.0

* Tue Aug 21 2012 Stephen Herr <sherr@redhat.com> 1.8.11-1
- 848475 - separate proxy auth error hostname into separate header

* Thu Aug 16 2012 Stephen Herr <sherr@redhat.com> 1.8.10-1
- 848475 - Don't expect string to already be imported

* Wed Aug 15 2012 Stephen Herr <sherr@redhat.com> 1.8.9-1
- 848475 - multi-tiered proxies don't update auth tokens correctly

* Fri Jul 13 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.8-1
- fixed man page
- removed dead --no-cache option

* Fri Jun 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.7-1
- 829724 - fixed man page for rhn-package-manager
- removed unused /XP handler

* Thu Jun 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.6-1
- no more special uploadLib.py
- merged uploadLib.UploadClass into rhn_package_manager.UploadClass

* Thu Jun 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.5-1
- 829724 - use session based calls from rhnpush.uploadLib
- 829724 - modified checkSync() to use session based authentication
- 829724 - session based authentication needs --new-cache and --no-cache
- 829724 - use session based authentication
- 829724 - /XP handler defines small subset of /APP handler functions

* Mon Jun 11 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.4-1
- provide /usr/share/spacewalk in proxy
- %%defattr is not needed since rpm 4.4

* Wed Apr 18 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.3-1
- add pylint warning

* Wed Apr 18 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.2-1
- move pylint directive up
- ignore false pylint warning

* Tue Apr 17 2012 Jan Pazdziora 1.8.1-1
- 811990 - refresh proxy auth cache for hostname changes (shughes@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 1.7.12-1
- Update the copyright year info.

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.11-1
- we are now just GPL

* Wed Feb 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.10-1
- fixed pylint error during rpm check

* Wed Feb 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.9-1
- proxy now requires updated modules from the latest spacewalk-backend
- reused parseRPMName() from spacewalk-backend

* Mon Feb 20 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.8-1
- fixing  Undefined variable 'info'

* Mon Feb 20 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.7-1
- merged list() with parent class
- merged uploadHeaders() with parent class
- removed dead code
- the very same newest() is defined in parent class
- merging duplicated code

* Wed Feb 15 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.6-1
- skip check also on Fedora 15

* Wed Feb 15 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.5-1
- skip pylint checks on RHEL5
- pylint needs python modules from spacewalk-backend
- fixed pylint errors
- pylint check has been moved to spacewalk-pylint package

* Fri Feb 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.4-1
- check proxy for pylint errors in rpm build time
- fixed pylint errors/warnings
* Tue Feb 07 2012 Miroslav Suchý 1.7.3-1
- clean up code style

* Tue Feb 07 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.2-1
- removed unused import
- removed dead copy of get_header() from proxy

* Tue Feb 07 2012 Miroslav Suchý 1.7.1-1
- Fix proxy traceback after code cleanup
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Wed Oct 26 2011 Miroslav Suchý 1.6.5-1
- there is no rhn-proxy-debug for some time

* Mon Oct 17 2011 Miroslav Suchý 1.6.4-1
- 719659 - correctly handle getpeername() on IPv6

* Fri Sep 30 2011 Jan Pazdziora 1.6.3-1
- 621531 - move /etc/rhn/default to /usr/share/rhn/config-defaults (proxy).

* Thu Aug 11 2011 Miroslav Suchý 1.6.2-1
- do not mask original error by raise in execption

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.

* Tue Jul 19 2011 Jan Pazdziora 1.5.11-1
- Updating the copyright years.

* Wed Jul 13 2011 Miroslav Suchý 1.5.10-1
- 720837 - pass /ks handler through Broker

* Mon Jul 11 2011 Miroslav Suchý 1.5.9-1
- optparse is here since python 2.3 - remove optik (msuchy@redhat.com)
- code cleanup

* Fri Jun 17 2011 Miroslav Suchý 1.5.8-1
- 710433 - if we get data chunked, httplib of python will join them, so it is
  not correct to send chunked header when data may not be chunked

* Fri May 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.7-1
- merged backend/common/UserDictCase.py into rhnlib/rhn/UserDictCase.py

* Fri May 13 2011 Miroslav Suchý 1.5.6-1
- 695651 - in mod_wsgi the URI is full URI (incl. protocol, hostname...) and
  not just the part beyond / (msuchy@redhat.com)
- 695651 - headers_in under mod_wsgi is dict, which does not have add()
  (msuchy@redhat.com)
- do not call function twice, store it in variable (msuchy@redhat.com)
- 695651 - pass /ty-cksm handler through Broker (msuchy@redhat.com)

* Wed May 11 2011 Miroslav Suchý 1.5.5-1
- 695651 - is_virtual is not exposed in mod_wsgi (msuchy@redhat.com)
- 695651 - pass /ty handler through Broker (tlestach@redhat.com)
- 695651 - pass /download handler through Broker (msuchy@redhat.com)

* Tue May 10 2011 Jan Pazdziora 1.5.4-1
- 678053 - add option --no-session-caching to rhn_package_manager
  (msuchy@redhat.com)

* Wed May 04 2011 Miroslav Suchý 1.5.3-1
- do not import modules through magic

* Tue Apr 19 2011 Miroslav Suchý <msuchy@redhat.com> 1.5.2-1
- 697447 - handle all other request

* Mon Apr 18 2011 Miroslav Suchý 1.5.1-1
- 697447 - pass /rpc/* through broker
- Bumping package versions for 1.5

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.11-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- remove redundant comment (msuchy@redhat.com)
- convert comment to docstring (msuchy@redhat.com)
- remove redundant comment (msuchy@redhat.com)

* Thu Jan 13 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.10-1
- do not traceback if redirected location do not contain '?'
- fix module name during import
- replace tabs with space to fix indentation

* Tue Jan 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.9-1
- fixed pylint errors

* Tue Jan 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.8-1
- removed xxmlrpclib
- Updating the copyright years to include 2010.

* Mon Dec 13 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.7-1
- fixed number of errors reported by pylint

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.6-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Fri Dec 03 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.5-1
- 656746 - send to hosted md5 checksum of package (msuchy@redhat.com)
- 656746 - make _processFile and _processBatch method of UploadClass class
  (msuchy@redhat.com)
- 656753 - add namespace prefix to merged functions (msuchy@redhat.com)
- 656753 - fix TB during rhn_package_manager -v -l (msuchy@redhat.com)
- 658527 - create _split_url function (msuchy@redhat.com)
- use constant instead of hardcoded string (msuchy@redhat.com)
- import Fault from different class (msuchy@redhat.com)

* Tue Nov 30 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.4-1
- 658303 - do not forward Host header, it will confuse target Satellite

* Mon Nov 29 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.3-1
- 657956 - fix condrestart option (msuchy@redhat.com)

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- removed unused imports

* Sat Nov 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- 629552 - Proxy should allow all header from rfc2616 (msuchy@redhat.com)
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Wed Nov 10 2010 Jan Pazdziora 1.2.15-1
- addressing rpmlint error non-standard-dir-perm (msuchy@redhat.com)
- fix spelling error (msuchy@redhat.com)
- update Makefile to reflect logrotate files rename (msuchy@redhat.com)
- rename logrotate/rhn_proxy_redirect to logrotate/rhn-proxy-redirect
  (msuchy@redhat.com)
- rename logrotate/rhn_proxy_broker to logrotate/rhn-proxy-broker
  (msuchy@redhat.com)
- mark logrotate.d files as %config(noreplace) (msuchy@redhat.com)
- correct description (msuchy@redhat.com)
- bumping up epoch in provides - do not self-obsolete (msuchy@redhat.com)
- escape entry in changelog (msuchy@redhat.com)

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.14-1
- 514253 - file cobbler-proxy.conf should have owner, winner is spacewalk-
  proxy-common (msuchy@redhat.com)

* Wed Nov 03 2010 Jan Pazdziora 1.2.13-1
- remove RootDir (msuchy@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 1.2.12-1
- Update copyright years in the rest of the repo.

* Fri Oct 29 2010 Jan Pazdziora 1.2.11-1
- removed unused class rhnPackageManagerException (michael.mraka@redhat.com)

* Thu Oct 21 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.10-1
- 612581 - spacewalk-backend modules has been migrated to spacewalk namespace

* Thu Oct 21 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.9-1
- 641371 - do not read response body if request is HEAD

* Mon Oct 18 2010 Jan Pazdziora 1.2.8-1
- code cleanup - it does not have sense to require itself (msuchy@redhat.com)
- require policycoreutils due usage of restorecon (msuchy@redhat.com)

* Wed Oct 13 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.7-1
- 640195 - do not produce warning if directory already exist
  (msuchy@redhat.com)

* Wed Oct 13 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.6-1
- fix typo in macro (msuchy@redhat.com)

* Wed Oct 13 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.5-1
- 640195 - put upgrade script to %%posttrans (msuchy@redhat.com)

* Wed Oct 13 2010 Jan Pazdziora 1.2.4-1
- bump up version of proxy (msuchy@redhat.com)

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.3-1
- replaced local copy of compile.py with standard compileall module

* Wed Sep 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.2-1
- 629330 - do not remove /var/cache/rhn/* during upgrade
- 629330 - do not remove /var/spool/rhn-proxy/list itself, only its content

* Tue Aug 31 2010 Justin Sherrill <jsherril@redhat.com> 1.2.1-1
- 629102 - Adding range to the allowed header list for proxy
  (jsherril@redhat.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.3-1
- oracle client has been removed from /opt/oracle ages ago

* Tue Jun 29 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- 609040 - if we request checksum of file, do not sent Range http header

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- merge 2 duplicate byterange module to common.byterange
- bumping spec files to 1.1 packages
- 578854 - read response even if HEADER_CONTENT_LENGTH is not present

