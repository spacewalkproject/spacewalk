%if 0%{?fedora} || 0%{?rhel} >= 7
%{!?pylint_check: %global pylint_check 1}
%endif

Name: spacewalk-proxy
Summary: Spacewalk Proxy Server
Version: 2.9.0
Release: 1%{?dist}
License: GPLv2
URL:     https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildRequires: python
BuildArch: noarch
Requires: httpd
%if 0%{?pylint_check}
BuildRequires: spacewalk-python2-pylint
%endif
BuildRequires: rhnpush >= 5.5.74
# proxy isn't Python 3 yet
BuildRequires: python2-rhnpush
BuildRequires: spacewalk-backend-libs >= 1.7.24
BuildRequires: spacewalk-backend >= 1.7.24

%define rhnroot %{_usr}/share/rhn
%define destdir %{rhnroot}/proxy
%define rhnconf %{_sysconfdir}/rhn
%if 0%{?suse_version}
%define httpdconf %{_sysconfdir}/apache2/conf.d
%define apache_user wwwrun
%define apache_group www
%else
%define httpdconf %{_sysconfdir}/httpd/conf.d
%define apache_user apache
%define apache_group apache
%endif

%description
This package is never built.

%package management
Summary: Packages required by the SpacewalkManagement Proxy
Requires: squid
Requires: spacewalk-backend >= 1.7.24
Requires: %{name}-broker = %{version}
Requires: %{name}-redirect = %{version}
Requires: %{name}-common >= %{version}
Requires: %{name}-docs
Requires: %{name}-html
Requires: jabberd spacewalk-setup-jabberd
Requires: httpd
%if 0%{?fedora} || 0%{?rhel}
Requires: spacewalk-proxy-selinux
Requires: sos
Requires(preun): initscripts
%endif
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
Summary: The Broker component for the Spacewalk Proxy Server
Requires: squid
Requires: spacewalk-certs-tools
Requires: spacewalk-proxy-package-manager
Requires: spacewalk-ssl-cert-check
Requires: httpd
%if 0%{?fedora} || 0%{?rhel}
Requires: mod_ssl
%endif
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
Summary: Modules shared by Spacewalk Proxy components
%if 0%{?suse_version}
BuildRequires: apache2
%else
Requires: mod_ssl
%endif
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
Requires: spacewalk-backend >= 1.7.24
Requires: rhnlib >= 2.5.56
Requires: python
Requires: rhnpush >= 5.5.74
# proxy isn't Python 3 yet
Requires: python2-rhnpush
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
an Spacewalk Proxy Server\'s custom channel.

%prep
%setup -q

%build
make -f Makefile.proxy

%install
make -f Makefile.proxy install PREFIX=$RPM_BUILD_ROOT
install -d -m 750 $RPM_BUILD_ROOT/%{_var}/cache/rhn/proxy-auth
install -d -m 750 $RPM_BUILD_ROOT/%{_datadir}/spacewalk

mkdir -p $RPM_BUILD_ROOT/%{_var}/spool/rhn-proxy/list

%if 0%{?suse_version}
mkdir -p $RPM_BUILD_ROOT/etc/apache2
mv $RPM_BUILD_ROOT/etc/httpd/conf.d $RPM_BUILD_ROOT/%{httpdconf}
rm -rf $RPM_BUILD_ROOT/etc/httpd
%endif
touch $RPM_BUILD_ROOT/%{httpdconf}/cobbler-proxy.conf

%clean

%check
%if 0%{?pylint_check}
# check coding style
export PYTHONPATH=$RPM_BUILD_ROOT/usr/share/rhn:$RPM_BUILD_ROOT%{python_sitelib}:/usr/share/rhn
spacewalk-python2-pylint $RPM_BUILD_ROOT/usr/share/rhn
%endif

%post broker
if [ -f %{_sysconfdir}/sysconfig/rhn/systemid ]; then
    chown root.%{apache_group} %{_sysconfdir}/sysconfig/rhn/systemid
    chmod 0640 %{_sysconfdir}/sysconfig/rhn/systemid
