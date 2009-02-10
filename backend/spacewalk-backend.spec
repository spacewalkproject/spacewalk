%define rhnroot %{_prefix}/share/rhn
%define rhnconf %{_sysconfdir}/rhn
%define httpdconf %{rhnconf}/satellite-httpd/conf
%define apacheconfd %{_sysconfdir}/httpd/conf.d

Name: spacewalk-backend
Summary: Common programs needed to be installed on the Spacewalk servers/proxies
Group: Applications/Internet
License: GPLv2
Version: 0.5.4
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: python, rpm-python
Requires: rhnlib >= 1.8
BuildRequires: /usr/bin/msgfmt
BuildRequires: /usr/bin/docbook2man
BuildRequires: docbook-utils
Requires(pre): httpd
# we don't really want to require this redhat-release, so we protect
# against installations on other releases using conflicts...
Obsoletes: rhns-common < 5.3.0
Obsoletes: rhns < 5.3.0

%description 
Generic program files needed by the Spacewalk server machines.
This package includes the common code required by all servers/proxies.

%package sql
Summary: Core functions providing SQL connectivity for the RHN backend modules
Group: Applications/Internet
Requires(pre): %{name} = %{version}-%{release}
Requires: python(:DBAPI:oracle)
Obsoletes: rhns-sql < 5.3.0

%description sql
This package contains the basic code that provides SQL connectivity for the Spacewalk
backend modules.

%package server
Summary: Basic code that provides RHN Server functionality
Group: Applications/Internet
Requires(pre): %{name}-sql = %{version}-%{release}
Requires: mod_python
Obsoletes: rhns-server < 5.3.0

%description server
This package contains the basic code that provides server/backend
functionality for a variety of XML-RPC receivers. The architecture is
modular so that you can plug/install additional mdoules for XML-RPC
receivers and get them enabled automatically.

%package xmlrpc
Summary: Handler for /XMLRPC
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-xmlrpc < 5.3.0
Obsoletes: rhns-xmlrpc < 5.3.0

%description xmlrpc
These are the files required for running the /XMLRPC handler, which
provide the basic support for the registration client (rhn_register)
and the up2date clients.

%package applet
Summary: Handler for /APPLET
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-applet < 5.3.0

%description applet
These are the files required for running the /APPLET handler, which
provides the functions for the RHN applet.

%package app
Summary: Handler for /APP
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-app < 5.3.0
Obsoletes: rhns-app < 5.3.0

%description app
These are the files required for running the /APP handler.
Calls to /APP are used by internal maintenance tools (rhnpush).

%package xp
Summary: Handler for /XP
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-xp < 5.3.0
Obsoletes: rhns-xp < 5.3.0

%description xp
These are the files required for running the /XP handler.
Calls to /XP are used by tools publicly available (like rhn_package_manager).

%package iss
Summary: Handler for /SAT
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-sat < 5.3.0

%description iss
%{name} contains the basic code that provides server/backend
functionality for a variety of XML-RPC receivers. The architecture is
modular so that you can plug/install additional mdoules for XML-RPC
receivers and get them enabled automatically.

This package contains /SAT handler, which provide Inter Spacewalk Sync 
capability.

%package iss-export
Summary: Listener for the Server XML dumper
Group: Applications/Internet
Requires: rpm-python
Requires: %{name}-xml-export-libs = %{version}-%{release}

%description iss-export
%{name} contains the basic code that provides server/backend
functionality for a variety of XML-RPC receivers. The architecture is
modular so that you can plug/install additional mdoules for XML-RPC
receivers and get them enabled automatically.

This package contains listener for the Server XML dumper.

%package config-files-common
Summary: Common files for the Configuration Management project
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-config-files-common < 5.3.0

%description config-files-common
Common files required by the Configuration Management project

%package config-files
Summary: Handler for /CONFIG-MANAGEMENT
Group: Applications/Internet
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files < 5.3.0

%description config-files
This package contains the server-side code for configuration management.

%package config-files-tool
Summary: Handler for /CONFIG-MANAGEMENT-TOOL
Group: Applications/Internet
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files-tool < 5.3.0

%description config-files-tool
This package contains the server-side code for configuration management tool.

%package upload-server
Summary: Server-side listener for rhn-pkgupload
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-upload-server < 5.3.0

%description upload-server
Server-side listener for rhn-pkgupload

%package package-push-server
Summary: Listener for rhnpush (non-XMLRPC version)
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-package-push-server < 5.3.0

%description package-push-server
Listener for rhnpush (non-XMLRPC version)

%package tools
Summary: Red Hat Network Services Satellite Tools
Group: Applications/Internet
Requires: %{name}-xmlrpc = %{version}-%{release}
Requires: %{name}-app = %{version}-%{release}
Requires: spacewalk-certs-tools
Requires: spacewalk-admin >= 0.1.1-0
Requires: python-gzipstream
Requires: PyXML
Requires: mod_ssl
Requires: %{name}-xml-export-libs
Requires: cobbler >= 0:1.4
Obsoletes: rhns-satellite-tools < 5.3.0
Obsoletes: spacewalk-backend-satellite-tools <= 0.2.7

