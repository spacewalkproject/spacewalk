%define rhnroot %{_prefix}/share/rhn
%define rhnconf %{_sysconfdir}/rhn
%define httpdconf %{rhnconf}/satellite-httpd/conf
%define apacheconfd %{_sysconfdir}/httpd/conf.d
%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Name: spacewalk-backend
Summary: Common programs needed to be installed on the Spacewalk servers/proxies
Group: Applications/Internet
License: GPLv2
Version: 0.9.12
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: python, rpm-python
# /etc/rhn is provided by spacewalk-proxy-common or by spacewalk-config
Requires: /etc/rhn
Requires: rhnlib >= 1.8
Requires: %{name}-libs = %{version}-%{release}
BuildRequires: /usr/bin/msgfmt
BuildRequires: /usr/bin/docbook2man
BuildRequires: docbook-utils
Requires(pre): httpd
# we don't really want to require this redhat-release, so we protect
# against installations on other releases using conflicts...
Obsoletes: rhns-common < 5.3.0
Obsoletes: rhns < 5.3.0
Provides: rhns = %{version}-%{release}

%description 
Generic program files needed by the Spacewalk server machines.
This package includes the common code required by all servers/proxies.

%package sql
Summary: Core functions providing SQL connectivity for the RHN backend modules
Group: Applications/Internet
Requires(pre): %{name} = %{version}-%{release}
Requires: python(:DBAPI:oracle)
Obsoletes: rhns-sql < 5.3.0
Provides: rhns-sql = %{version}-%{release}

%description sql
This package contains the basic code that provides SQL connectivity for the Spacewalk
backend modules.

%package server
Summary: Basic code that provides RHN Server functionality
Group: Applications/Internet
Requires(pre): %{name}-sql = %{version}-%{release}
Requires: PyPAM
Obsoletes: rhns-server < 5.3.0
Provides: rhns-server = %{version}-%{release}

%if  0%{?rhel} && 0%{?rhel} < 6
Requires: mod_python
%else
Requires: mod_wsgi
%endif


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
Provides: rhns-server-xmlrpc = %{version}-%{release}
Provides: rhns-xmlrpc = %{version}-%{release}

%description xmlrpc
These are the files required for running the /XMLRPC handler, which
provide the basic support for the registration client (rhn_register)
and the up2date clients.

%package applet
Summary: Handler for /APPLET
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-applet < 5.3.0
Provides: rhns-applet = %{version}-%{release}

%description applet
These are the files required for running the /APPLET handler, which
provides the functions for the RHN applet.

%package app
Summary: Handler for /APP
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-app < 5.3.0
Obsoletes: rhns-app < 5.3.0
Provides: rhns-server-app = %{version}-%{release}
Provides: rhns-app = %{version}-%{release}

%description app
These are the files required for running the /APP handler.
Calls to /APP are used by internal maintenance tools (rhnpush).

%package xp
Summary: Handler for /XP
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-xp < 5.3.0
Obsoletes: rhns-xp < 5.3.0
Provides: rhns-server-xp = %{version}-%{release}
Provides: rhns-xp = %{version}-%{release}

%description xp
These are the files required for running the /XP handler.
Calls to /XP are used by tools publicly available (like rhn_package_manager).

%package iss
Summary: Handler for /SAT
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-sat < 5.3.0
Provides: rhns-sat = %{version}-%{release}

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

%package libs
Summary: Spacewalk server and client tools libraries
Group: Applications/Internet
BuildRequires: python-devel
Requires: python-hashlib

%description libs
Libraries required by both Spacewalk server and Spacewalk client tools.

%package config-files-common
Summary: Common files for the Configuration Management project
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-config-files-common < 5.3.0
Provides: rhns-config-files-common = %{version}-%{release}

%description config-files-common
Common files required by the Configuration Management project

%package config-files
Summary: Handler for /CONFIG-MANAGEMENT
Group: Applications/Internet
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files < 5.3.0
Provides: rhns-config-files = %{version}-%{release}

%description config-files
This package contains the server-side code for configuration management.

%package config-files-tool
Summary: Handler for /CONFIG-MANAGEMENT-TOOL
Group: Applications/Internet
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files-tool < 5.3.0
Provides: rhns-config-files-tool = %{version}-%{release}

%description config-files-tool
This package contains the server-side code for configuration management tool.

%package upload-server
Summary: Server-side listener for rhn-pkgupload
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-upload-server < 5.3.0
Provides: rhns-upload-server = %{version}-%{release}

%description upload-server
Server-side listener for rhn-pkgupload

%package package-push-server
Summary: Listener for rhnpush (non-XMLRPC version)
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-package-push-server < 5.3.0
Provides: rhns-package-push-server = %{version}-%{release}

%description package-push-server
Listener for rhnpush (non-XMLRPC version)

%package tools
Summary: Red Hat Network Services Satellite Tools
Group: Applications/Internet
Requires: %{name}-xmlrpc = %{version}-%{release}
Requires: %{name}-app = %{version}-%{release}
Requires: %{name}
Requires: spacewalk-certs-tools
Requires: spacewalk-admin >= 0.1.1-0
Requires: python-gzipstream
Requires: python-hashlib
Requires: PyXML
Requires: mod_ssl
Requires: %{name}-xml-export-libs
Requires: cobbler >= 1.4.3
Requires: rhnlib  >= 2.5.20
Obsoletes: rhns-satellite-tools < 5.3.0
Obsoletes: spacewalk-backend-satellite-tools <= 0.2.7
Provides: rhns-satellite-tools = %{version}-%{release}

%description tools
Various utilities for the Red Hat Network Satellite Server.

%package xml-export-libs
Summary: Red Hat Network XML data exporter
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-xml-export-libs < 5.3.0
Provides: rhns-xml-export-libs = %{version}-%{release}

%description xml-export-libs
Libraries required by various exporting tools
XXX To be determined if the proper location is under backend