fi
%if 0%{?suse_version}
/sbin/service apache2 try-restart > /dev/null 2>&1 ||:
%else
/sbin/service httpd condrestart > /dev/null 2>&1
%endif

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
%if 0%{?suse_version}
/sbin/service apache2 try-restart > /dev/null 2>&1 ||:
%else
/sbin/service httpd condrestart > /dev/null 2>&1
%endif
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
%if 0%{?suse_version}
    /sbin/service apache2 try-restart > /dev/null 2>&1 ||:
%else
    /sbin/service httpd condrestart >/dev/null 2>&1
%endif
fi

%if 0%{?suse_version}
%post common
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES wsgi
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES access_compat
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES proxy
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES rewrite
sysconf_addword /etc/sysconfig/apache2 APACHE_SERVER_FLAGS SSL
%endif

%posttrans common
if [ -n "$1" ] ; then # anything but uninstall
    mkdir /var/cache/rhn/proxy-auth 2>/dev/null
    chown %{apache_user}:root /var/cache/rhn/proxy-auth
    restorecon /var/cache/rhn/proxy-auth
fi


%files broker
%dir %{destdir}
%{destdir}/broker/__init__.py*
%{destdir}/broker/rhnBroker.py*
%{destdir}/broker/rhnRepository.py*
%attr(750,%{apache_user},%{apache_group}) %dir %{_var}/spool/rhn-proxy
%attr(750,%{apache_user},%{apache_group}) %dir %{_var}/spool/rhn-proxy/list
%attr(770,root,%{apache_group}) %dir %{_var}/log/rhn
%config(noreplace) %{_sysconfdir}/logrotate.d/rhn-proxy-broker
# config files
%attr(644,root,%{apache_group}) %{_prefix}/share/rhn/config-defaults/rhn_proxy_broker.conf
%if 0%{?suse_version}
%dir %{destdir}/broker
%endif

%files redirect
%dir %{destdir}
%{destdir}/redirect/__init__.py*
%{destdir}/redirect/rhnRedirect.py*
%attr(770,root,%{apache_group}) %dir %{_var}/log/rhn
%config(noreplace) %{_sysconfdir}/logrotate.d/rhn-proxy-redirect
# config files
%attr(644,root,%{apache_group}) %{_prefix}/share/rhn/config-defaults/rhn_proxy_redirect.conf
%if 0%{?suse_version}
%dir %{destdir}/redirect
%endif

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
%attr(750,%{apache_user},%{apache_group}) %dir %{_var}/spool/rhn-proxy
%attr(750,%{apache_user},%{apache_group}) %dir %{_var}/spool/rhn-proxy/list
%attr(770,root,%{apache_group}) %dir %{_var}/log/rhn
%attr(755,root,%{apache_group}) %dir %{_datadir}/spacewalk
# config files
%attr(755,root,%{apache_group}) %dir %{rhnconf}
%attr(645,root,%{apache_group}) %config %{rhnconf}/rhn.conf
%attr(644,root,%{apache_group}) %{_prefix}/share/rhn/config-defaults/rhn_proxy.conf
%attr(644,root,%{apache_group}) %config %{httpdconf}/spacewalk-proxy.conf
# this file is created by either cli or webui installer
%ghost %config %{httpdconf}/cobbler-proxy.conf
%attr(644,root,%{apache_group}) %config %{httpdconf}/spacewalk-proxy-wsgi.conf
%{rhnroot}/wsgi/xmlrpc.py*
%{rhnroot}/wsgi/xmlrpc_redirect.py*
# the cache
%attr(750,%{apache_user},root) %dir %{_var}/cache/rhn
%attr(750,%{apache_user},root) %dir %{_var}/cache/rhn/proxy-auth
%if 0%{?suse_version}
%dir %{rhnroot}
%dir %{rhnroot}/wsgi
%attr(755,root,%{apache_group}) %dir %{rhnroot}/config-defaults
%endif