%description tools
Various utilities for the Red Hat Network Satellite Server.

%package xml-export-libs
Summary: Red Hat Network XML data exporter
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
%if "%{pythongen}" == "1.5"
Requires: python-iconv
%endif
Obsoletes: rhns-xml-export-libs < 5.3.0

%description xml-export-libs
Libraries required by various exporting tools
XXX To be determined if the proper location is under backend

%prep
%setup -q

%build
make -f Makefile.backend all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make -f Makefile.backend install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}

%clean
rm -rf $RPM_BUILD_ROOT

%pre server
OLD_SECRET_FILE=%{_var}/www/rhns/server/secret/rhnSecret.py
if [ -f $OLD_SECRET_FILE ]; then
    install -d -m 750 -o root -g apache %{rhnconf}
    mv ${OLD_SECRET_FILE}*  %{rhnconf}
fi

%post server
# Is secret key in our config file?
regex="^[[:space:]]*(server\.|)secret_key[[:space:]]*=.*$"

if egrep -i $regex %{rhnconf}/rhn.conf > /dev/null 2>&1 ; then
    # secret key already there
    rm -f %{rhnconf}/rhnSecret.py*
    exit 0
fi
    
# Generate a secret key if old one is not present
if [ -f %{rhnconf}/rhnSecret.py ]; then
    secret_key=$(PYTHONPATH=%{rhnconf} python -c \
        "from rhnSecret import SECRET_KEY; print SECRET_KEY")
else
    secret_key=$(dd if=/dev/urandom bs=1024 count=1 2>/dev/null | sha1sum - | 
        awk '{print $1}')
fi

echo "server.secret_key = $secret_key" >> %{rhnconf}/rhn.conf
rm -f %{rhnconf}/rhnSecret.py*

%files
%defattr(-,root,root)
%dir %{rhnroot}
%dir %{rhnroot}/common
%{rhnroot}/common/__init__.py*
%{rhnroot}/common/rhn_fcntl.py*
%{rhnroot}/common/rhn_mpm.py*
%{rhnroot}/common/rhn_posix.py*
%{rhnroot}/common/rhn_rpm.py*
%{rhnroot}/common/rhn_timer.py*
%{rhnroot}/common/rhnApache.py*
%{rhnroot}/common/rhnCache.py*
%{rhnroot}/common/rhnConfig.py*
%{rhnroot}/common/rhnException.py*
%{rhnroot}/common/rhnFlags.py*
%{rhnroot}/common/rhnLib.py*
%{rhnroot}/common/rhnLockfile.py*
%{rhnroot}/common/rhnLog.py*
%{rhnroot}/common/rhnMail.py*
%{rhnroot}/common/rhnTB.py*
%{rhnroot}/common/rhnRepository.py*
%{rhnroot}/common/rhnTranslate.py*
%{rhnroot}/common/UserDictCase.py*
%{rhnroot}/common/RPC_Base.py*
%attr(770,root,apache) %dir %{_var}/log/rhn
# config files
%attr(750,root,apache) %dir %{rhnconf}
%attr(750,root,apache) %dir %{rhnconf}/default
%attr(640,root,apache) %{rhnconf}/default/rhn.conf