%prep
%setup -q

%build
make -f Makefile.backend all
export PYTHON_MODULE_NAME=%{name}
export PYTHON_MODULE_VERSION=%{version}
%{__python} setup.py build

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make -f Makefile.backend install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}
export PYTHON_MODULE_NAME=%{name}
export PYTHON_MODULE_VERSION=%{version}
%{__python} setup.py install -O1 --root $RPM_BUILD_ROOT --prefix=%{_prefix}

%if 0%{?rhel} && 0%{?rhel} < 6
rm -v $RPM_BUILD_ROOT/%{apacheconfd}/zz-spacewalk-server-wsgi.conf
rm -rfv $RPM_BUILD_ROOT/%{rhnroot}/server/wsgi
%else
rm -v $RPM_BUILD_ROOT/%{apacheconfd}/zz-spacewalk-server-python.conf
%endif


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
%{rhnroot}/common/apache.py*
%{rhnroot}/common/rhn_posix.py*
%{rhnroot}/common/rhn_timer.py*
%{rhnroot}/common/rhnApache.py*
%{rhnroot}/common/rhnCache.py*
%{rhnroot}/common/rhnConfig.py*
%{rhnroot}/common/rhnException.py*
%{rhnroot}/common/rhnFlags.py*
%{rhnroot}/common/rhnLib.py*
%{rhnroot}/common/rhnLog.py*
%{rhnroot}/common/rhnMail.py*
%{rhnroot}/common/rhnTB.py*
%{rhnroot}/common/rhnRepository.py*
%{rhnroot}/common/rhnTranslate.py*
%{rhnroot}/common/UserDictCase.py*
%{rhnroot}/common/RPC_Base.py*
%attr(770,root,apache) %dir %{_var}/log/rhn
# config files
%attr(750,root,apache) %dir %{rhnconf}/default
%attr(640,root,apache) %{rhnconf}/default/rhn.conf
%attr(755,root,root) %{_bindir}/spacewalk-cfg-get
%{_mandir}/man8/spacewalk-cfg-get.8.gz

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
%{rhnroot}/server/rhnPackage.py*
%{rhnroot}/server/rhnPackageUpload.py*
%{rhnroot}/server/basePackageUpload.py*
%{rhnroot}/server/rhnHandler.py*
%{rhnroot}/server/rhnImport.py*
%{rhnroot}/server/rhnLib.py*
%{rhnroot}/server/rhnMapping.py*
%{rhnroot}/server/rhnRepository.py*
%{rhnroot}/server/rhnSession.py*
%{rhnroot}/server/rhnUser.py*
%{rhnroot}/server/rhnVirtualization.py*
%{rhnroot}/server/taskomatic.py*
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
%attr(750,apache,apache) %dir %{_var}/cache/rhn
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server.conf
# main httpd config
%attr(640,root,apache) %config %{apacheconfd}/zz-spacewalk-server.conf

%if 0%{?rhel} && 0%{?rhel} < 6
%attr(640,root,apache) %config %{apacheconfd}/zz-spacewalk-server-python.conf
%else
# wsgi stuff
%attr(640,root,apache) %config %{apacheconfd}/zz-spacewalk-server-wsgi.conf
%dir %{rhnroot}/server/wsgi
%{rhnroot}/server/wsgi/__init__.py*
%{rhnroot}/server/wsgi/app.py*
%{rhnroot}/server/wsgi/applet.py*
%{rhnroot}/server/wsgi/config.py*
%{rhnroot}/server/wsgi/config_tool.py*
%{rhnroot}/server/wsgi/package_push.py*
%{rhnroot}/server/wsgi/package_upload.py*
%{rhnroot}/server/wsgi/sat.py*
%{rhnroot}/server/wsgi/sat_dump.py*
%{rhnroot}/server/wsgi/wsgiHandler.py*
%{rhnroot}/server/wsgi/wsgiRequest.py*
%{rhnroot}/server/wsgi/xmlrpc.py*
%{rhnroot}/server/wsgi/xp.py*
%endif

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
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-xmlrpc.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_xmlrpc

%files applet
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/applet
%{rhnroot}/server/handlers/applet/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_applet.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-applet.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_applet

%files app
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/app
%{rhnroot}/server/handlers/app/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_app.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-app.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_app