%files package-manager
# config files
%attr(644,root,%{apache_group}) %{_prefix}/share/rhn/config-defaults/rhn_proxy_package_manager.conf
%{_bindir}/rhn_package_manager
%{rhnroot}/PackageManager/rhn_package_manager.py*
%{rhnroot}/PackageManager/__init__.py*
%{_mandir}/man8/rhn_package_manager.8.gz
%if 0%{?suse_version}
%dir %{rhnroot}/PackageManager
%endif

%files management
# dirs
%dir %{destdir}
# start/stop script
%attr(755,root,root) %{_sbindir}/rhn-proxy
# mans
%{_mandir}/man8/rhn-proxy.8*


%changelog
* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 2.8.5-1
- run pylint on rhel 7 builds

* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 2.8.4-1
- Update to use newly separated spacewalk-python[2|3]-pylint packages

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.3-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Nov 13 2017 Jan Dobes 2.8.2-1
- proxy isn't Python 3 yet, still require Python 2 rhnpush
- removing useless condition

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- use standard brp-python-bytecompile
- Bumping package versions for 2.8.

* Mon Aug 07 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.7-1
- python-hashlib is included in python-libs since RHEL 6

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.6-1
- update copyright year

* Wed Jul 19 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.5-1
- ignore unknown pylint checks

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.4-1
- disable pylint warnings
- fixed pylint warnings

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.3-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 2.7.2-1
- add some small pep8 fixes for proxy code

* Thu Mar 16 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.1-1
- wrong-import-position is not present in pylint on Fedora 23
- pylint fixes - proxy
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- Bumping package versions for 2.7.

* Tue Sep 20 2016 Jan Dobes 2.6.2-1
- header can be changed here, this method was added for pylint anyway

* Tue Sep 20 2016 Gennadii Altukhov <galt@redhat.com> 2.6.1-1
- proxy 'ValueError: Invalid header value' fixing
- proxy - fix build on Fedora 24
- Bumping package versions for 2.6.

* Fri May 20 2016 Grant Gainey 2.5.2-1
- spacewalk-proxy: build on openSUSE

* Fri Nov 27 2015 Jan Dobes 2.5.1-1
- removing old dependency
- Bumping package versions for 2.5.

* Wed May 27 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.3-1
- fix pylint warning on Fedora 22

* Wed May 13 2015 Stephen Herr <sherr@redhat.com> 2.4.2-1
- Break up long line to make pylint happy

* Mon May 11 2015 Stephen Herr <sherr@redhat.com> 2.4.1-1
- 1220399 - make proxy able to understand (bad) requests from ubuntu clients
- Bumping package versions for 2.4.