%files sql
%defattr(-,root,root)
# Need __init__ = share it with rhns-server
%dir %{rhnroot}/server
%{rhnroot}/server/__init__.py*
%dir %{rhnroot}/server/rhnSQL
%{rhnroot}/server/rhnSQL/*

%files server
%defattr(-,root,root)
# modules
%{rhnroot}/server/apacheAuth.py*
%{rhnroot}/server/apacheHandler.py*
%{rhnroot}/server/apacheRequest.py*
%{rhnroot}/server/apacheServer.py*
%{rhnroot}/server/apacheUploadServer.py*
%{rhnroot}/server/byterange.py*
%{rhnroot}/server/rhnAction.py*
%{rhnroot}/server/rhnAuthPAM.py*
%{rhnroot}/server/rhnCapability.py*
%{rhnroot}/server/rhnChannel.py*
%{rhnroot}/server/rhnKickstart.py*
%{rhnroot}/server/rhnDatabaseCache.py*
%{rhnroot}/server/rhnDependency.py*
%{rhnroot}/server/rhnItem.py*
%{rhnroot}/server/rhnPackage.py*
%{rhnroot}/server/rhnPackageUpload.py*
%{rhnroot}/server/rhnHandler.py*
%{rhnroot}/server/rhnImport.py*
%{rhnroot}/server/rhnLib.py*
%{rhnroot}/server/rhnMapping.py*
%{rhnroot}/server/rhnRepository.py*
%{rhnroot}/server/rhnSession.py*
%{rhnroot}/server/rhnUser.py*
%{rhnroot}/server/rhnVirtualization.py*
%dir %{rhnroot}/server/rhnServer
%{rhnroot}/server/rhnServer/*
%dir %{rhnroot}/server/importlib
%{rhnroot}/server/importlib/__init__.py*
%{rhnroot}/server/importlib/archImport.py*
%{rhnroot}/server/importlib/backend.py*
%{rhnroot}/server/importlib/backendLib.py*
%{rhnroot}/server/importlib/backendOracle.py*
%{rhnroot}/server/importlib/blacklistImport.py*
%{rhnroot}/server/importlib/channelImport.py*
%{rhnroot}/server/importlib/errataCache.py*
%{rhnroot}/server/importlib/errataImport.py*
%{rhnroot}/server/importlib/headerSource.py*
%{rhnroot}/server/importlib/importLib.py*
%{rhnroot}/server/importlib/kickstartImport.py*
%{rhnroot}/server/importlib/mpmSource.py*
%{rhnroot}/server/importlib/packageImport.py*
%{rhnroot}/server/importlib/packageUpload.py*
%{rhnroot}/server/importlib/productNamesImport.py*
%{rhnroot}/server/importlib/userAuth.py*
%{rhnroot}/server/handlers/__init__.py*

# Repomd stuff
%dir %{rhnroot}/server/repomd
%{rhnroot}/server/repomd/__init__.py*
%{rhnroot}/server/repomd/domain.py*
%{rhnroot}/server/repomd/mapper.py*
%{rhnroot}/server/repomd/repository.py*
%{rhnroot}/server/repomd/view.py*

# the cache
%attr(750,apache,root) %dir %{_var}/cache/rhn
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server.conf
# main httpd config
%attr(640,root,apache) %config %{apacheconfd}/zz-spacewalk-server.conf
# logs and other stuff
%config %{_sysconfdir}/logrotate.d/rhn_server
# translations
%{rhnroot}/locale

%files xmlrpc
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/xmlrpc
%{rhnroot}/server/handlers/xmlrpc/*
%dir %{rhnroot}/server/action
%{rhnroot}/server/action/*
%dir %{rhnroot}/server/action_extra_data
%{rhnroot}/server/action_extra_data/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_xmlrpc.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/xmlrpc.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_xmlrpc

%files applet
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/applet
%{rhnroot}/server/handlers/applet/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_applet.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/applet.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_applet

%files app
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/app
%{rhnroot}/server/handlers/app/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_app.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/app.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_app

%files xp
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/xp
%{rhnroot}/server/handlers/xp/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_xp.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/xp.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_xp

%files iss
%defattr(-,root,root)
%dir %{rhnroot}/server/handlers/sat
%{rhnroot}/server/handlers/sat/*
%config %{_sysconfdir}/logrotate.d/rhn_server_sat
%attr(640,root,apache) %config %{httpdconf}/rhn/sat.conf

%files iss-export
%defattr(-,root,root)

%dir %{rhnroot}/satellite_exporter
%{rhnroot}/satellite_exporter/__init__.py*
%{rhnroot}/satellite_exporter/satexport.py*
%{rhnroot}/satellite_exporter/constants.py*

%dir %{rhnroot}/satellite_exporter/exporter
%{rhnroot}/satellite_exporter/exporter/__init__.py*
%{rhnroot}/satellite_exporter/exporter/dumper.py*
%{rhnroot}/satellite_exporter/exporter/string_buffer.py*
%{rhnroot}/satellite_exporter/exporter/exportLib.py*
%{rhnroot}/satellite_exporter/exporter/xmlWriter.py*

%dir %{rhnroot}/satellite_exporter/handlers
%{rhnroot}/satellite_exporter/handlers/__init__.py*
%{rhnroot}/satellite_exporter/handlers/non_auth_dumper.py*
# config files
%attr(640,root,apache) %config %{httpdconf}/rhn/sat-export-internal.conf
%config %{_sysconfdir}/logrotate.d/rhn_sat_export_internal
%attr(640,root,apache) %{rhnconf}/default/rhn_server_satexport.conf
%attr(640,root,apache) %{rhnconf}/default/rhn_server_satexport_internal.conf


%files config-files-common
%defattr(-,root,root)
%{rhnroot}/server/configFilesHandler.py*
%dir %{rhnroot}/server/config_common
%{rhnroot}/server/config_common/*

%files config-files
%defattr(-,root,root)
%dir %{rhnroot}/server/handlers/config
%{rhnroot}/server/handlers/config/*
%attr(640,root,apache) %{rhnconf}/default/rhn_server_config-management.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/config-management.conf
%config %{_sysconfdir}/logrotate.d/rhn_config_management

%files config-files-tool
%defattr(-,root,root)
%dir %{rhnroot}/server/handlers/config_mgmt
%{rhnroot}/server/handlers/config_mgmt/*
%attr(640,root,apache) %{rhnconf}/default/rhn_server_config-management-tool.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/config-management-tool.conf
%config %{_sysconfdir}/logrotate.d/rhn_config_management_tool

%files upload-server
%defattr(-,root,root)
# Some directories and files are shared with rhns-package-push-server
%dir %{rhnroot}/upload_server
%{rhnroot}/upload_server/__init__.py*
%dir %{rhnroot}/upload_server/handlers
%{rhnroot}/upload_server/handlers/__init__.py*
%{rhnroot}/upload_server/handlers/package
%attr(640,root,apache) %{rhnconf}/default/rhn_server_upload.conf
%attr(640,root,apache) %{rhnconf}/default/rhn_server_upload_package.conf
%config %{_sysconfdir}/logrotate.d/rhn_package_upload
%attr(640,root,apache) %config %{httpdconf}/rhn/pkg-upload.conf

%files package-push-server
%defattr(-,root,root)
# Some directories and files are shared with rhns-upload-server
%dir %{rhnroot}/upload_server
%{rhnroot}/upload_server/__init__.py*
%dir %{rhnroot}/upload_server/handlers
%{rhnroot}/upload_server/handlers/__init__.py*
%{rhnroot}/upload_server/handlers/package_push
%attr(640,root,apache) %{rhnconf}/default/rhn_server_upload.conf
%attr(640,root,apache) %{rhnconf}/default/rhn_server_upload_package-push.conf
%config %{_sysconfdir}/logrotate.d/rhn_package_push
%attr(640,root,apache) %config %{httpdconf}/rhn/package-push.conf

%files tools
%defattr(-,root,root)
%attr(640,root,apache) %{rhnconf}/default/rhn_server_satellite.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_satellite
%attr(755,root,root) %{_bindir}/rhn-charsets
%attr(755,root,root) %{_bindir}/rhn-satellite-activate
%attr(755,root,root) %{_bindir}/rhn-schema-version
%attr(755,root,root) %{_bindir}/rhn-ssl-dbstore
%attr(755,root,root) %{_bindir}/satellite-sync
%attr(755,root,root) %{_bindir}/spacewalk-debug
%attr(755,root,root) %{_bindir}/rhn-satellite-exporter
%attr(755,root,root) %{_bindir}/update-packages
%attr(755,root,root) %{_bindir}/migrate-system-profile
%{rhnroot}/satellite_tools/SequenceServer.py*
%{rhnroot}/satellite_tools/messages.py*
%{rhnroot}/satellite_tools/progress_bar.py*
%{rhnroot}/satellite_tools/req_channels.py*
%{rhnroot}/satellite_tools/satrm.py*
%{rhnroot}/satellite_tools/satsync.py*
%{rhnroot}/satellite_tools/satCerts.py*
%{rhnroot}/satellite_tools/satComputePkgHeaders.py*
%{rhnroot}/satellite_tools/syncCache.py*
%{rhnroot}/satellite_tools/sync_handlers.py*
%{rhnroot}/satellite_tools/rhn_satellite_activate.py*
%{rhnroot}/satellite_tools/rhn_ssl_dbstore.py*
%{rhnroot}/satellite_tools/xmlWireSource.py*
%{rhnroot}/satellite_tools/updatePackages.py*
%{rhnroot}/satellite_tools/migrateSystemProfile.py*
%dir %{rhnroot}/satellite_tools/disk_dumper
%{rhnroot}/satellite_tools/disk_dumper/__init__.py*
%{rhnroot}/satellite_tools/disk_dumper/iss.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_ui.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_isos.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_runcommand.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_actions.py*
%{rhnroot}/satellite_tools/disk_dumper/dumper.py*
%{rhnroot}/satellite_tools/disk_dumper/string_buffer.py*
%config %attr(644,root,apache) %{rhnconf}/default/rhn_server_iss.conf
%{_mandir}/man8/rhn-satellite-exporter.8*
%{_mandir}/man8/rhn-charsets.8*
%{_mandir}/man8/rhn-satellite-activate.8*
%{_mandir}/man8/rhn-schema-version.8*
%{_mandir}/man8/rhn-ssl-dbstore.8*
%{_mandir}/man8/satellite-sync.8*
%{_mandir}/man8/spacewalk-debug.8*
%{_mandir}/man8/migrate-system-profile.8*

%files xml-export-libs
%defattr(-,root,root)
%dir %{rhnroot}/satellite_tools
%{rhnroot}/satellite_tools/__init__.py*
%{rhnroot}/satellite_tools/geniso.py*
%{rhnroot}/satellite_tools/gentree.py*
%{rhnroot}/satellite_tools/xmlDiskDumper.py*
# A bunch of modules shared with satellite-tools
%{rhnroot}/satellite_tools/connection.py*
%{rhnroot}/satellite_tools/diskImportLib.py*
%{rhnroot}/satellite_tools/syncLib.py*
%{rhnroot}/satellite_tools/xmlDiskSource.py*
%{rhnroot}/satellite_tools/xmlSource.py*
%dir %{rhnroot}/satellite_tools/exporter
%{rhnroot}/satellite_tools/exporter/__init__.py*
%{rhnroot}/satellite_tools/exporter/exporter.py*
%{rhnroot}/satellite_tools/exporter/exportLib.py*
%{rhnroot}/satellite_tools/exporter/xmlWriter.py*

# $Id$
%changelog
* Mon Feb 09 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.4-1
- bz475894:fixing the server code to filter out duplicate deps 
  when pushing fedora-10+ packages to channels

* Thu Feb 05 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.3-1
- fixing satsync warning.

* Wed Jan 28 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.2-1
- removing rhel-instnum dep requires and associated unsed code

* Tue Jan 20 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.1-1
- 480757 - fix filenames generation in repomd for custom channels
- change Source0 to point to fedorahosted.org

* Thu Jan 15 2009 Pradeep Kilambi 0.4.22-1
- include migrate-system-profile.8 file in the spec

* Thu Jan 15 2009 Milan Zazrivec 0.4.20-1
- include migrate-system-profile manual page

* Wed Jan 14 2009 Dave Parker <dparker@redhat.com> 0.4.18-1
- bz461162 added rule to redirect port 80 requests to /rpc/api to /rhn/rpc/api

* Tue Jan 13 2009 Mike McCune <mmccune@gmail.com> 0.4.15-1
- 461162 - for some reason with our new httpd rework this rewrite rule needs 
  to be in both config files.  Filed space05 bug: 479911 to address this.

* Tue Jan 13 2009 Michael Mraka <michael.mraka@redhat.com> 0.4.13-1
- resolved #479826
- resolved #479825

* Mon Jan 12 2009 Mike McCune <mmccune@gmail.com> 0.4.12-1
- 461162 - get the virtualization provisioning tracking system to work with a :virt system record.
- 479640 - remove conflict with specspo; if it causes problems,
  it should be fixed properly, either in our code or in specspo

* Thu Jan  8 2009 Jan Pazdziora 0.4.10-1
- more changes for nvrea error handling
- changed all references of none to auto w.r.t
  rhnKickstartVirtualizationType
- 467115 - adding a switch so users can turn off same nvrea different
  vendor package uploads
- eliminate satellite-httpd daemon, migrate to 'stock' apache
- 461162 - adding support to push the cobbler profile name down to koan
- 461162 - adding some virt options and spiffifying the virt provisioning page
- 461162 - moving cobbler requirement down to the RPMs that actually use it
- changes are by multiple authors

* Mon Dec 22 2008 Mike McCune <mmccune@gmail.com>
- Adding proper cobbler requirement with version

* Fri Dec 19 2008 Dave Parker <dparker@redhat.com> 0.4.9-1
- Reconfigured backed to use stock apache server rather than satellite-httpd

* Thu Dec 18 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.9-1
- 476055 - fixing sat activation to work by setting the right handler
- 457629 - multiarch support for errata updates

* Fri Dec 12 2008 Jan Pazdziora 0.4.8-1
- 476212 - adding Requires rhel-instnum
- 461162 - remove profile label parameter from the spacewalk-koan call chain
- 461162 - fix problem w/ backend/satellite_tools makefile
- 461162 - remove spacewalk-cobbler-sync as well
- set close-on-exec on log files

* Wed Dec 10 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.7-1
- fix build errors and finish removing of cobbler-spacewalk-sync and 
  spacewalk-cobbler-sync from tools subpackage

* Mon Dec  8 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.6-1
- fixed Obsoletes: rhns-* < 5.3.0

* Thu Dec 5 2008 Partha Aji <paji@redhat.com>
- Removed spacewalk-cobbler-sync & cobbler-spacewalk-sync from tools package

* Wed Nov 18 2008 Partha Aji <paji@redhat.com>
- Added spacewalk-cobbler-sync to tools package

* Mon Nov 17 2008 Devan Goodwin <dgoodwin@redhat.com> 0.4.5-1
- Expand rhnSQL PostgreSQL support.
- Fix rhnSQL connection re-use for both Oracle and PostgreSQL.

* Tue Nov 11 2008 Dave Parker <dparker@redhat.com>
- Added cobbler-spacewalk-sync to tools package

* Thu Nov  6 2008 Devan Goodwin <dgoodwin@redhat.com> 0.4.4-1
- Adding initial support for PostgreSQL.

* Sun Nov  2 2008  Pradeep Kilambi <pkilambi@redhat.com> 0.3.3-1
- fixed the auth issue for registration and iss auth handlers

* Fri Oct 24 2008  Jesus M. Rodriguez <jesusr@redhat.com> 0.3.2-1
- renaming the local exporter

* Fri Oct 10 2008  Pradeep Kilambi <pkilambi@redhat.com>
- support for inter spacewalk sync

* Thu Oct  9 2008  Pradeep Kilambi <pkilambi@redhat.com>
- packaging iss-export dump hanlder

* Thu Oct  9 2008  Miroslav Suchy <msuchy@redhat.com>
- add -iss package for handling ISS

* Wed Sep 24 2008 Milan Zazrivec 0.3.1-1
- bumped version for spacewalk 0.3
- fixed package obsoletes

* Wed Sep  3 2008 jesus rodriguez <jesusr@redhat.com> 0.2.4-1
- rebuilding

* Wed Sep  3 2008 Pradeep Kilambi <pkilambi@redhat.com>
- fixing rhnpush to be able to push packages associating to channels

* Wed Sep  3 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.3-1
- Fixing bug with chown vs chmod.

* Tue Sep  2 2008 Milan Zazrivec 0.2.2-1
- bumped version for tag-release
- removed python-sgmlop, PyXML from spacewalk-backend-server requirements

* Tue Aug 19 2008 Mike McCune 0.1.2-1
- moving requirement for spacewalk-admin version to proper 0.1

* Mon Aug 04 2008  Miroslav Suchy <msuchy@redhat.com> 0.1.2-0
- rename package to spacewalk-server
- cleanup spec

* Mon Jun 30 2008 Pradeep Kilambi <pkilambi@redhat.com>
- including spacewalk-debug tool

* Thu Jun 12 2008 Pradeep Kilambi <pkilambi@redhat.com>
- clean up hosted specific handlers

* Thu Jun 12 2008 Pradeep Kilambi <pkilambi@redhat.com> 5.2.0-9
- updated to use default httpd from distribution

* Thu Sep  6 2007 Jan Pazdziora <jpazdziora@redhat.com>
- updated to use default httpd from distribution

* Thu May 17 2007 Clifford Perry <cperry@redhat.com>
- adding satComputePkgHeaders.py to rhns-satellite-tools. Needed for upgrades

* Wed Apr 11 2007 Pradeep Kilambi <pkilambi@redhat.com>
- removing rhns-soa from backend.spec
- removing hosted specific handlers

* Tue Dec 12 2006 Jesus Rodriguez <jesusr@redhat.com>
- Added rhns-soa package

* Thu Nov 30 2006 Ryan Newberry <rnewberr@redhat.com>
- Updated some files defs to handle the fact that .pyc and .pyo files
  are generated on RHEL5 for geniso.py and gentree.py

* Wed Nov 08 2006 Bret McMillan <bretm@redhat.com>
- remove the preun trigger that nukes the cache, too expensive an operation
  to happen each and every time

* Thu Nov 02 2006 James Bowes <jbowes@redhat.com>
- Remove rhnpush (it has its own spec file now).

* Fri Oct 20 2006 James Bowes <jbowes@redhat.com>
- Replace cheetah with hand-coded xml generation.

* Wed Oct 11 2006 James Bowes <jbowes@redhat.com>
- Include template file for other.xml

* Mon Jul 17 2006 James Bowes <jbowes@redhat.com>
- Add repository metadata generation files.

* Sun Feb 19 2006 Bret McMillan <bretm@redhat.com>
- make rhns-[xp/app/bugzilla] conflict with specspo

* Fri Jul  1 2005 Joel Martin <jmartin@redhat.com> 4.0.0-131
- Makefile.defs python compile searches PATH for python

* Mon Jun  6 2005 Mihai Ibanescu <misa@redhat.com> 4.0.0-106
- split rhns-sql out of rhns-server, to allow for this piece of functionality
  without needing mod_python etc.

* Mon Oct 11 2004 Todd Warner <taw@redhat.com>
- removed rmchannel

* Mon Aug 09 2004 Todd Warner <taw@redhat.com>
- send-satellite-debug executable and manpage pulled

* Tue Jul 06 2004 Todd Warner <taw@redhat.com>
- rhns-shared goes away. Code moves to rhns-certs-tools elsewhere.
- rhn-ssl-dbstore and associated files added.

* Tue Jun 15 2004 Todd Warner <taw@redhat.com>
- new RPM: rhns-shared

* Tue Jun 01 2004 Todd Warner <taw@redhat.com>
- rhn_satellite_activate.py added to spec file.

* Fri May 28 2004 Todd Warner <taw@redhat.com>
- rhn-charsets and manpage added to satellite-tools.
  Thanks to Cliff Perry <cperry@redhat.com> for the script.

* Tue Mar 30 2004 Mihai Ibanescu <misa@redhat.com>
- rhns-upload-server and rhns-package-push-server added to this tree

* Thu Dec 11 2003 Todd Warner <taw@redhat.com>
- rhn-satellite-activate and manpage added to satellite-tools.

* Thu Dec 11 2003 Todd Warner <taw@redhat.com>
- rhn-schema-version and manpage added to satellite-tools.

* Thu Oct 16 2003 Mihai Ibanescu <misa@redhat.com>
- action_error renamed to action_extra_data

* Mon Jul 28 2003 Todd Warner <taw@redhat.com>
- rhnpush.8 (man page) in the rhnpush RPM now instead of satellite-tools (oops)

* Fri Jun  6 2003 Todd Warner <taw@redhat.com>
- man pages added: satellite-debug.8, send-satellite-debug.8, & rhnpush.8

* Thu May  8 2003 Mihai Ibanescu <misa@redhat.com>
- rhns-xml-export-libs depends on python-iconv

* Tue Apr 15 2003 Todd Warner <taw@redhat.com>
- added a number of .py files to the satellite_tools lineup.
- added a number of .py files to the server/importLib lineup.

* Thu Apr  3 2003 Mihai Ibanescu <misa@redhat.com>
- xml-export-libs owns the satellite_tools dir (and therefore also needs
  __init__)

* Tue Mar 18 2003 Todd Warner <taw@redhat.com>
- added rhnLockfile.py. Used by various commandline tools (e.g. satellite-sync).
- rhnFlock.py is no longer used (previously used for locking down log files).

* Tue Mar 11 2003 Cristian Gafton <gafton@redhat.com>
- add hourly crons to rhns-tools

* Fri Feb 28 2003 Mihai Ibanescu <misa@redhat.com>
- Added server/action_error/*

* Fri Jan 31 2003 Mihai Ibanescu <misa@redhat.com>
- Attempt to sanitize the satellite_ttols dir: added xml-export-libs

* Mon Jan 27 2003 Mihai Ibanescu <misa@redhat.com>
- Requires PyXML

* Mon Jan 14 2003 Todd Warner <taw@redhat.com>
- moved ownership of the /var/cache/rhn directory to the rhns-server rpm.
  It's really a server/satellite thang.
- blow away the cache upon uninstallation.

* Mon Jan 13 2003 Mihai Ibanescu <misa@redhat.com>
- Added rmchannel

* Thu Nov  7 2002 Mihai Ibanescu <misa@redhat.com>
- Fixed bug 77463

* Tue Nov  5 2002 Mihai Ibanescu <misa@redhat.com>
- rhnpush should not require rhns-server. rhnpush doesn't even need rhns.
  Bug 77371

* Tue Oct 29 2002 Todd Warner <taw@redhat.com>
- satellite-import goes away.

* Mon Oct  7 2002 Cristian Gafton <gafton@redhat.com>
- updated the tools subpackage

* Wed Oct  2 2002 Mihai Ibanescu <misa@redhat.com>
- added rhns-applet
- removed the requirements imposed by the build system

* Thu Sep 19 2002 Todd Warner <taw@redhat.com>
- rhns shouldn't require DCOracle.
- rhnDefines.py is no longer a part of rhns.

* Wed Sep 11 2002 Todd Warner <taw@redhat.com>
- s/python-clap/python-optik
- appearantly we forgot to require python-optik for satellite-tools as well.

* Tue Aug 20 2002 Cristian Gafton <gafton@redhat.com>
- add satellite-tools back; my split efforts are failing one by one...

* Mon Aug 19 2002 Cristian Gafton <gafton@redhat.com>
- add rhnpush to the mix

* Wed Aug  7 2002 Cristian Gafton <gafton@redhat.com>
- merged the former rhns-notification spec file in too (now as rhns-tools)
- fix post, which should not be tagged to the server package
- renamed some conig files to math their package names better
- merged the spec files for rhns-common and rhns-server into a single
  one. Now the rhns-common package is called simply rhns

* Thu Jul 25 2002 Cristian Gafton <gafton@redhat.com>
- renaming of the default config files
- add per subpackage logrotate files

* Mon Jun 17 2002 Mihai Ibanescu <misa@redhat.com>
- bugzilla component name changed

* Tue Jun 11 2002 Todd Warner <taw@redhat.com>
- bugzilla specific code pulled out of the app_internal RPM and given its own.

* Fri May 31 2002 Todd Warner <taw@redhat.com>
- adding server/rhnPackage.py

* Tue May 21 2002 Cristian Gafton <gafton@redhat.com>
- fix location of config files
- get rid of the RHNS usage
- fix the license fields
- moved rhn_server_satellite.conf back in the rhns-server-sat package
- add defattr to all subpackages
- fix default permissions for config files (apache should be able to
  read them, but not change them)

* Thu May 16 2002 Todd Warner <taw@redhat.com>
- rhn_server_satellite.conf was double serviced in the main server and in sat.
  It is used by satellite-tools as well so needs to reside in rhns-server.

* Wed May 15 2002 Todd Warner <taw@redhat.com>
- httpd.conf.sample file should be a real conf file (..._xmlrpc.httpd.conf).

* Tue May 14 2002 Cristian Gafton <gafton@redhat.com>
- add support for multiple release building

* Tue Apr 23 2002 Cristian Gafton <gafton@redhat.com>
- add rhnHandler

* Thu Apr 18 2002 Todd Warner <taw@redhat.com>
- took out references to rhnslib
- fixed sat stuff.
- added *.httpd.conf files.
- added *.httpd.conf.sample file.
- rhnImport.py* was missing.
- server/handlers/__init__.py* was missing.

* Wed Apr 17 2002 Cristian Gafton <gafton@redhat.com>
- add rhnMapping, apacheHandler and rhnServer
- minor reorg to the files section - still need to figure out if we
  need to ship the whole importlib to all subpackages....

* Wed Apr 17 2002 Mihai Ibanescu <misa@redhat.com>
- /var/up2date/ no longer needed: replaced with /var/cache/rhn
- split rhns-server-{xmlrpc,sat,app,xp}

* Tue Apr 16 2002 Cristian Gafton <gafton@redhat.com>
- add rhnChannel, rhnRPM, rhnUser

* Fri Mar 15 2002 Todd Warner <taw@redhat.com>
- rhnServerLogRotate --> rhn_server in the logrotate directory.

* Thu Mar 14 2002 Todd Warner <taw@redhat.com>
- preun's added that rpmsave the rhn.conf file upon rpm -e.
  This was chosen in opposition to making rhn.conf a config'ed
  file... which has its own side-effects.

* Wed Mar 13 2002 Cristian Gafton <gafton@redhat.com>
- update for the new bs

* Sun Mar 10 2002 Todd Warner <taw@redhat.com>
- removed old obsoletes that simply don't matter.

* Fri Mar  8 2002 Mihai Ibanescu <misa@redhat.com>
- defined rhnconf
- added {rhnroot}/server/conf/rhn.conf

* Thu Mar 07 2002 Todd Warner <taw@redhat.com>
- new common/rhnConfig.py methodology
- server/rhnConfig.py gone
- rhnConfigCheck.py gone
- siteConfig.py no longer relevant
- /etc/rhn/rhn.conf stuff added.
- give ownership of /etc/rhn/rhn.conf to apache
- added log rotation crap.
- fixed a couple of install section errors.

* Wed Oct 17 2001 Todd Warner <taw@redhat.com>
- change location of server specific en/ and ro/ directories.
- small comment/description changes.
- changelog has consistent spacing now.

* Fri Aug 10 2001 Cristian Gafton <gafton@redhat.com>
- track rhnSecret.py as a ghost file

* Mon Jul 30 2001 Mihai Ibanescu <misa@redhat.com>
- Added server/action/*

* Mon Jul 23 2001 Mihai Ibanescu <misa@redhat.com>
- Added a requires for a specific version of rpm-python, since we are sending
  the headers with a digest attached.
  
* Thu Jul 12 2001 Mihai Ibanescu <misa@redhat.com>
- siteConfig.py is now config(noreplace) since it was screwing up the
  already-installed siteConfig.py
  
* Mon Jul 10 2001 Todd Warner <taw@redhat.com>
- /var/log/rhns --> /var/log/rhn to match rhnConfig.py

* Mon Jul  9 2001 Cristian Gafton <gafton@redhat.com>
- get rid of the -head package and integrate everything in the rhns-server

* Mon Jul  9 2001 Mihai Ibanescu <misa@redhat.com>
- Added an explicit dependency on python-xmlrpc >= 1.4.4
- Added /var/log/rhns

* Sun Jul 08 2001 Todd Warner <taw@redhat.com>
- unified and now install config files properly

* Tue Jul  3 2001 Cristian Gafton <gafton@redhat.com>
- no more webapp

* Fri Jun 29 2001 Mihai Ibanescu <misa@redhat.com>
- Added /var/up2date/list as a dir

* Tue Jun 19 2001 Cristian Gafton <gafton@redhat.com>
- rename the base package to rhns-server
- import the version and release from the version file

* Mon Jun 18 2001 Mihai Ibanescu <misa@rehdat.com>
- Rebuild

* Fri Jun 15 2001 Mihai Ibanescu <misa@redhat.com>
- Built packages as noarch
- Added a postinstall script to generate the secret
- RPM_BUILD_ROOT is created by the install stage

* Thu Jun 14 2001 Cristian Gafton <gafton@redhat.com>
- siteConfig is now nstalled by Makefile; no need to touch it
- make siteConfig common with the proxy package

* Thu Jun 14 2001 Mihai Ibanescu <misa@redhat.com>
- Added some files 
- Fixed the install stage
- Added dependency on rhns-common

* Tue Jun 12 2001 Cristian Gafton <gafton@redhat.com>
- rework for the new layout

* Fri Mar 16 2001 Cristian Gafton <gafton@redhat.com> 
- deploy the new code layout
- ship a compiled version of config as well
- don't ship default config files that open holes to the world

* Fri Mar 16 2001 Adrian Likins <alikins@redhat.com>
- add the bugzilla_errata stuff to app packages

* Mon Mar 12 2001 Cristian Gafton <gafton@redhat.com> 
- get rid of the bsddbmodule source code (unused in the live site)