%files xp
%defattr(-,root,root) 
%dir %{rhnroot}/server/handlers/xp
%{rhnroot}/server/handlers/xp/*
# config files
%attr(640,root,apache) %{rhnconf}/default/rhn_server_xp.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-xp.conf
%config %{_sysconfdir}/logrotate.d/rhn_server_xp

%files iss
%defattr(-,root,root)
%dir %{rhnroot}/server/handlers/sat
%{rhnroot}/server/handlers/sat/*
%config %{_sysconfdir}/logrotate.d/rhn_server_sat
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-sat.conf

%files iss-export
%defattr(-,root,root)

%dir %{rhnroot}/satellite_exporter
%{rhnroot}/satellite_exporter/__init__.py*
%{rhnroot}/satellite_exporter/satexport.py*

%dir %{rhnroot}/satellite_exporter/handlers
%{rhnroot}/satellite_exporter/handlers/__init__.py*
%{rhnroot}/satellite_exporter/handlers/non_auth_dumper.py*
# config files
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-sat-export-internal.conf
%config %{_sysconfdir}/logrotate.d/rhn_sat_export_internal
%attr(640,root,apache) %{rhnconf}/default/rhn_server_satexport.conf
%attr(640,root,apache) %{rhnconf}/default/rhn_server_satexport_internal.conf


%files libs
%defattr(-,root,root)
%{python_sitelib}/spacewalk*

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
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-config-management.conf
%config %{_sysconfdir}/logrotate.d/rhn_config_management

%files config-files-tool
%defattr(-,root,root)
%dir %{rhnroot}/server/handlers/config_mgmt
%{rhnroot}/server/handlers/config_mgmt/*
%attr(640,root,apache) %{rhnconf}/default/rhn_server_config-management-tool.conf
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-config-management-tool.conf
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
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-pkg-upload.conf

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
%attr(640,root,apache) %config %{httpdconf}/rhn/spacewalk-backend-package-push.conf

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
%attr(755,root,root) %{_bindir}/spacewalk-repo-sync
%attr(755,root,root) %{_bindir}/rhn-db-stats
%attr(755,root,root) %{_bindir}/rhn-schema-stats
%attr(750,root,root) %{_bindir}/satpasswd
%attr(750,root,root) %{_bindir}/satwho
%attr(750,root,root) %{_bindir}/spacewalk-remove-channel*
%{rhnroot}/satellite_tools/SequenceServer.py*
%{rhnroot}/satellite_tools/messages.py*
%{rhnroot}/satellite_tools/progress_bar.py*
%{rhnroot}/satellite_tools/req_channels.py*
%{rhnroot}/satellite_tools/rhn-entitlement-report.py*
%{rhnroot}/satellite_tools/satsync.py*
%{rhnroot}/satellite_tools/satCerts.py*
%{rhnroot}/satellite_tools/satComputePkgHeaders.py*
%{rhnroot}/satellite_tools/syncCache.py*
%{rhnroot}/satellite_tools/sync_handlers.py*
%{rhnroot}/satellite_tools/rhn_satellite_activate.py*
%{rhnroot}/satellite_tools/rhn_ssl_dbstore.py*
%{rhnroot}/satellite_tools/xmlWireSource.py*
%{rhnroot}/satellite_tools/updatePackages.py*
%{rhnroot}/satellite_tools/updateSignatures.py*
%{rhnroot}/satellite_tools/reposync.py*
%{rhnroot}/satellite_tools/constants.py*
%dir %{rhnroot}/satellite_tools/disk_dumper
%{rhnroot}/satellite_tools/disk_dumper/__init__.py*
%{rhnroot}/satellite_tools/disk_dumper/iss.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_ui.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_isos.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_runcommand.py*
%{rhnroot}/satellite_tools/disk_dumper/iss_actions.py*
%{rhnroot}/satellite_tools/disk_dumper/dumper.py*
%{rhnroot}/satellite_tools/disk_dumper/string_buffer.py*
%dir %{rhnroot}/satellite_tools/repo_plugins
%attr(770,root,apache) %dir %{_var}/log/rhn/reposync
%{rhnroot}/satellite_tools/repo_plugins/__init__.py*
%{rhnroot}/satellite_tools/repo_plugins/yum_src.py*
%config %attr(644,root,apache) %{rhnconf}/default/rhn_server_iss.conf
%{_mandir}/man8/rhn-satellite-exporter.8*
%{_mandir}/man8/rhn-charsets.8*
%{_mandir}/man8/rhn-satellite-activate.8*
%{_mandir}/man8/rhn-schema-version.8*
%{_mandir}/man8/rhn-ssl-dbstore.8*
%{_mandir}/man8/rhn-db-stats.8*
%{_mandir}/man8/rhn-schema-stats.8*
%{_mandir}/man8/satellite-sync.8*
%{_mandir}/man8/spacewalk-debug.8*
%{_mandir}/man8/satpasswd.8*
%{_mandir}/man8/satwho.8*
%{_mandir}/man8/spacewalk-remove-channel.8*

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
* Mon Mar 22 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.12-1
- 571413 - fixed source rpackage push
- fixing wsgi error handling

* Thu Mar 18 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.11-1
- 561553 - fixed missing commit
- 564278 - fixed satellite-sync call from rhn-satellite-activate

* Wed Mar 17 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.10-1
- 568958 - package removal and verify
- 573140 - solaris packages with duplicate requires

* Fri Mar 12 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.9-1
- Fixed constraint violation when satellite had multiple certs
- 558502 - fixed ordering issue in reprovisioning

* Wed Mar 10 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.8-1
- 571365 - fixed solaris mpm packages import
- spacewalk-remove-channel improvements

* Mon Mar 08 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.7-1
- fixed import to work with satellites running older versions of rhnLib
- 568371 - fix an ORA-00918 on config file import
- fixed error ihandling for spacewalk-channel-remove
- 570176 - disable caching the channel info during export
- spacewalk-remove-channel script enhancements
- 569233 - exit with error value upon error

* Wed Feb 24 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.6-1
- fixed missing require
- fixed dates in rhn-satellite-exporter

* Tue Feb 23 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.5-1
- improved spacewalk-repo-sync

* Mon Feb 22 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.4-1
- fixed import error proxy ImportError: No module named server
- 246480 - sync last_modified column for rhnKickstartableTree as well.
- 501024 - want to preserve families for channels which are already in the dump

* Fri Feb 19 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.1-1
- added repo deletion to channel remove script
- added spacewalk-remove-channel
- added mechanism for updating existing sha256 packages
- 562644 - added class to emulate mod_python's mp_table

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.43-1
- updated copyrights
- 479911 - removing duplicate rewrites and consolidating to a single location
- added utility to update package checksums

* Wed Feb 03 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.42-1
- implemented satellite-sync --dump-version
- 556761 - existing packages result in not importing gpg signature
- fixed config files not be deployed if system is subscribed to config channel

* Mon Feb 01 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.41-1
- removed unreferenced functions
- let use rhnLockfile from rhnlib
- removed old python 1.5 code
- Revert "543509 - do not fail if machine has not uuid set (like qemu)"

* Fri Jan 29 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.40-1
- fixed the sha module is deprecated
- fixed maximum recursion depth exceeded

* Fri Jan 29 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.39-1
- fixed ISE on F12 mod_wsgi
- 545389 - initial satellite-sync performance issue -- force use of index.

* Wed Jan 27 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.38-1
- fixed packaging of wsgi handler files

* Tue Jan 26 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.37-1
- fixed HTTP 404 on package download
- execute commands through shell

* Fri Jan 22 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.36-1
- fixed handling subprocess.poll() return codes
- 557581 - fixed config deployment would fail when multiple activation keys present

* Thu Jan 21 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.35-1
- fixed bug from popen2 -> subprocess migration
- check parent_channel label only if exists
- 526696 - checking whether server already uses a token
- 528214 - Encode DBstrings as utf-8 bytes before truncating

* Wed Jan 20 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.33-1
- fixed payload_size always = 0 error
- removed dead code in rhn_rpm.py

* Tue Jan 19 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.32-1
- 556460 - time values are <long> on Fedora 12
- fixed DeprecationWarnings on Fedora 12
- 524722 - add /etc/httpd/conf.d to the spacewalk-debug

* Mon Jan 18 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.31-1
- fixed import errors

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.30-1
- added import of rhn-channel-checksum-type

* Thu Jan 14 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.28-1
- SHA256 code cleanup

* Wed Jan 13 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.25-1
- ISS should work again

* Wed Jan 13 2010 Tomas Lestach <tlestach@redhat.com> 0.8.23-1
- preparations for srpm sync (tlestach@redhat.com)

* Tue Jan 12 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.22-1
- fixed more ISS SHA256 errors
- Force correct UTF-8 for changelog name and text.

* Mon Jan 11 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.21-1
- fixed satsync -l over ISS 
- fixed failure of httpd to (re)start
* Sat Jan 09 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.20-1
- fixed SHA256 packages import

* Fri Jan 08 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.19-1
- fixed rhnpush and satellite-sync sha256 errors
- adding wsgi support adapter and removing code dependence on mod_python
- 528833 - having username printed instead of user object

* Thu Jan 07 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.18-1
- made satelite-sync understand both 3.4 and 3.5 dumps
- 175155 - bump up protocol version to 3.5

* Tue Jan 05 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.16-1
- made rhn-satellite-exporter SHA256 ready

* Tue Jan 05 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.15-1
- merged satellite_exporter/exporter into satellite_tools/disk_dumper

* Mon Jan 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.14-1
- more fixes in SHA256 implementation

* Thu Dec 17 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.13-1
- fixed kickastart import for sha256 exports
- 528833 - fixed using an activation key of a disabled user

* Wed Dec 16 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.12-1
- fixed satellite-sync of pre-sha256 exports

* Mon Dec 14 2009 Jan Pazdziora 0.8.10-1
- reporting: add column total to the entitlements report

* Mon Dec 14 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.11-1
- fixed satellite-sync errata import

* Fri Dec 11 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.8-1
- removed a lot of dead code
- fixed getFileChecksum usage
- SHA256 fixes
* Thu Dec 10 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.7-1
- added support for uploading SHA256 rpms
- 541078 - rhn-satellite-exporter --start-date and --end-date issues fixed

* Wed Dec 09 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.5-1
- 516767 - create files with default repository owner/group/permissions
- removed duplicated code from syncLib

* Tue Dec 08 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.4-1
- fixed file glob for -libs

* Mon Dec 07 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.3-1
- moved code from rhnlib to spacewalk-backend-libs
- 543509 - do not fail if machine has not uuid set (like qemu)

* Fri Dec  4 2009 Miroslav Suchý <msuchy@redhat.com> 0.8.2-1
- sha256 support

* Fri Dec 04 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- rhn_rpm/rhn_mpm moved to rhnlib
- bumping Version to 0.8.0

* Tue Dec  1 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.18-1
- 449167 - time.strptime can not handle None values

* Thu Nov 26 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.17-1
- fix compilation error

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.16-1
- 540544 - raise error if channel do not exist or you are not allowed to add or remove it
- 540544 - fix usage of check_user_password
- made conditions more readable (michael.mraka@redhat.com)

* Thu Nov 19 2009 Jan Pazdziora 0.7.15-1
- 537063 - drop the report-specific options

* Wed Nov 18 2009 Jan Pazdziora 0.7.14-1
- reporting: add reports "users" and "users-systems".

* Thu Nov 12 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.13-1
- merged exportLib from satellite_exporter to satellite_tools
* Thu Nov  5 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.12-1
- save some time
- replace isinstance with has_key
- do not check xml corectness twice
- call _dict_to_utf8 only once
- 528227 - Warning in case sync would move the channel between orgs.
- do not vaste time checking if string is instance of UnicodeType
- order test according to probability that the type will appear
- reverting 68bed9e28e2973d3e1e30816d9090b7f5e1d4005
- do not ask repeatedly if types has attribute UnicodeKey
- removing unnecessary condition
- optimize code

* Fri Oct 30 2009 Jan Pazdziora 0.7.11-1
- reporting: add column type to the errata-list report.
- removed redundant else; we call associate_package anyway (Michael M.)

* Mon Oct 26 2009 Jan Pazdziora 0.7.10-1
- reporting: added --info options and documentation of reports and fields

* Fri Oct 23 2009 Jan Pazdziora 0.7.9-1
- reporting: added report errata-list and errata-system

* Thu Oct 22 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.8-1
- 449167 - record installation date of rpm package

* Mon Oct 19 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.7-1
- removed unused parameter
- changed get_package_path comment to reflect new package path
- Include constraint info in schema statistics

* Fri Oct 02 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.6-1
- spacewalk-backend-tools requires python-hashlib

* Thu Oct 01 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.7.5-1
- rhn-db-stats: split database & schema statistics (mzazrivec@redhat.com)
- fixes for 524231, 523393, 523760, 523384 (jpazdziora@redhat.com)
- catch all exceptions, so that we commit in all cases. (jpazdziora@redhat.com)
- If we fail, let us commit the previous updates (done in this transaction).
  (jpazdziora@redhat.com)
- Do the rhn_rpm.get_package_header before we do the actual move.
  (jpazdziora@redhat.com)
- No commit in processPackageKeyAssociations. (jpazdziora@redhat.com)
- clean up (pkilambi@redhat.com)
- if nevra enabled use md5sum as a unique constraint for package pushes
  (pkilambi@redhat.com)
- Move the debug message up; if the OS operation fail, we will know what we
  were trying to do. (jpazdziora@redhat.com)
- Add more actual values to log messages, to make debugging easier.
  (jpazdziora@redhat.com)
- No need to sleep if we want the /var/satellite migration to be faster.
  (jpazdziora@redhat.com)
- Update using id, as there is no index on rhnPackage.path which could be used.
  (jpazdziora@redhat.com)

* Fri Sep 04 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.4-1
- fixed output of multivalue variables in spacewalk-cfg-get

* Tue Sep 01 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.3-1
- 494813 - print error message instead of traceback
- postgresql dependency moved to spacewalk-postgresql

* Fri Aug 28 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.2-1
- use spacewalk-cfg-get instead of awk
- added mirror list support to spacewalk-repo-sync
- fixed an ISE relating to config management w/selinux

* Thu Aug 13 2009 Devan Goodwin <dgoodwin@redhat.com> 0.7.1-1
- Add spacewalk-backend Requires on python-pgsql. (dgoodwin@redhat.com)
- 516237 - Fix the channel family population task to take into account None
  counts and use 0 instead while computing the purge count.
  (pkilambi@redhat.com)
- bumping versions to 0.7.0 (jmatthew@redhat.com)

* Wed Aug 05 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.30-1
- 

* Wed Aug 05 2009 Jan Pazdziora 0.6.29-1
- reporting: add the entitlements report
- enhancing logging mechanism for spacewalk-repo-sync (jsherril@redhat.com)
- Merge branch 'master' into repo-sync (jsherril@redhat.com)
- Patch: Selinux Context support for config files (joshua.roys@gtri.gatech.edu)
- merge conflict (jsherril@redhat.com)
- adding newline to error message output (jsherril@redhat.com)
- fixing small method call in reposync (jsherril@redhat.com)
- fixing specfile to create directory for reposync (jsherril@redhat.com)
- fixing small whitespace error with reposync (jsherril@redhat.com)
- adding better logging for spacewalk-repo-sync (jsherril@redhat.com)
- 467281 - Instead of checksing for the start now we cechk if tools is in the
  channel label. This is not a perfect solution but atleast covers few more
  cases. An ideal solution would be to add some kind of a relation ship between
  parent and child signifying that this is a tools channel for a given parent.
  (pkilambi@redhat.com)
- 505559 - spacewalk-debug now captures database tablespace usage report
  (pkilambi@redhat.com)
- making the logging a bit cleaner (jsherril@redhat.com)
- fixing some import things to actually work on an installed system
  (jsherril@redhat.com)
- adding logging, cache clearing, and a few fixes to reposync
  (jsherril@redhat.com)
- adding makefile to repo_plugins (pkilambi@redhat.com)
- updating spacewalk backend spec file with reposync stuff
  (pkilambi@redhat.com)
- updating Makefile with reposync files (pkilambi@redhat.com)
- some clean up on repo sync stuff (pkilambi@redhat.com)
- adding repo sync task and other UI bits for spacewalk repo sync
  (jsherril@redhat.com)
- backend/satellite_tools/repo_plugins/yum_src.py (jsherril@redhat.com)

* Wed Jul 29 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.28-1
- 

* Mon Jul 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.27-1
- Fix rhnSQL pgsql driver when sql not provided to Cursor class.
  (dgoodwin@redhat.com)
- Replace Oracle blob update syntax with our rhnSQL wrapper.
  (dgoodwin@redhat.com)
- Add missing cursor method to pgsql rhnsql driver. (dgoodwin@redhat.com)
- Minor pgsql query fix in satCerts.py. (dgoodwin@redhat.com)
- Modify rhn-ssl-dbstore script to not be Oracle specific.
  (dgoodwin@redhat.com)
- Postgresql query fix. (dgoodwin@redhat.com)
- Remove unused query in sync_handlers.py. (dgoodwin@redhat.com)
- Add "as" to query to work with both databases. (dgoodwin@redhat.com)
- Fix Oracle specific setDateFormat call in backend.py. (dgoodwin@redhat.com)
- Change Oracle nextval to sequence_nextval. (dgoodwin@redhat.com)
- Convert Oracle sequence.nextval's to use nextval compatability function.
  (dgoodwin@redhat.com)
- Add rhnSQL Cursor update_blob function. (dgoodwin@redhat.com)
- Change satCerts.py query to be more clear. (dgoodwin@redhat.com)
- Convert unicode Python strings into strings for PostgreSQL.
  (dgoodwin@redhat.com)
- Remove type mapping code from PostgreSQL rhnSQL driver. (dgoodwin@redhat.com)
- Purge munge_args insanity from PostgreSQL rhnSQL driver.
  (dgoodwin@redhat.com)
- Adjust satCerts.py query to work with both databases. (dgoodwin@redhat.com)
- Fix some rhnSQL error reporting for PostgreSQL. (dgoodwin@redhat.com)
- Fix bug in rhnSQL PostgreSQL named -> positional argument conversion.
  (dgoodwin@redhat.com)
- Initial rhnSQL PostgreSQL Procedure implementation. (dgoodwin@redhat.com)
- Modify rhn-satellite-activate to communicate with PostgreSQL.
  (dgoodwin@redhat.com)
- rhnSQL: Adjust and comment out some PostgreSQL Procedure code.
  (dgoodwin@redhat.com)
- Add support for calling PostgreSQL stored procedures with rhnSQL.
  (dgoodwin@dangerouslyinc.com)
- Implement rhnSQL Cursor.execute_bulk for PostgreSQL.
  (dgoodwin@dangerouslyinc.com)

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 0.6.26-1
- 513073 - Fix rhnpush of packages with duplicate requires.
  (dgoodwin@redhat.com)

* Fri Jul 24 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.25-1
- 513652 - Dumping the debug level so the info shows up only with --debug flag.
  (pkilambi@redhat.com)
- 513435 - WebUI creates these for us at the org creation time. So dont try to
  insert those at the sync time as ui is not smart enough to check if exists
  before inserting a row. (pkilambi@redhat.com)

* Fri Jul 24 2009 Jan Pazdziora 0.6.24-1
- add spacewalk-report script and inventory report.

* Thu Jul 23 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.23-1
- 513432, 513435 : Our channel family import is written such that we compare
  and resync the red hat channel families. But in iss case we can have provate
  channel family ties to a channel ebing imported that will not match whats on
  the slave as slaves default to org 1. This fix should only post process the
  channel families if its a non custom one. (pkilambi@redhat.com)
- reporting: add report option for listing fields for report.
  (jpazdziora@redhat.com)
- reporting: after having parsed the common options, put the rest back to
  sys.argv. (jpazdziora@redhat.com)
- reporting: show error message when unknown report is specified.
  (jpazdziora@redhat.com)
- reporting: change structure of the report definition file to also include
  column names. (jpazdziora@redhat.com)
- reporting: add channel(s) to which the server is registered.
  (jpazdziora@redhat.com)
- reporting: add number of out-of-date packages and errata.
  (jpazdziora@redhat.com)
- reporting: add kernel version to the report. (jpazdziora@redhat.com)
- reporting: when report name is not specified on the command line, show list
  of available reports. (jpazdziora@redhat.com)
- reporting: move the SQL to definition file, to allow for multiple reports.
  (jpazdziora@redhat.com)
- reporting: add registration time and last check-in time.
  (jpazdziora@redhat.com)
- reporting: add the registered by information. (jpazdziora@redhat.com)
- reporting: add hostname and IP address to the report. (jpazdziora@redhat.com)
- reporting: output field names as the first row. (jpazdziora@redhat.com)
- reporting: output formatted as csv. (jpazdziora@redhat.com)
- reporting: initial prepare, execute, and fetch loop. (jpazdziora@redhat.com)
- reporting: add spacewalk-report to the rpm package. (jpazdziora@redhat.com)
- reporting: a stub for new script, spacewalk-report. (jpazdziora@redhat.com)

* Wed Jul 22 2009 John Matthews <jmatthew@redhat.com> 0.6.22-1
- 511283 - Package compare between db and cache should see if the db is newer
  than cache and only then import the content. (pkilambi@redhat.com)

* Tue Jul 21 2009 John Matthews <jmatthew@redhat.com> 0.6.21-1
- 512936 - Changing the custom channel rule to always defalt to org 1 for
  custom channels unless --org option is used. This will avoid the confusion of
  putting the channel is some random org on slaves. (pkilambi@redhat.com)

* Tue Jul 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.20-1
- 512960 - check for the proper attr name on rpm for header reading
  (jbowes@redhat.com)

* Thu Jul 16 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.19-1
- 512236 - the org id checks were defaulting to None in custom channel cases
  instead of 1. Also the metadata sting frommaster is a string None so we need
  to check for the string. This should fix both custom and null org content in
  iss case. hosted syncs should work as usual. (pkilambi@redhat.com)
- Return config channels sorted highest to lowest priority.
  (dgoodwin@redhat.com)
- 511116 - changing updatePackages to change the permissions on the kickstart
  trees in the same way we do for packages within /var/satellite
  (jsherril@redhat.com)

* Fri Jul 10 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.6.18-1
- If not commandline options given, compare the erratum channels to the already
  imported ones (pkilambi@redhat.com)
- If not commandline options given, compare the erratum channels to the already
  imported ones (pkilambi@redhat.com)
- compute the channel filtering only if a channel is specified in the
  commandline. If not, use the default (pkilambi@redhat.com)

* Thu Jul 09 2009 John Matthews <jmatthew@redhat.com> 0.6.17-1
- Only include the channels that are being synced to each errata. This will
  help taskomatic not spam users with irrelevant errata mails
  (pkilambi@redhat.com)

* Fri Jul  3 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.16-1
- 509516 - failure to check for non-existant header (Mark Chappell <m.d.chappell@bath.ac.uk>)
- 509444 - remove delete action system from virt page (Shannon Hughes <shughes@redhat.com>)
- 509371 - SSM->Install,Remove,Verify - minor fixes to Package Name and Arch (Brad Buckingham <bbuckingham@redhat.com>)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.6.15-1
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- 499723 - accept follow-redirects with value greater then 2
  (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- 507867 - Schedule repo gen once the channel package associations is complete
  (pkilambi@redhat.com)
- 505680 - channel_product_id is computed based on the name, product and
  version so it will not match the cache as cache is always None. Also dont
  update the channel_product_id uless the id is different from whats being
  updated (pkilambi@redhat.com)
- Update HACKING file for backend test instructions. (dgoodwin@redhat.com)
- Integrate some PostgreSQL rhnSQL driver unit tests. (dgoodwin@redhat.com)
- First cut of a unit test framework for Python backend. (dgoodwin@redhat.com)
- 507593 - fixing eus registration tracebacks (pkilambi@redhat.com)
- Adding repodata details for a given channel to channelDetails page.
  (pkilambi@redhat.com)
- Revert "503090 - Exclude rhnlib from kickstart profile sync."
  (dgoodwin@redhat.com)
- remove short package dependency on rpms. User might wanna skip the rpms and
  still import metadata. (pkilambi@redhat.com)
- 422611 - Warn that satrm.py is not a supported script. (dgoodwin@redhat.com)
- fixing the unsubscriptable object error when package is not yet in rhnPackage
  table (pkilambi@redhat.com)
- 506264 - This commit includes: (pkilambi@redhat.com)
- 505680 - When satsync tries to do an import it compares whats in cache to db
  and tries to import only new content, but since the last_modified date always
  differ we end up updating the rhnChannel table even when there is nothing to
  sync. Adding last_modified to ignore keys list so that we dont decide the
  diff based on this field. We still continue to compare the rest of the
  fields. (pkilambi@redhat.com)
- 495790 - force uploading a package ends up with duplicate entries in
  rhnPackage table. This is because we use md5sum along with name, evr, package
  arch and org as a primary key while deciding whether to perform an insert or
  an update. Since the solaris packages had same nvrea and org and different
  md5 sums it was doing an insert instead of update on the existing row. Fixed
  the schema wrapper to only use md5sum as a primary key if nvrea feature is
  enabled. Also fixed the package uniquifies to use md5sum only for nvrea.
  (pkilambi@redhat.com)
- Catch the systemExit and preserve the error code. Also fixing the traceback
  issue when db is not accessible (pkilambi@redhat.com)
- removing bugzilla handler specific tests (pkilambi@redhat.com)
- 502581 - splitting the data to smaller chunks to please cx_oracle to avoid
  throwing array too big errors (pkilambi@redhat.com)
- 503090 - Exclude rhnlib from kickstart profile sync. (dgoodwin@redhat.com)

* Fri Jun 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.11-1
- fixing duplicate entries in repogen tables and other clean aup
  (pkilambi@redhat.com)
- add rhn-db-stats manual page (mzazrivec@redhat.com)
- allow rhn-db-stats to write to arbitrary location with running selinux
  (mzazrivec@redhat.com)
- Fixes to support mod_jk >= 2.2.26. (dgoodwin@redhat.com)
- 503243 - Dropping the is_default column as we now determine the default in
  the app code based on the compatible eus channel instead of jus the default.
  (pkilambi@redhat.com)
- Show all available eus channels during registration (jbowes@redhat.com)
- removing some unused hosted stuff (pkilambi@redhat.com)
- removing leftover code after a removed query (jsherril@redhat.com)
- 498517 fixing the error message to show the needed free entitlements for the
  activation to proceed (pkilambi@redhat.com)
- 502060 - The uniquify filter for deps is causing missing deps in repodata gen
  as we should be looking into the name + version instead of just name. Also
  since the f10+ rpms have issues with only duplicate provides, lets process
  the rest of the capabilities. (pkilambi@redhat.com)

* Wed May 27 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.10-1
- 309601 - removing md5crypt from spacewalk-backend-tools
  (bbuckingham@redhat.com)

* Wed May 27 2009 Jan Pazdziora 0.6.9-1
- spacewalk-backend: add command-line utility spacewalk-cfg-get to
  print config values

* Tue May 26 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.7-1
- fixing the keyError as we should be using smbios.system.uuid
  (pkilambi@redhat.com)
- 495778 - process UTF-8 input. (jpazdziora@redhat.com)
- 491831 - fix detection if monitoring is enabled (msuchy@redhat.com)
- make variables attributes of instance and not class itself
  (msuchy@redhat.com)
- change comments to docstrings (msuchy@redhat.com)
- make attributes real attributes and not global variables (msuchy@redhat.com)

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.6-1
- 485698 - manual page: fix --db option syntax (mzazrivec@redhat.com)
- 469219 - Adding the permissions ability to our caching mechanism. (pkilambi@redhat.com)
- simplifying the previos commit even more. All we need to check here is if the
  hostename is in the allowed list or not. Jus this one line should accomplish
  that (pkilambi@redhat.com)
- list.pop is causing some unexpected behavior causing to retain the popped
  list in memory and failing the subsequent compares as the list is not being
  garbage collected looks like. very weird behavior and causes the slave check
  ins to fail with ISS not allowed errors. This should resolve the issue as we
  dont modify the list object in place (pkilambi@redhat.com)
- 500168 - fixed virt guest install was marked complete when it was not (jsherril@redhat.com)
- 486526 - use getent instead of grep /etc/{passwd|group} (mzazrivec@redhat.com)
- 439042 - Another pass at conveying a better error message (pkilambi@redhat.com)
- 499560 - sysexit trap is overriding the error codes returned by the
  businesslogic with 0. removing the catch so the exit codes propogate all the
  way through when exporter fails. (pkilambi@redhat.com)
- 477703 - Adding the size limit changes to disk dumper as well (pkilambi@redhat.com)
- 477703 - Porting changes from hosted to limit the size of the data being
  exported slave satellite is pulling content from master (pkilambi@redhat.com)
- Basic support for detecting a KVM/QEMU guest on registration (jbowes@redhat.com)

* Mon May 11 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.5-1
- 309601 - updating satpasswd/satwho to pull db info from rhn.conf
  (bbuckingham@redhat.com)
* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.4-1
- 498273 - removing incorrect index busting package list updates for custom
  base channels (shughes@redhat.com)
- 1000010021 - fixing issue where you could not remove packages from rhel 4
  systems (jsherril@redhat.com)
- 497871 - fixing issue where guest provisioning would show as succesfull even
  when it had failed (jsherril@redhat.com)
- 486526 - put db creation / upgrade logs into spacewalk-debug
  (mzazrivec@redhat.com)
- 486526 - put dump files from embedded db into spacewalk-debug
  (mzazrivec@redhat.com)
- 486526 - put audit.log into spacewalk-debug (mzazrivec@redhat.com)
- 486526 - put schema upgrade logs into spacewalk-debug (mzazrivec@redhat.com)
- 492903 - fixing the sql fetch (pkilambi@redhat.com)

* Fri Apr 24 2009 Brad Buckingham <bbuckingham@redhat.com> 0.6.3-1
- 309601 - adding satpasswd, satwho and md5crypt to spacewalk-backend-tools

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.2-1
- 494976 - adding cobbler systme record name usage to reprovisioning
  (jsherril@redhat.com)
- 443500 - Changed logic to determine packages to remove to include the
  server's current package information. (jason.dobies@redhat.com)
- When a new system is registered it will notify search service
  (jmatthew@redhat.com)

* Fri Apr 17 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- 439042 - fixing the not enough entitlements error to more descriptive.
  (pkilambi@redhat.com)
- 495928 - adding cobbler collection to spacewalk-debug (jsherril@redhat.com)
- moving migrate-system-profile to spacewalk-utils package
  (pkilambi@redhat.com)
- 492903 - fix the query to include the privatechannelfamily org into
  rhnprivatecahnnelfamily (pkilambi@redhat.com)
- 495396 - let the commandline ca-cert option override the cert when using in
  conjunction with iss (pkilambi@redhat.com)
- 494982 - fixing the error message to not take extra strings cusing parse
  errors (pkilambi@redhat.com)
- 486526 - display the created and modified information in ISO format.
  (jpazdziora@redhat.com)
- 486526 - add history of schema upgrades to spacewalk-debug
  (mzazrivec@redhat.com)
- 149695 - Including channel_id as part of rhnErrataQueue table so that
  taskomatic can send errata notifications based on channel_id instead of
  sending to everyone subscribed to the channel. The changes include db change
  to rhnErrataQueue table and backend change to satellite-sync's errata import.
  (pkilambi@redhat.com)
- 485870 - only recalculate the channel family counts once per family.
  (mmccune@gmail.com)
- 488062 - fixing the activation to be more careful in checking the integrity
  of variables before assigning slots (pkilambi@redhat.com)
- 494968 - typo in config comment (pkilambi@redhat.com)
- 494593 - fixing the repofile compare to use the right type for java date
  object obtained through hibernate (pkilambi@redhat.com)
- bumping the protocol version on exporter (pkilambi@redhat.com)
- 491668 - update Spacewalk Apache conf to support .htaccess
  (bbuckingham@redhat.com)
- 486526 - store alert.log into the database/ directory.
  (jpazdziora@redhat.com)
- 486526 - renaming directory for database-related stuff, we will want to store
  alert.log here as well. (jpazdziora@redhat.com)
- check the attr instead of try catch (pkilambi@redhat.com)
- 493583 - fixing the rhnpush to call old rpm libraries for RHEL-4
  (pkilambi@redhat.com)
- adding some additional checks before creating first org info
  (pkilambi@redhat.com)
- bump Versions to 0.6.0 (jesusr@redhat.com)
- minor default args clean up (pkilambi@redhat.com)
- Fixing the first org creation to check for ChannelFamily existance and create
  row if missing so the channel shows up in channels tab on sync
  (pkilambi@redhat.com)

* Fri Apr 17 2009 Pradeep Kilambi <pkilambi@redhat.com>
- move the migrate systems script to utils package

* Mon Mar 30 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.28-1
- 485698 - rhn-satellite-exporter manual page fixes

* Thu Mar 26 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.27-1
- 486526 - additional system files and db statistics included into spacewalk-debug archive

* Wed Mar 25 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.26-1
- 487621 - Fix segfaults rhnpush has been causing server-side on Fedora 10.
- Fix Oracle exception handling in procedure calls.
- 485529 - Fix to handle empty or missing ip_addr on a disabled interface.
- 482830 - Fix rpm fetch to include the xml-dump-version in httpd headers during GET requests.
- 483811 - Fix orgid based sync logic.
- 480252 - Raise meaningful exception instead of traceback on Oracle column size error.

* Thu Mar 19 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.25-1
- 468686 - restricts deactivated accounts from registering systems and managing systems. 
- 485532 - Adding the overriding config values for apachec process sizelimit issue

* Wed Mar 18 2009 Mike McCune <mmccune@gmail.com> 0.5.23-1
- 486186 - Update spacewalk spec files to require cobbler >= 1.4.3

* Fri Mar 13 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.22-1
- 484879 - warn if you are connection using ISS to parent which do not know ISS

* Wed Mar 11 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.21-1
- 483802 - remove conflicts between spacewalk-proxy-common and spacewalk-config
- 209620 - satellite-debug creates world readable output
- 479439 - adding better message when trying to downgrade entitelments
- 481236 - making package downloads work for http
- 485875 - fixing missing man page options and removed deprecated ones for satsync

* Fri Mar 06 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.20-1
- Add missing dependency on PyPAM.

* Thu Mar 05 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.19-1
- 488753 - Adding nevra support to satsync

* Tue Mar 03 2009 Dave Parker <dparker@redhat.com> 0.5.18-1
- 483802 - Directory /etc/rhn owned by two packages, group does not match

* Fri Feb 27 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.17-1
- rebuild

* Thu Feb 26 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.15-1
- 430634 - fixing the profile sync code to include arch info

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.15-1
- 430634 - support kickstart profile to compare profiles by arch
- 487238 - spacewalk-debug not working, doesnt actually write the tar file

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.14-1
- 209620 - satellite-debug creates world readable output

* Sat Feb 21 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.13-1
- Fix rpm-python hdr installation error on Fedora 10.

* Fri Feb 20 2009 Miroslav Suchy <msuchy@redhat.com> 0.5.12-1
- fixing run time error of satsync

* Thu Feb 19 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.11-1
- 480903 - fix for fcntl locking to use flock when IOError's
- 461672 - fixing satsync --no-rpms to only skip rpms

* Wed Feb 18 2009 Dave Parker <dparker@redhat.com> 0.5.9-1
- 486186 - Update spacewalk spec files to require cobbler >= 1.4.2

* Wed Feb 18 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.8-1
- Resolves: bz#446289 - create the private channel family at 
  org creation time

* Mon Feb 16 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.7-1
- yum repodata regen support through taskomatic

* Thu Feb 12 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.6-1
- move logs from /var/tmp to /var/log/nocpulse

* Tue Feb 10 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.5.5-1
- bz#368711 bz#480063

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