* Fri Mar 27 2015 Stephen Herr <sherr@redhat.com> 2.3.23-1
- 1206350 - another checkstyl fix :(

* Fri Mar 27 2015 Stephen Herr <sherr@redhat.com> 2.3.22-1
- 1206350 - make checkstyle happy

* Fri Mar 27 2015 Stephen Herr <sherr@redhat.com> 2.3.21-1
- 1206350 - Proxy needs to correctly pass around -Auth-Error headers on SSL GET
  requests
- 1206350 - teach Proxy to auth up to Satellite if it doesn't recognize client
  token

* Mon Mar 23 2015 Grant Gainey 2.3.20-1
- Standardize pylint-check to only happen on Fedora

* Thu Mar 19 2015 Grant Gainey 2.3.19-1
- Updating copyright info for 2015

* Wed Mar 18 2015 Stephen Herr <sherr@redhat.com> 2.3.18-1
- 1194056 - pylint is barfing over perfectly valid pep-8 compliant code. Oh
  well.

* Wed Mar 18 2015 Stephen Herr <sherr@redhat.com> 2.3.17-1
- 1194056 - Fedora pylint is even pickier, space change

* Tue Mar 17 2015 Stephen Herr <sherr@redhat.com> 2.3.16-1
- 1194056 - IOException is not a thing :(

* Tue Mar 17 2015 Stephen Herr <sherr@redhat.com> 2.3.15-1
- 1194056 - another checkstyle fix

* Tue Mar 17 2015 Stephen Herr <sherr@redhat.com> 2.3.14-1
- 1201380 - make checkstyle happy

* Mon Mar 16 2015 Stephen Herr <sherr@redhat.com> 2.3.13-1
- 1188868 - wsgi.input is only guaranteed to be readable once. We read it twice
- 1194056 - make checkstyle happy

* Mon Mar 09 2015 Stephen Herr <sherr@redhat.com> 2.3.12-1
- 1194056 - Proxy should recover from corrupt cached channel lists

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.11-1
- drop monitoring from proxy setup

* Wed Feb 04 2015 Stephen Herr <sherr@redhat.com> 2.3.10-1
- 1189184 - prevent squid 3.2 from detecting forwarding loops

* Fri Jan 23 2015 Stephen Herr <sherr@redhat.com> 2.3.9-1
- Leave condrestart command in rhn-proxy script for backwards-compatibility
- spacewalk-proxy: do not use subsys anymore does not exist on all systems
- spacewalk-proxy: make rhn-proxy systemd aware

* Fri Jan 23 2015 Matej Kollar <mkollar@redhat.com> 2.3.8-1
- Fix Pylint on Fedora 21: manual fixes
- Autopep8

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.7-1
- Fix 403 errors for proxy wsgi requests

* Thu Dec 11 2014 Stephen Herr <sherr@redhat.com> 2.3.6-1
- 1172738 - checkstyle fix

* Thu Dec 11 2014 Stephen Herr <sherr@redhat.com> 2.3.5-1
- 1172738 - empty base channels incompatible with pre-cache, fall back to
  Spacewalk

* Fri Nov 21 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- 1166045 - read systemid path from configuration

* Tue Nov 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.3-1
- 1158155 - fixed renaming of deb packages

* Thu Oct 30 2014 Stephen Herr <sherr@redhat.com> 2.3.2-1
- 1158644 - prevent infinite redirect if using spacewalk webui through proxy

* Tue Oct 28 2014 Stephen Herr <sherr@redhat.com> 2.3.1-1
- 1158193 - configure proxy max memory file size separately from buffer_size
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.10-1
- fix copyright years

* Mon Jun 23 2014 Stephen Herr <sherr@redhat.com> 2.2.9-1
- 1108370 - checkstyle fix

* Mon Jun 23 2014 Stephen Herr <sherr@redhat.com> 2.2.8-1
- 1108370 - add more user-friendly caching option to package_manager

* Fri Jun 20 2014 Stephen Herr <sherr@redhat.com> 2.2.7-1
- 1108370 - checkstyle fix and error handling

* Fri Jun 20 2014 Stephen Herr <sherr@redhat.com> 2.2.6-1
- 1108370 - enable proxy to serve files from its cache for kickstarts
- 1108370 - enable proxy to correctly respond to partial http requests

* Wed Jun 11 2014 Stephen Herr <sherr@redhat.com> 2.2.5-1
- 1108370 - add --from-export option to rhn_package_manager
- make rhnpush backwards-compatible with old spacewalk-proxy

* Sat Jun 07 2014 Stephen Herr <sherr@redhat.com> 2.2.4-1
- 1104375 - checkstyle fixes

* Fri Jun 06 2014 Stephen Herr <sherr@redhat.com> 2.2.3-1
- 1104375 - add default path structure to proxy lookaside that avoids
  collisions
- 1105273 - rhn_package_manager should not force md5; use package hearders

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- spec file polish

* Fri Mar 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- Proxy should not make bogus fqdn:port DNS queries

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.15-1
- Updating the copyright years info

* Wed Jan 08 2014 Stephen Herr <sherr@redhat.com> 2.1.14-1
- Fixing typo in 70e86d8d47

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

