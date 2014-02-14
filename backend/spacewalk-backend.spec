%global rhnroot %{_prefix}/share/rhn
%global rhnconfigdefaults %{rhnroot}/config-defaults
%global rhnconf %{_sysconfdir}/rhn
%global apacheconfd %{_sysconfdir}/httpd/conf.d
%if 0%{?rhel} && 0%{?rhel} < 6
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%endif
%global pythonrhnroot %{python_sitelib}/spacewalk

Name: spacewalk-backend
Summary: Common programs needed to be installed on the Spacewalk servers/proxies
Group: Applications/Internet
License: GPLv2
Version: 2.1.50
Release: 1%{?dist}
URL:       https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Requires: python, rpm-python
# /etc/rhn is provided by spacewalk-proxy-common or by spacewalk-config
Requires: /etc/rhn
Requires: rhnlib >= 2.5.57
# for Debian support
Requires: python-debian
Requires: %{name}-libs >= 1.1.16-1
BuildRequires: /usr/bin/msgfmt
BuildRequires: /usr/bin/docbook2man
BuildRequires: docbook-utils
%if 0%{?fedora} > 15 || 0%{?rhel} > 5
BuildRequires: spacewalk-pylint
BuildRequires: rhnlib >= 2.5.57
BuildRequires: rpm-python
BuildRequires: python-crypto
BuildRequires: python-debian
%endif
Requires(pre): httpd
Requires: httpd
# we don't really want to require this redhat-release, so we protect
# against installations on other releases using conflicts...
Obsoletes: rhns-common < 5.3.0
Obsoletes: rhns < 5.3.0
Provides: rhns = 1:%{version}-%{release}
Provides: rhns-common = 1:%{version}-%{release}
Obsoletes: spacewalk-backend-upload-server < 1.2.28
Provides: spacewalk-backend-upload-server = 1:%{version}-%{release}

%description 
Generic program files needed by the Spacewalk server machines.
This package includes the common code required by all servers/proxies.

%package sql
Summary: Core functions providing SQL connectivity for the RHN backend modules
Group: Applications/Internet
Requires(pre): %{name} = %{version}-%{release}
Requires: %{name} = %{version}-%{release}
Obsoletes: rhns-sql < 5.3.0
Provides: rhns-sql = 1:%{version}-%{release}
Requires: %{name}-sql-virtual = %{version}-%{release}

%description sql
This package contains the basic code that provides SQL connectivity for
the Spacewalk backend modules.

%package sql-oracle
Summary: Oracle backend for Spacewalk
Group: Applications/Internet
Requires: python(:DBAPI:oracle)
Provides: %{name}-sql-virtual = %{version}-%{release}

%description sql-oracle
This package contains provides Oracle connectivity for the Spacewalk backend
modules.

%package sql-postgresql
Summary: Postgresql backend for Spacewalk
Group: Applications/Internet
Requires: python-psycopg2 >= 2.0.14-2
Provides: %{name}-sql-virtual = %{version}-%{release}

%description sql-postgresql
This package contains provides PostgreSQL connectivity for the Spacewalk
backend modules.

%package server
Summary: Basic code that provides RHN Server functionality
Group: Applications/Internet
Requires(pre): %{name}-sql = %{version}-%{release}
Requires: %{name}-sql = %{version}-%{release}
Requires: PyPAM
Obsoletes: rhns-server < 5.3.0
Provides: rhns-server = 1:%{version}-%{release}

#this exists only on rhel5 and rhel6
Conflicts: python-sgmlop
# cobbler-web is known to break our configuration
Conflicts: cobbler-web

Requires: mod_wsgi


%description server
This package contains the basic code that provides server/backend
functionality for a variety of XML-RPC receivers. The architecture is
modular so that you can plug/install additional modules for XML-RPC
receivers and get them enabled automatically.

%package xmlrpc
Summary: Handler for /XMLRPC
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-xmlrpc < 5.3.0
Obsoletes: rhns-xmlrpc < 5.3.0
Provides: rhns-server-xmlrpc = 1:%{version}-%{release}
Provides: rhns-xmlrpc = 1:%{version}-%{release}

%description xmlrpc
These are the files required for running the /XMLRPC handler, which
provide the basic support for the registration client (rhn_register)
and the up2date clients.

%package applet
Summary: Handler for /APPLET
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-applet < 5.3.0
Provides: rhns-applet = 1:%{version}-%{release}

%description applet
These are the files required for running the /APPLET handler, which
provides the functions for the RHN applet.

%package app
Summary: Handler for /APP
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-server-app < 5.3.0
Obsoletes: rhns-app < 5.3.0
Provides: rhns-server-app = 1:%{version}-%{release}
Provides: rhns-app = 1:%{version}-%{release}
Obsoletes: spacewalk-backend-xp < 1.8.38
Provides: spacewalk-backend-xp = %{version}-%{release}
Obsoletes: rhns-server-xp < 5.3.0
Obsoletes: rhns-xp < 5.3.0
Provides: rhns-server-xp = 1:%{version}-%{release}
Provides: rhns-xp = 1:%{version}-%{release}

%description app
These are the files required for running the /APP handler.
Calls to /APP are used by internal maintenance tools (rhnpush).

%package iss
Summary: Handler for /SAT
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-sat < 5.3.0
Provides: rhns-sat = 1:%{version}-%{release}

%description iss
%{name} contains the basic code that provides server/backend
functionality for a variety of XML-RPC receivers. The architecture is
modular so that you can plug/install additional modules for XML-RPC
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
modular so that you can plug/install additional modules for XML-RPC
receivers and get them enabled automatically.

This package contains listener for the Server XML dumper.

%package libs
Summary: Spacewalk server and client tools libraries
Group: Applications/Internet
BuildRequires: python2-devel
Conflicts: %{name} < 1.7.0
Requires: python-hashlib
BuildRequires: python-hashlib

%description libs
Libraries required by both Spacewalk server and Spacewalk client tools.

%package config-files-common
Summary: Common files for the Configuration Management project
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-config-files-common < 5.3.0
Provides: rhns-config-files-common = 1:%{version}-%{release}

%description config-files-common
Common files required by the Configuration Management project

%package config-files
Summary: Handler for /CONFIG-MANAGEMENT
Group: Applications/Internet
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files < 5.3.0
Provides: rhns-config-files = 1:%{version}-%{release}

%description config-files
This package contains the server-side code for configuration management.

%package config-files-tool
Summary: Handler for /CONFIG-MANAGEMENT-TOOL
Group: Applications/Internet
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files-tool < 5.3.0
Provides: rhns-config-files-tool = 1:%{version}-%{release}

%description config-files-tool
This package contains the server-side code for configuration management tool.

%package package-push-server
Summary: Listener for rhnpush (non-XMLRPC version)
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-package-push-server < 5.3.0
Provides: rhns-package-push-server = 1:%{version}-%{release}

%description package-push-server
Listener for rhnpush (non-XMLRPC version)

%package tools
Summary: Spacewalk Services Tools
Group: Applications/Internet
Requires: %{name}-xmlrpc = %{version}-%{release}
Requires: %{name}-app = %{version}-%{release}
Requires: %{name}
Requires: spacewalk-certs-tools
Requires: spacewalk-admin >= 0.1.1-0
Requires: python-gzipstream
Requires: python-hashlib
Requires: mod_ssl
Requires: %{name}-xml-export-libs
Requires: cobbler >= 2.0.0
Requires: rhnlib  >= 2.5.57
Obsoletes: rhns-satellite-tools < 5.3.0
Obsoletes: spacewalk-backend-satellite-tools <= 0.2.7
Provides: spacewalk-backend-satellite-tools = %{version}-%{release}
Provides: rhns-satellite-tools = 1:%{version}-%{release}

%description tools
Various utilities for the Spacewalk Server.

%package xml-export-libs
Summary: Spacewalk XML data exporter
Group: Applications/Internet
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-xml-export-libs < 5.3.0
Provides: rhns-xml-export-libs = 1:%{version}-%{release}

%description xml-export-libs
Libraries required by various exporting tools

%prep
%setup -q

%build
make -f Makefile.backend all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{rhnroot}
install -d $RPM_BUILD_ROOT%{pythonrhnroot}
make -f Makefile.backend install PREFIX=$RPM_BUILD_ROOT \
    MANDIR=%{_mandir}
export PYTHON_MODULE_NAME=%{name}
export PYTHON_MODULE_VERSION=%{version}

%find_lang %{name}-server

%if 0%{?fedora} || 0%{?rhel} > 6
sed -i 's/#LOGROTATE-3.8#//' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/spacewalk-backend-*
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%check
make -f Makefile.backend PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib} test || :

%if 0%{?fedora} > 15 || 0%{?rhel} > 5
# check coding style
export PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib}:/usr/lib/rhn
spacewalk-pylint $RPM_BUILD_ROOT%{pythonrhnroot}/common \
                 $RPM_BUILD_ROOT%{pythonrhnroot}/satellite_exporter \
                 $RPM_BUILD_ROOT%{pythonrhnroot}/upload_server \
                 $RPM_BUILD_ROOT%{pythonrhnroot}/wsgi
%endif

%pre server
OLD_SECRET_FILE=%{_var}/www/rhns/server/secret/rhnSecret.py
if [ -f $OLD_SECRET_FILE ]; then
    install -d -m 750 -o root -g apache %{rhnconf}
    mv ${OLD_SECRET_FILE}*  %{rhnconf}
fi

%post server
# Is secret key in our config file?
regex="^[[:space:]]*(server\.|)secret_key[[:space:]]*=.*$"

if grep -E -i $regex %{rhnconf}/rhn.conf > /dev/null 2>&1 ; then
    # secret key already there
    rm -f %{rhnconf}/rhnSecret.py*
    exit 0
fi
    
# Generate a secret key if old one is not present
if [ -f %{rhnconf}/rhnSecret.py ]; then
    secret_key=$(PYTHONPATH=%{rhnconf} %{__python} -c \
        "from rhnSecret import SECRET_KEY; print SECRET_KEY")
else
    secret_key=$(dd if=/dev/urandom bs=1024 count=1 2>/dev/null | sha1sum - | 
        awk '{print $1}')
fi

echo "server.secret_key = $secret_key" >> %{rhnconf}/rhn.conf
rm -f %{rhnconf}/rhnSecret.py*

%files
%doc LICENSE
%dir %{pythonrhnroot}
%dir %{pythonrhnroot}/common
%{pythonrhnroot}/common/apache.py*
%{pythonrhnroot}/common/byterange.py*
%{pythonrhnroot}/common/rhnApache.py*
%{pythonrhnroot}/common/rhnCache.py*
%{pythonrhnroot}/common/rhnConfig.py*
%{pythonrhnroot}/common/rhnException.py*
%{pythonrhnroot}/common/rhnFlags.py*
%{pythonrhnroot}/common/rhnLib.py*
%{pythonrhnroot}/common/rhnLog.py*
%{pythonrhnroot}/common/rhnMail.py*
%{pythonrhnroot}/common/rhnTB.py*
%{pythonrhnroot}/common/rhnRepository.py*
%{pythonrhnroot}/common/rhnTranslate.py*
%{pythonrhnroot}/common/RPC_Base.py*
%attr(770,root,apache) %dir %{_var}/log/rhn
# config files
%attr(755,root,apache) %dir %{rhnconfigdefaults}
%attr(644,root,apache) %{rhnconfigdefaults}/rhn.conf
%attr(755,root,root) %{_bindir}/spacewalk-cfg-get
%{_mandir}/man8/spacewalk-cfg-get.8.gz
# wsgi stuff
%dir %{rhnroot}/wsgi
%{rhnroot}/wsgi/__init__.py*
%{rhnroot}/wsgi/wsgiHandler.py*
%{rhnroot}/wsgi/wsgiRequest.py*

%files sql
%doc LICENSE
# Need __init__ = share it with rhns-server
%dir %{pythonrhnroot}/server
%{pythonrhnroot}/server/__init__.py*
%{rhnroot}/server/__init__.py*
%dir %{pythonrhnroot}/server/rhnSQL
%{pythonrhnroot}/server/rhnSQL/const.py*
%{pythonrhnroot}/server/rhnSQL/dbi.py*
%{pythonrhnroot}/server/rhnSQL/__init__.py*
%{pythonrhnroot}/server/rhnSQL/sql_*.py*

%files sql-oracle
%doc LICENSE
%{pythonrhnroot}/server/rhnSQL/driver_cx_Oracle.py*

%files sql-postgresql
%doc LICENSE
%{pythonrhnroot}/server/rhnSQL/driver_postgresql.py*

%files server -f %{name}-server.lang
%doc LICENSE
# modules
%{pythonrhnroot}/server/apacheAuth.py*
%{pythonrhnroot}/server/apacheHandler.py*
%{pythonrhnroot}/server/apacheRequest.py*
%{pythonrhnroot}/server/apacheServer.py*
%{pythonrhnroot}/server/apacheUploadServer.py*
%{pythonrhnroot}/server/rhnAction.py*
%{pythonrhnroot}/server/rhnAuthPAM.py*
%{pythonrhnroot}/server/rhnCapability.py*
%{pythonrhnroot}/server/rhnChannel.py*
%{pythonrhnroot}/server/rhnDependency.py*
%{pythonrhnroot}/server/rhnPackage.py*
%{pythonrhnroot}/server/rhnPackageUpload.py*
%{pythonrhnroot}/server/basePackageUpload.py*
%{pythonrhnroot}/server/rhnHandler.py*
%{pythonrhnroot}/server/rhnImport.py*
%{pythonrhnroot}/server/rhnLib.py*
%{pythonrhnroot}/server/rhnMapping.py*
%{pythonrhnroot}/server/rhnRepository.py*
%{pythonrhnroot}/server/rhnSession.py*
%{pythonrhnroot}/server/rhnUser.py*
%{pythonrhnroot}/server/rhnVirtualization.py*
%{pythonrhnroot}/server/taskomatic.py*
%dir %{pythonrhnroot}/server/rhnServer
%{pythonrhnroot}/server/rhnServer/*
%dir %{pythonrhnroot}/server/importlib
%{pythonrhnroot}/server/importlib/__init__.py*
%{pythonrhnroot}/server/importlib/archImport.py*
%{pythonrhnroot}/server/importlib/backend.py*
%{pythonrhnroot}/server/importlib/backendLib.py*
%{pythonrhnroot}/server/importlib/backendOracle.py*
%{pythonrhnroot}/server/importlib/backend_checker.py*
%{pythonrhnroot}/server/importlib/channelImport.py*
%{pythonrhnroot}/server/importlib/debPackage.py*
%{pythonrhnroot}/server/importlib/errataCache.py*
%{pythonrhnroot}/server/importlib/errataImport.py*
%{pythonrhnroot}/server/importlib/headerSource.py*
%{pythonrhnroot}/server/importlib/importLib.py*
%{pythonrhnroot}/server/importlib/kickstartImport.py*
%{pythonrhnroot}/server/importlib/mpmSource.py*
%{pythonrhnroot}/server/importlib/packageImport.py*
%{pythonrhnroot}/server/importlib/packageUpload.py*
%{pythonrhnroot}/server/importlib/productNamesImport.py*
%{pythonrhnroot}/server/importlib/userAuth.py*
%{pythonrhnroot}/server/importlib/orgImport.py*
%{rhnroot}/server/handlers/__init__.py*

# Repomd stuff
%dir %{pythonrhnroot}/server/repomd
%{pythonrhnroot}/server/repomd/__init__.py*
%{pythonrhnroot}/server/repomd/domain.py*
%{pythonrhnroot}/server/repomd/mapper.py*
%{pythonrhnroot}/server/repomd/repository.py*
%{pythonrhnroot}/server/repomd/view.py*

# the cache
%attr(755,apache,apache) %dir %{_var}/cache/rhn
# config files
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server.conf
# main httpd config
%attr(644,root,apache) %config %{apacheconfd}/zz-spacewalk-server.conf

# wsgi stuff
%attr(644,root,apache) %config %{apacheconfd}/zz-spacewalk-server-wsgi.conf
%{rhnroot}/wsgi/app.py*
%{rhnroot}/wsgi/applet.py*
%{rhnroot}/wsgi/config.py*
%{rhnroot}/wsgi/config_tool.py*
%{rhnroot}/wsgi/package_push.py*
%{rhnroot}/wsgi/sat.py*
%{rhnroot}/wsgi/sat_dump.py*
%{rhnroot}/wsgi/xmlrpc.py*

# logs and other stuff
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-server

%files xmlrpc
%doc LICENSE
%dir %{rhnroot}/server/handlers/xmlrpc
%{rhnroot}/server/handlers/xmlrpc/*
%dir %{pythonrhnroot}/server/action
%{pythonrhnroot}/server/action/*
%dir %{pythonrhnroot}/server/action_extra_data
%{pythonrhnroot}/server/action_extra_data/*
# config files
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_xmlrpc.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-xmlrpc

%files applet
%doc LICENSE
%dir %{rhnroot}/server/handlers/applet
%{rhnroot}/server/handlers/applet/*
# config files
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_applet.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-applet

%files app
%doc LICENSE
%dir %{rhnroot}/server/handlers/app
%{rhnroot}/server/handlers/app/*
# config files
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_app.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-app

%files iss
%doc LICENSE
%dir %{rhnroot}/server/handlers/sat
%{rhnroot}/server/handlers/sat/*
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-iss

%files iss-export
%doc LICENSE
%dir %{pythonrhnroot}/satellite_exporter
%{pythonrhnroot}/satellite_exporter/__init__.py*
%{pythonrhnroot}/satellite_exporter/satexport.py*

%dir %{rhnroot}/satellite_exporter
%dir %{rhnroot}/satellite_exporter/handlers
%{rhnroot}/satellite_exporter/__init__.py*
%{rhnroot}/satellite_exporter/handlers/__init__.py*
%{rhnroot}/satellite_exporter/handlers/non_auth_dumper.py*
# config files
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-iss-export


%files libs
%doc LICENSE
%{pythonrhnroot}/__init__.py*
%dir %{pythonrhnroot}/common
%{pythonrhnroot}/common/__init__.py*
%{pythonrhnroot}/common/checksum.py*
%{pythonrhnroot}/common/cli.py*
%{pythonrhnroot}/common/fileutils.py*
%{pythonrhnroot}/common/rhn_deb.py*
%{pythonrhnroot}/common/rhn_mpm.py*
%{pythonrhnroot}/common/rhn_pkg.py*
%{pythonrhnroot}/common/rhn_rpm.py*
%{pythonrhnroot}/common/stringutils.py*

%files config-files-common
%doc LICENSE
%{pythonrhnroot}/server/configFilesHandler.py*
%dir %{pythonrhnroot}/server/config_common
%{pythonrhnroot}/server/config_common/*

%files config-files
%doc LICENSE
%dir %{rhnroot}/server/handlers/config
%{rhnroot}/server/handlers/config/*
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_config-management.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-config-files

%files config-files-tool
%doc LICENSE
%dir %{rhnroot}/server/handlers/config_mgmt
%{rhnroot}/server/handlers/config_mgmt/*
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_config-management-tool.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-config-files-tool

%files package-push-server
%doc LICENSE
%dir %{rhnroot}/upload_server
%{rhnroot}/upload_server/__init__.py*
%dir %{rhnroot}/upload_server/handlers
%{rhnroot}/upload_server/handlers/__init__.py*
%{rhnroot}/upload_server/handlers/package_push
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_upload.conf
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_upload_package-push.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-package-push-server

%files tools
%doc LICENSE
%attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_satellite.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-tools
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
%attr(755,root,root) %{_bindir}/satpasswd
%attr(755,root,root) %{_bindir}/satwho
%attr(755,root,root) %{_bindir}/spacewalk-remove-channel*
%attr(755,root,root) %{_bindir}/rhn-entitlement-report
%attr(755,root,root) %{_bindir}/spacewalk-update-signatures
%attr(755,root,root) %{_bindir}/spacewalk-data-fsck
%{pythonrhnroot}/satellite_tools/SequenceServer.py*
%{pythonrhnroot}/satellite_tools/messages.py*
%{pythonrhnroot}/satellite_tools/progress_bar.py*
%{pythonrhnroot}/satellite_tools/req_channels.py*
%{pythonrhnroot}/satellite_tools/satsync.py*
%{pythonrhnroot}/satellite_tools/satCerts.py*
%{pythonrhnroot}/satellite_tools/satComputePkgHeaders.py*
%{pythonrhnroot}/satellite_tools/syncCache.py*
%{pythonrhnroot}/satellite_tools/sync_handlers.py*
%{pythonrhnroot}/satellite_tools/rhn_satellite_activate.py*
%{pythonrhnroot}/satellite_tools/rhn_ssl_dbstore.py*
%{pythonrhnroot}/satellite_tools/xmlWireSource.py*
%{pythonrhnroot}/satellite_tools/updatePackages.py*
%{pythonrhnroot}/satellite_tools/reposync.py*
%{pythonrhnroot}/satellite_tools/constants.py*
%dir %{pythonrhnroot}/satellite_tools/disk_dumper
%{pythonrhnroot}/satellite_tools/disk_dumper/__init__.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss_ui.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss_isos.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss_actions.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/dumper.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/string_buffer.py*
%dir %{pythonrhnroot}/satellite_tools/repo_plugins
%attr(755,root,apache) %dir %{_var}/log/rhn/reposync
%{pythonrhnroot}/satellite_tools/repo_plugins/__init__.py*
%{pythonrhnroot}/satellite_tools/repo_plugins/yum_src.py*
%config %attr(644,root,apache) %{rhnconfigdefaults}/rhn_server_iss.conf
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
%{_mandir}/man8/spacewalk-repo-sync.8*
%{_mandir}/man8/spacewalk-update-signatures.8*
%{_mandir}/man8/update-packages.8*
%{_mandir}/man8/rhn-entitlement-report.8*

%files xml-export-libs
%doc LICENSE
%dir %{pythonrhnroot}/satellite_tools
%{pythonrhnroot}/satellite_tools/__init__.py*
%{pythonrhnroot}/satellite_tools/geniso.py*
# A bunch of modules shared with satellite-tools
%{pythonrhnroot}/satellite_tools/connection.py*
%{pythonrhnroot}/satellite_tools/diskImportLib.py*
%{pythonrhnroot}/satellite_tools/syncLib.py*
%{pythonrhnroot}/satellite_tools/xmlDiskSource.py*
%{pythonrhnroot}/satellite_tools/xmlSource.py*
%dir %{pythonrhnroot}/satellite_tools/exporter
%{pythonrhnroot}/satellite_tools/exporter/__init__.py*
%{pythonrhnroot}/satellite_tools/exporter/exportLib.py*
%{pythonrhnroot}/satellite_tools/exporter/xmlWriter.py*

%changelog
* Fri Feb 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.50-1
- query should not end with semicolon in oracle

* Thu Feb 06 2014 Jan Dobes 2.1.49-1
- 1056515 - adapting to different logrotate version in fedora and rhel
- 870990 - sw-rm-ch -l when satellite-sync runs.

* Wed Feb 05 2014 Aron Parsons <parsonsa@bit-sys.com> 2.1.48-1
- apply exclude filters to dependencies in repo-sync

* Fri Jan 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.47-1
- 1058431 - don't remove files referenced from other distributions/trees
- 1058431 - propagate --skip-kickstart-trees to delete_channels()

* Wed Jan 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.46-1
- fixed man page for spacewalk-remove-channel
- added option to skip kickstart trees removal
- 1058431 - sw-remove-channel does not rm ks trees.

* Fri Jan 24 2014 Stephen Herr <sherr@redhat.com> 2.1.45-1
- 1051658 - Fixing InvalidPackageError when importing from channel dump

* Thu Jan 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.44-1
- 1056659 - commit after updating server's package profile
- Add extra log folder /var/log/rhn/tasko/sat/ in spacewalk-debug.

* Mon Jan 20 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.43-1
- python rhnSQL: proper cleanup after connection error
- fixed python tests

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.42-1
- increase length of rhnCVE name column

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.41-1
- Updating the copyright years info

* Fri Jan 10 2014 Stephen Herr <sherr@redhat.com> 2.1.40-1
- 1051658 - fixing sat-sync daylight-savings-related 'NoneType is
  unsubscriptable' error

* Fri Jan 03 2014 Tomas Lestach <tlestach@redhat.com> 2.1.39-1
- 1043657 - allow 1 character system profile names

* Thu Dec 05 2013 Aron Parsons <aronparsons@gmail.com> 2.1.38-1
- detect RDO instances as QEMU guests

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.37-1
- convert empty uuid to None

* Thu Nov 28 2013 Tomas Lestach <tlestach@redhat.com> 2.1.36-1
- 1010205 - fix displaying of reposync log on WebUI
- python server: better logging of exceptions

* Fri Nov 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.35-1
- 991044 - change python module permissions to rw-r--r--

* Thu Oct 31 2013 Matej Kollar <mkollar@redhat.com> 2.1.34-1
- 1020952 - Single db root cert + option name change

* Tue Oct 29 2013 Matej Kollar <mkollar@redhat.com> 2.1.33-1
- 1020952 - SSL for Postgresql: Backend (Python)
- Simplification
- Simplification: use isinstance
- Various small coding convetions (PEP8)
- Test for None with `is`
- Older Class to newer Instance exceptions
- Small coding conventions
- Change deprecated 'has_key' to 'in'
- Tab vs. Space War

* Tue Oct 22 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.32-1
- fixed table alias
- add support for enhances rpm weak dependencies (backend) (bnc#846436)

* Mon Oct 21 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.31-1
- fixed pylint warnings and errors

* Mon Oct 21 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.30-1
- python oracle tests: better integration with nosetest
- python pgsql driver: behave like the oracle one
- python oracle tests: moved connection settings to configuration file
- python oracle tests: fixed import statements
- removed dead test

* Fri Oct 18 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.29-1
- include stringutils into package
- replace encode/decode with to_string/to_unicode
- 891880 - reuse stringutils functions
- 891880 - make sure we put strings to fd.write()
- 1020910 - use sha1 to compare checksums

* Tue Oct 15 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.28-1
- python pgsql tests: made easier Jenkins integration

* Wed Oct 09 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.27-1
- cleaning up old svn Ids

* Fri Oct 04 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.26-1
- Python pgsql db tests: fix broken test
- Fixed errors inside of the python pgsql test suite.
- Python pgsql driver: handled ProgrammingError exceptions
- Python db tests: moved connection settings to dedicated file
- Fixed script which runs python PostgreSQL tests

* Wed Oct 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.25-1
- 923338 - replace application code with database lookup to prevent conflicting
  inserts

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.24-1
- make pylint 1.0 happy about map/filter on lambda

* Mon Sep 23 2013 Tomas Lestach <tlestach@redhat.com> 2.1.23-1
- Fixing spelling mistakes

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.22-1
- recognize signature used by Oracle
- Fix field length of erratum-advisory-name to match real DB field length

* Wed Sep 11 2013 Stephen Herr <sherr@redhat.com> 2.1.21-1
- 1006867 - null-org channels should be visible over ISS

* Mon Sep 09 2013 Stephen Herr <sherr@redhat.com> 2.1.20-1
- 1005760 - if orgs data does not exist in sat-sync import from disk, just skip

* Mon Sep 09 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.19-1
- 1005817 - create snapshot when changing base channel via rhn-channel

* Fri Sep 06 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.18-1
- 1001979 - fixed typo in --master description

* Fri Sep 06 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.17-1
- Consolidated rhnLib tests into a single place
- 1004804 - bool(0) == False, but is valid file mode
- Changing deprecated "has_key" to "in"

* Thu Sep 05 2013 Jan Dobes 2.1.16-1
- 883242 - check for empty result before printing software entitlement

* Tue Sep 03 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.15-1
- 1002041 - don't upload crash file if over the size limit or the upload is
  disabled
- removing trailing whitespaces in python in backend directory

* Fri Aug 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.14-1
- don't install / build mod_python stuff
- removed unused mod_python stuff

* Fri Aug 30 2013 Tomas Lestach <tlestach@redhat.com> 2.1.13-1
- 1002193 - remove spacewalk-backend-libs dependency from rhncfg

* Wed Aug 28 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.12-1
- 1001979 - fixed man page
- 1001978 - fixed typo

* Wed Aug 21 2013 Stephen Herr <sherr@redhat.com> 2.1.11-1
- 960550 - completed checkbox was not checked on kickstarts that had no
  activation keys

* Tue Aug 20 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.10-1
- fixed satellite-sync man page

* Mon Aug 19 2013 Stephen Herr <sherr@redhat.com> 2.1.9-1
- 997571 - channel visibility settings broke backwards compatibility
- https://engineering.redhat.com/trac/satellite/wiki/TooCleverForPython
- whitespace cleanup

* Mon Aug 12 2013 Grant Gainey <ggainey@redhat.com> 2.1.8-1
- 996155 - Fix messaging when ISS failures happen

* Wed Aug 07 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.7-1
- Backend: fix broken gettext test

* Tue Aug 06 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.6-1
- set default value for disconnected
- 959923 - change (hopefully improve) usage guide.

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.5-1
- Branding clean-up of proxy stuff in backend dir

* Fri Aug 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- fixed variable name

* Fri Aug 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- handle unicode tracebacks

* Mon Jul 29 2013 Stephen Herr <sherr@redhat.com> 2.1.2-1
- 960550 - the "Deploy confguration files" box is never checked for kickstarts

* Thu Jul 25 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.1-1
- 803837 - process includepkgs and exclude from yum.conf

* Thu Jul 18 2013 Jan Dobes 2.0.3-1
- 645435 - log per channel instead of session

* Thu Jul 18 2013 Michael Mraka <michael.mraka@redhat.com> 2.0.2-1
- check only tables in own schema

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.59-1
- updating copyright years

* Tue Jul 16 2013 Tomas Lestach <tlestach@redhat.com> 1.10.58-1
- allow spacewalk-remove-channel to unsubscribe systems with enabled logging

* Tue Jul 16 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.57-1
- removing some dead code

* Sun Jul 14 2013 Tomas Lestach <tlestach@redhat.com> 1.10.56-1
- enable satellite-sync with enabled audit

* Fri Jul 12 2013 Tomas Lestach <tlestach@redhat.com> 1.10.55-1
- handle registration time in backend
- implement logging functions for python stack
- Set the clear_log_id.
- Adding the logging setup to the backend stack (no user authentication).

* Tue Jul 02 2013 Stephen Herr <sherr@redhat.com> 1.10.54-1
- 977878 - move iss parent / ca_cert configs into database

* Fri Jun 28 2013 Stephen Herr <sherr@redhat.com> 1.10.53-1
- 977878 - fixing ISS demo problem, this query should get org ids

* Thu Jun 27 2013 Stephen Herr <sherr@redhat.com> 1.10.52-1
- 977878 - trust syncing should remove trusts that no longer exist

* Tue Jun 25 2013 Stephen Herr <sherr@redhat.com> 1.10.51-1
- 977878 - fixing checkstyle errors

* Tue Jun 25 2013 Grant Gainey 1.10.50-1
- ISS: checking a couple of potentially None values
- ISS: make sure new satellites can sync to old ones
- ISS: Channel trust syncing now works
- ISS: Implemented sat-sync options and db work for org / org trusts
- ISS: Bunch of changes for ISS, not working yet
- ISS: export org and org-trust data
- ISS: export channel access permissions
- ISS: First pieces of backend code for using the iss-cfg tables
- support numerals only for db-name, db-user and db-password

* Thu Jun 20 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.49-1
- 852250 - filter out bad package/architecture combinations

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.48-1
- removed old CVS/SVN version ids
- branding fixes in man pages
- more branding cleanup

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.47-1
- moved product name to work also in proxy

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.46-1
- rebranding few more strings

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.45-1
- rebranding RHN Proxy to Red Hat Proxy
- rebrading RHN Satellite to Red Hat Satellite in backend

* Thu Jun 06 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.44-1
- 675228, 795000 - metadata are already in utf8

* Tue Jun 04 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.43-1
- 970315 - support both gz and bz2 compressed repo files

* Thu May 30 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.42-1
- severity may be unknown

* Wed May 29 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.41-1
- 967850 - don't change global configuration component for reading product name

* Tue May 28 2013 Stephen Herr <sherr@redhat.com> 1.10.40-1
- 948335 - adding new server client capability for cpu_sockets

* Tue May 28 2013 Simon Lukasik <slukasik@redhat.com> 1.10.39-1
- Add scap into list of packaged modules.
- Do not use python key-word as a variable name
- Store SCAP-file-limit to the database

* Mon May 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.38-1
- pack backend_checker into rpm

* Mon May 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.37-1
- update copyright column length
- script to backendOracle.py definitions vs. database
- 962683 - don't truncate channel name to 64 chars
- Backend handlers for receiving full SCAP results
- Challenge clients to upload result files from the audit

* Wed May 22 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.36-1
- 950198 - make API compatible with old RHEL5 clients
- man pages branding cleanup + misc branding fixes

* Tue May 21 2013 Grant Gainey <ggainey@redhat.com> 1.10.35-1
- Turn off a pylint warning

* Tue May 21 2013 Grant Gainey <ggainey@redhat.com> 1.10.34-1
- 965809 - Fix ISS authentication hole

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.33-1
- branding clean-up of spacewalk-backend
- branding clean-up of logrotate files

* Fri May 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.32-1
- 963230 - remote activation in disconnected mode is not valid

* Thu May 16 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.31-1
- 891333 - provide option to keep rpms

* Mon May 13 2013 Jan Dobes 1.10.30-1
- 843367 - replacing __processHash function body by lookups to prevent multiple
  insertion tries

* Fri May 10 2013 Tomas Lestach <tlestach@redhat.com> 1.10.29-1
- 959590 - prepending security severity to advisory synopsis

* Fri May 10 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.28-1
- 888378 - print nice error message in disconnected mode

* Tue May 07 2013 Jan Pazdziora 1.10.27-1
- The get_source_rpm was removed long time ago, removing reference to it.

* Tue May 07 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.26-1
- 918333 - don't truncate filepath when exporting

* Thu May 02 2013 Stephen Herr <sherr@redhat.com> 1.10.25-1
- 947639 - make satellite-sync work with new rhnlib

* Mon Apr 29 2013 Stephen Herr <sherr@redhat.com> 1.10.24-1
- Revert "Run python backend in daemon mode to ease integration with splice"
- Revert "Additional change for spacewalk-backend daemon mode"

* Fri Apr 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.23-1
- 911738 - remove incorrect path from db

* Fri Apr 26 2013 Tomas Lestach <tlestach@redhat.com> 1.10.22-1
- 953284 - fix registration issues on PG

* Fri Apr 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.21-1
- make rpclib connection timeout configurable

* Wed Apr 17 2013 Jan Pazdziora 1.10.20-1
- moving taskomatic.channel_repodata_workers config default from backend to
  java

* Mon Apr 15 2013 Stephen Herr <sherr@redhat.com> 1.10.19-1
- Additional change for spacewalk-backend daemon mode

* Fri Apr 12 2013 Stephen Herr <sherr@redhat.com> 1.10.18-1
- Run python backend in daemon mode to ease integration with splice

* Tue Apr 09 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.17-1
- moving system currency config defaults from separate file to rhn_java.conf

* Fri Apr 05 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.16-1
- 929238 - fixed local path for file:// repos
- 918333 - reflect schema change

* Wed Mar 27 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.15-1
- abrt: check the package string is complete

* Wed Mar 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.14-1
- do not read rpm into memory before transferring to client (bnc#801151)

* Tue Mar 26 2013 Jan Pazdziora 1.10.13-1
- Replacing DECODE with more standard CASE.

* Tue Mar 26 2013 Jan Pazdziora 1.10.12-1
- Use to_timestamp instead of to_date which should bring the second precision
  to PostgreSQL.

* Mon Mar 25 2013 Stephen Herr <sherr@redhat.com> 1.10.11-1
- Client tools able to pass up socket info
- add python and java xmlrpc handlers for cpu socket info

* Thu Mar 21 2013 Jan Pazdziora 1.10.10-1
- abrt: store crash uuid

* Wed Mar 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.9-1
- fixing column name in postgresql
- The min_new_user_len option is not used anywhere in our code, removing.

* Thu Mar 14 2013 Jan Pazdziora 1.10.8-1
- The parameters are not processed in the parent class, stop passing them in.

* Wed Mar 13 2013 Jan Pazdziora 1.10.7-1
- Properly check the self.port which can be None by now.

* Tue Mar 12 2013 Jan Pazdziora 1.10.6-1
- abrt: support parsing package nevra from older abrt versions
- The is_connected_to needs to match the adjustments we do in connect.
- Do not parse the command line options, there are none.

* Mon Mar 11 2013 Jan Pazdziora 1.10.5-1
- 757302, 843723, 873379 - require python-psycopg2 with patch for the reference
  leaks.
- add missing comma

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.4-1
- abrt: enable crash reporting settings in backend

* Fri Mar 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.3-1
- Move org configuration to a separate table
- make startswith work with python versions < 2.5

* Wed Mar 06 2013 Jan Pazdziora 1.10.2-1
- Stop having comments on the same line as the key = value pair.

* Tue Mar 05 2013 Jan Pazdziora 1.10.1-1
- To allow hash-signs in passwords, only ignore comments if they are the first
  non-whitespace characters on the line.

* Fri Mar 01 2013 Jan Pazdziora 1.9.45-1
- If the database host is localhost, use Unix sockets in backend.

* Fri Mar 01 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.44-1
- abrt: display download link only for files that are available
- Removing writeConfig and dependencies, we do not use it anywhere in our code.
- The TODOs are not up-to-date, removing.

* Thu Feb 28 2013 Jan Pazdziora 1.9.43-1
- Init CFG only if it was not yet.

* Thu Feb 28 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.42-1
- reverted --db-only removal

* Thu Feb 28 2013 Jan Pazdziora 1.9.41-1
- Initialize the CFG, in case the caller did not do it for us.
- Using the correct configuration value for database name.
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.40-1
- Fixing empty method body.

* Thu Feb 28 2013 Jan Pazdziora 1.9.39-1
- Move to three-parameter cx_Oracle.Connection call.
- Removing the dsn parameter from initDB, removing support for --db option.

* Wed Feb 27 2013 Jan Pazdziora 1.9.38-1
- abrt: strip extraneous '\n' from username

* Wed Feb 27 2013 Jan Pazdziora 1.9.37-1
- The directory index can use uppercase for the HTML markup.

* Tue Feb 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.36-1
- spacewalk-backend.spec fix

* Tue Feb 26 2013 Tomas Kasparek <tkasparek@redhat.com> 1.9.35-1
- 914902 - system currency report

* Tue Feb 26 2013 Jan Pazdziora 1.9.34-1
- abrt: delete crash: remove content from filer

* Thu Feb 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.33-1
- don't link packages which failed to download

* Wed Feb 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.32-1
- correct size for old rpms > 2 GiB

* Wed Feb 20 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.31-1
- attribute doesn't work on RHEL5, use key

* Tue Feb 19 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.30-1
- abrt: don't update count for non-existent crash reports

* Tue Feb 19 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.29-1
- support V4 RSA/SHA1 signature

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.28-1
- abrt: commit after every call to insert_crash_file
- abrt: allow uploading zero length files

* Wed Feb 13 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.27-1
- link all packages to channel at once
- download packages first then link to channel
- abrt: use exceptions rather than return values for errors
- abrt: ability to limit crashfile upload size per organization
- abrt: ability to update crash count
- abrt: support for client -> server crash upload
- New translations from Transifex for spacewalk-backend.

* Mon Feb 11 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.26-1
- allow client to access mod_wsgi pages under apache 2.4

* Tue Feb 05 2013 Jan Pazdziora 1.9.25-1
- The urls now have three elements, make the list consistent.

* Mon Feb 04 2013 Jan Pazdziora 1.9.24-1
- Stop referencing URL which no longer exists.
- The abuse_check was a hosted feature.
- Removing rhnFault codes that are not raised anywhere in our code base.

* Fri Feb 01 2013 Jan Pazdziora 1.9.23-1
- Parse the directory listings and retrieve kickstartable trees when called
  with the --sync-kickstart option.
- Make clear_ssl_cache actually do the cleaning.
- Use the existing _clean_cache helper method.

* Mon Jan 28 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.22-1
- fixed container implementation
- fixing order of disabled messages

* Fri Jan 25 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.21-1
- pylint on RHEL6 does not know about W1401

* Fri Jan 25 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.20-1
- silence warning about "\0" string
- disable false positive warnings

* Fri Jan 25 2013 Jan Pazdziora 1.9.19-1
- The rhn_asdf_* anonymous logic should not be needed anymore.
- Reimplement anonymous block with update or insert.
- Reimplement anonymous block with rhnSQL.Procedure.
- The _query_purge_extra_channel_families_1 seems unused, removing.
- Reimplement anonymous block.
- Reimplement _set_comps_for_channel as stored procedure.

* Tue Jan 22 2013 Jan Pazdziora 1.9.18-1
- Use SSL options from rhncontentsourcessl during spacewalk-repo-sync.

* Fri Jan 18 2013 Jan Pazdziora 1.9.17-1
- Removing no longer used rhnChannelDownloads, rhnDownloads, and
  rhnDownloadType.

* Thu Jan 17 2013 Jan Pazdziora 1.9.16-1
- abrt: use insert + update rather than delete + insert
- fix bogus dates in changelog

* Wed Jan 02 2013 Tomas Lestach <tlestach@redhat.com> 1.9.15-1
- 889263 - unify java & backend grace period lenghts
- 890910 - set satsync email sender to root@<satfqdn>

* Fri Dec 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.14-1
- Do not use value attribute of an exception

* Mon Dec 10 2012 Jan Pazdziora 1.9.13-1
- 885170 - fixing syntax.

* Mon Dec 10 2012 Jan Pazdziora 1.9.12-1
- 885170 - provide translations of a new error recieved from Hosted

* Tue Dec 04 2012 Jan Pazdziora 1.9.11-1
- On Fedoras, start to use tomcat >= 7.

* Fri Nov 30 2012 Jan Pazdziora 1.9.10-1
- 877451 - read the repo config from yumbase
- 877451 - correct the proxy configuration logic

* Thu Nov 22 2012 Jan Pazdziora 1.9.9-1
- 877451 - correct parsing of main and channel's settings
- 877451 - add missing and
- 877451 - honor yum's "proxy = _none_" settings

* Fri Nov 16 2012 Jan Pazdziora 1.9.8-1
- 877451 - yum-like per-repo configuration for spacewalk-repo-sync
- remove misleading comment

* Wed Nov 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.7-1
- 868370 - fixed dependency solver for RHEL4 clients

* Wed Nov 07 2012 Jan Pazdziora 1.9.6-1
- Fixing pylint error.

* Wed Nov 07 2012 Jan Pazdziora 1.9.5-1
- Using fcntl.lockf should avoid any need for packing.

* Wed Nov 07 2012 Tomas Lestach <tlestach@redhat.com> 1.9.4-1
- renaming forgotten 'dict' to 'row_dict'

* Tue Nov 06 2012 Jan Pazdziora 1.9.3-1
- The fcntl documentation recommends different pack format.
- Only SEEK_SET used, no need to have zero defined in an extra module.

* Wed Oct 31 2012 Jan Pazdziora 1.9.2-1
- add org_id to DistChannelMap backend class

* Wed Oct 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.1-1
- 860860 - release and title are optional in older updateinfo version

* Tue Oct 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.84-1
- removing unused backend code
- backend changes

* Tue Oct 30 2012 Jan Pazdziora 1.8.83-1
- Update the copyright year.
- Update .po and .pot files for rhnsd.
- Download translations from Transifex for spacewalk-backend.

* Wed Oct 24 2012 Jan Pazdziora 1.8.82-1
- group file might be missing

* Mon Oct 22 2012 Jan Pazdziora 1.8.81-1
- 828804 - no su-ing to oracle with embedded PostgreSQL.
- rhnlib >= 2.5.38 is not necessary
- 797893 - rollback any unfinished transaction

* Fri Oct 19 2012 Jan Pazdziora 1.8.80-1
- omit inserting child channels into the rhnDistChannelMap

* Mon Oct 15 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.79-1
- fixed Used builtin function 'apply'
- replaced "!#/**bin/env python" with "!#/usr/bin/python"

* Fri Oct 12 2012 Jan Pazdziora 1.8.78-1
- Use the binary binding.
- Fixing example. This was meant as a short option.

* Thu Oct 11 2012 Jan Pazdziora 1.8.77-1
- 712313 - for the installed_size, ignore situation when it was not populated
  in the database.
- Use the severityHash/diffHash mechanism for ignoring channel_product_id
  differences.

* Thu Oct 11 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.76-1
- let's spacewalk-repo-sync download comps.xml

* Tue Oct 09 2012 Jan Pazdziora 1.8.75-1
- Put Oracle stuff back for Fedora 17.

* Tue Oct 09 2012 Jan Pazdziora 1.8.74-1
- Put Oracle stuff back for Fedora 17.

* Tue Oct 09 2012 Jan Pazdziora 1.8.73-1
- Put Oracle stuff back for Fedora 17.

* Thu Oct 04 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.71-1
- 860860 - don't fail when from attribute is missing

* Wed Oct 03 2012 Jan Pazdziora 1.8.70-1
- Revert "diffing packages speedup on postgresql"

* Mon Sep 17 2012 Jan Pazdziora 1.8.69-1
- exporter: honor sync-date / rhn-date when exporting erratas

* Fri Sep 14 2012 Jan Pazdziora 1.8.68-1
- The server/rhnKickstart does not seem to be imported by any code, removing.

* Fri Sep 14 2012 Jan Pazdziora 1.8.67-1
- Now that the Oracle columns are of type TIMESTAMP WITH LOCAL TIME ZONE,
  nls_timestamp_format is needed as well.

* Mon Sep 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.66-1
- spacewalk-backend-libs can break spacewalk-backend < 1.7

* Fri Sep 07 2012 Jan Pazdziora 1.8.65-1
- Adding file path restoration functionality to spacewalk-data-fsck
- 815964 - moving monitoring probe batch option from rhn.conf to rhn_web.conf

* Fri Aug 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.64-1
- fixed pylint errors

* Mon Aug 27 2012 Stephen Herr <sherr@redhat.com> 1.8.63-1
- 848475 - Adding IPv6 ip-address detection to proxy auth fix

* Sun Aug 26 2012 Aron Parsons <aronparsons@gmail.com> 1.8.62-1
- add --no-errata option to spacewalk-repo-sync

* Tue Aug 21 2012 Stephen Herr <sherr@redhat.com> 1.8.61-1
- 848475 - separate proxy auth error hostname into separate header
- 849219 - don't explain the error about not subscribing proxy channels

* Wed Aug 15 2012 Stephen Herr <sherr@redhat.com> 1.8.60-1
- 848475 - multi-tiered proxies don't update auth tokens correctly

* Thu Aug 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.59-1
- calls have been removed from client side, mark them as obsoleted
- unfortunatelly old clients can still call new_user

* Tue Jul 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.58-1
- 844603 - removed PyXML dependency

* Tue Jul 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.57-1
- upload_server is now pylint-able
- fixed pylint errors / warnings

* Tue Jul 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.56-1
- 838502 - block subscription to satellite and proxy channels

* Tue Jul 31 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.55-1
- pylint on Fedoras need disable before whole try-except block

* Mon Jul 30 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.54-1
- satellite_exporter is now pylint-able

* Mon Jul 30 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.53-1
- update_contact_info is not called from client for a long time
- removed unaccessible code

* Mon Jul 30 2012 Tomas Lestach <tlestach@redhat.com> 1.8.52-1
- remove usage of org_applicant user role
- remove usage of rhn_superuser user role

* Fri Jul 27 2012 Tomas Kasparek <tkasparek@redhat.com> 1.8.51-1
- Truncating date string and therefore preventing ORA-01830
- Fixing placeholder syntax.

* Thu Jul 19 2012 Jan Pazdziora 1.8.50-1
- Add abrt into list of packaged modules.

* Wed Jul 18 2012 Jan Pazdziora 1.8.49-1
- Add abrt data handling functionality

* Thu Jul 12 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.48-1
- prostgresql don't know about decode
- fixed ERROR: subquery in FROM must have an alias

* Tue Jul 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.47-1
- Fix indentation error

* Wed Jul 04 2012 Jan Pazdziora 1.8.46-1
- Make sure even upgrades from 1.8.33 remove spacewalk-backend-xp.

* Thu Jun 28 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.45-1
- 765816 - file mode have to be string

* Thu Jun 28 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.44-1
- fixed AttributeError: 'buffer' object has no attribute 'write'

* Thu Jun 28 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.43-1
- Correct SQL query for installing and removing solaris patches
- Correct query for PGSQL

* Tue Jun 26 2012 Stephen Herr <sherr@redhat.com> 1.8.42-1
- 835676 - man page fix and root-level user warning for rhn-satellite-exporter

* Tue Jun 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.41-1
- 833686 - don't open file if path is None

* Tue Jun 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.40-1
- removed dead code backend.listChannel()

* Fri Jun 22 2012 Jan Pazdziora 1.8.39-1
- 712313 - Add installed size to repodata

* Fri Jun 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.38-1
- fixed usage of path macros
- removed -xp subpackage
- removed dead code for /XP handler
- removed unused /XP handler

* Fri Jun 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.37-1
- 811646 - handle locally exception in entitle_server()
- don't pass the same parameter twice
- 811646 - made error message more detailed

* Mon Jun 18 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.36-1
- removed API for v1 clients

* Fri Jun 15 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.35-1
- fixed Instance of 'deb_Header' has no 'keys' member
- removed unreachable code

* Tue Jun 12 2012 Tomas Lestach <tlestach@redhat.com> 1.8.34-1
- 804106 - do not entitle virt guests twice during registration

* Tue Jun 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.33-1
- removed support for Red Hat Linux 6.2 and 7.[0123]

* Tue Jun 05 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.32-1
- fix wrong transaction name in unsubscribe_channels (mc@suse.de)

* Tue Jun 05 2012 Jan Pazdziora 1.8.31-1
- No longer building spacewalk-backend-sql-oracle on Fedora 17+.

* Mon Jun 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.30-1
- Add support for studio image deployments (backend) (jrenner@suse.de)

* Fri Jun 01 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.29-1
- print reasonable error message when something wrong with repo

* Tue May 22 2012 Jan Pazdziora 1.8.28-1
- decode unicode string on IDN machines
- %%defattr is not needed since rpm 4.4

* Fri May 18 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.27-1
- 822620 - lookup packages only from correct org

* Fri May 11 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.26-1
- use ANSI sql syntax

* Fri May 04 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.25-1
- update.xml contains epoch='0' even for packages which epoch is NULL

* Fri May 04 2012 Jan Pazdziora 1.8.24-1
- No need to be autonomous when inserting to rhnArchType, only satellite-sync
  does it.

* Mon Apr 30 2012 Simon Lukasik <slukasik@redhat.com> 1.8.23-1
- Assign a dummy profile when none is selected. (slukasik@redhat.com)
- xccdf_eval should not send null value (slukasik@redhat.com)
- Removing unhelpful assignment. (slukasik@redhat.com)

* Fri Apr 27 2012 Jan Pazdziora 1.8.22-1
- 815964 - update monitoring probes in small batches to reduce the chance of a
  deadlock (sherr@redhat.com)

* Tue Apr 24 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.21-1
- 807962 - raise SQLSchemaError alike oracle driver does

* Fri Apr 20 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.20-1
- 805582 - fix sql query with --use-sync-date and --start-date of rhn-
  satellite-exporter

* Tue Apr 17 2012 Jan Pazdziora 1.8.19-1
- The mod_wsgi insists on having something after the numeric value on the
  Status line.
- Workaround httplib in 2.4 which did not have the responses dictionary.
- 812789 - write nicer error message in case you are missing rpm files
  (msuchy@redhat.com)

* Mon Apr 16 2012 Jan Pazdziora 1.8.18-1
- Sadly, even if cobbler 2.2 is in EPELs, it is not in Fedora -- we need to
  require just 2.0.

* Mon Apr 16 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.17-1
- add man page for --use-rhn-date and --use-sync-date
- 805582 - include even package which does not belong to errata
- 805582 - introduce new option --whole-errata to exporter

* Fri Apr 13 2012 Jan Pazdziora 1.8.16-1
- 812329 - adding PostgreSQL configuration and log files to the debug.
- 812329 - updating rhn-charsets man page -- update list of value names, no
  command line options.
- 812329 - make rhn-charsets working on PostgreSQL as well; the output format
  changed even for Oracle.
- 812329 - add sudoers.d to the debug, there can be important information
  there.
- 812329 - The /etc/tnsnames.ora file might not exists.

* Fri Apr 13 2012 Jan Pazdziora 1.8.15-1
- With cobbler 2.2 landing in EPEL 5, we need to move to mod_wsgi with
  Spacewalk backend even on RHEL 5.

* Wed Apr 11 2012 Stephen Herr <sherr@redhat.com> 1.8.14-1
- 786705 - Update config default to preserve base channel on reactivation
  (sherr@redhat.com)

* Tue Apr 10 2012 Jan Pazdziora 1.8.13-1
- rhn-schema-stats: update manual page (mzazrivec@redhat.com)
- rhn-schema-stats: support for PostgreSQL (mzazrivec@redhat.com)
- rhn-db-stats: update manual page (mzazrivec@redhat.com)
- rhn-db-stats: support for PostgreSQL (mzazrivec@redhat.com)

* Thu Apr 05 2012 Jan Pazdziora 1.8.12-1
- 809936 - we need to insert NULLs to avoid vn_rhnserverhistory_details.

* Tue Apr 03 2012 Jan Pazdziora 1.8.11-1
- Fixing typo in spacewalk-remove-channel man page.

* Fri Mar 30 2012 Stephen Herr <sherr@redhat.com> 1.8.10-1
- 808516 - When importing channeldumps from Sat 5.3 or older we should assume
  sha1 checksum type (sherr@redhat.com)
- 805012 - check channel permissions when unsubscribing a channel
  (mzazrivec@redhat.com)

* Fri Mar 30 2012 Jan Pazdziora 1.8.9-1
- CVE-2012-1145, 800688 - check the result of parseServ operation.
- Truncate data which are longer than db allows (slukasik@redhat.com)

* Thu Mar 29 2012 Simon Lukasik <slukasik@redhat.com> 1.8.8-1
- Store also @idref of xccdf:rule-result element (slukasik@redhat.com)
- We want to store all idents per rule-result (slukasik@redhat.com)
- PostgreSQL 9.x does not like alias without AS, the alias not needed in the
  end. (jonathan.hoser@helmholtz-muenchen.de)

* Wed Mar 21 2012 Jan Pazdziora 1.8.7-1
- Avoid printing "None" when uninitialized value is found.
- The parameter/option is traceback_mail.

* Mon Mar 19 2012 Jan Pazdziora 1.8.6-1
- Avoid unlink after move.
- 521764 - use runuser instead of su (msuchy@redhat.com)

* Fri Mar 16 2012 Jan Pazdziora 1.8.5-1
- 804036 - need to use timestamp datatype to preserve the precision.

* Fri Mar 16 2012 Jan Pazdziora 1.8.4-1
- 802688 - Forcing empty strings to be Nones.

* Wed Mar 14 2012 Jan Pazdziora 1.8.3-1
- 803230 - cast to string to force lookup_evr prototype.
- 798401 - use --debug-level parameter (msuchy@redhat.com)

* Fri Mar 09 2012 Miroslav Suchý 1.8.2-1
- spacewalk-repo-sync documentation fix : add include/exclude options to
  manpage (shardy@redhat.com)
- add default value for taskomatic.channel_repodata_workers

* Mon Mar 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.1-1
- login(), logout() moved to spacewalk.common.cli
- added cli module to rpm
- created module for usefull cli functions

* Fri Mar 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.38-1
- channel id have to be number

* Fri Mar 02 2012 Jan Pazdziora 1.7.37-1
- Update the copyright year info.

* Tue Feb 28 2012 Jan Pazdziora 1.7.36-1
- Update .po and .pot files for spacewalk-backend.
- Download translations from Transifex for spacewalk-backend.
- Remove unstructured debugging outputs. (slukasik@redhat.com)

* Tue Feb 28 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.35-1
- fixed 'speeded up searching whether package is already synced'

* Tue Feb 28 2012 Jan Pazdziora 1.7.34-1
- Avoid vn_rhnpackageevr_epoch violation.

* Mon Feb 27 2012 Simon Lukasik <slukasik@redhat.com> 1.7.33-1
- OpenSCAP integration -- Backend API interface. (slukasik@redhat.com)
- convert empty string to NULL for postgresql (michael.mraka@redhat.com)

* Mon Feb 27 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.32-1
- use already known channel id
- speeded up searching whether package is already synced

* Mon Feb 27 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.31-1
- merged solve_dependencies_arch() and solve_dependencies()
- merged listChannelsSource() and listChannels()

* Fri Feb 24 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.30-1
- 727979 - don't hardcode package suffix

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.29-1
- removed unused pygettext.py
- we are now just GPL

* Wed Feb 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.26-1
- diffing packages speedup on postgresql

* Wed Feb 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.25-1
- fixed pylint error in rpm check
- parseRPMFilename() should stay in server/rpmLib

* Wed Feb 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.24-1
- import rhnLog stuff once
- moved parseRPMName() from server/rhnLib to common/rhnLib

* Mon Feb 20 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.23-1
- fixed up2date --show-available on PG

* Fri Feb 17 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.22-1
- wsgi should be pylint clean from now
- pylint cleanup in backend/wsgi
* Fri Feb 17 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.21-1
- insert empty strings as NULL for postgresql

* Wed Feb 15 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.20-1
- use spacewalk-pylint for coding style check
- fixed pylint errors
- removed unused function

* Fri Feb 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.19-1
- empty epoch have to be None
- compute payload_size including its header
- idn_ascii_to_pune() expects string not list
- made mod_wsgi configuration consistent with mod_python

* Wed Feb 08 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.18-1
- added description to pushed debian packages

* Tue Feb 07 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.17-1
- fixed KeyError during deb package push
- fixed ERROR: unhandled exception occurred: ('epoch').
- fixed InvalidPackageErrorduring push of deb package
- converted rhnpush to use A_Package interface

* Mon Feb 06 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.16-1
- fixed rpmbuild on RHEL5

* Mon Feb 06 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.15-1
- fixed nsglms errors
- fixed pylint error on Fedora 16
- fixed tempfile error on RHEL5

* Sat Feb 04 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.14-1
- fixed macros in changelog
- check common/* for pylint errors
- fixed pylint errors and warnings in common/*.py

* Fri Feb 03 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.13-1
- simplified checksum_exists condition
- merged duplicated h.execute() call
- version and release should be strings, epoch should be None or string
- modified RPM/MPM/DEB package for payload_checksum
- generic code to compute checksum of package
- spacewalk-repo-sync updated to use new package object
- created DEB_Package
- moved InvalidPackageError to rhn_pkg
- created RPM_Package
- create proper package object
- compute checksum while saving payload
- rewritten package_push handler to use package object
- created virtual class for RPM/MPM/DEB packages

* Thu Feb 02 2012 Jan Pazdziora 1.7.12-1
- Call the test entitlement count check for satellite-sync as well.

* Wed Feb 01 2012 Aron Parsons <parsonsa@bit-sys.com> 1.7.11-1
- fix incorrect parsing of errata bug data on import (parsonsa@bit-sys.com)

* Thu Jan 26 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.10-1
- fixed rhnpush ERROR: unhandled exception occurred: (timed out)

* Tue Jan 24 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.9-1
- Use shutil instead of os to push packages

* Mon Jan 23 2012 Aron Parsons <aronparsons@gmail.com> 1.7.8-1
- use the correct tag for the bugzilla href field (aronparsons@gmail.com)

* Mon Jan 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.7-1
- 756918 - workaround for package_group issue

* Tue Jan 17 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.6-1
- use name_ids to speedup reposync

* Mon Jan 16 2012 Miroslav Suchý 1.7.5-1
- Avoing rhnChecksum_seq.nextval Oracle syntax.

* Tue Jan 10 2012 Jan Pazdziora 1.7.4-1
- Revert "695282 - censor password from registration.reserve_user if it appears
  in TB"
- 749890 - setting up seclist in reserve_user, new_system, and
  new_system_user_pass.

* Thu Jan 05 2012 Jan Pazdziora 1.7.3-1
- Removing the debugging prints.
- removed dead code (michael.mraka@redhat.com)

* Tue Jan 03 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.2-1
- code cleanup
- removed dead remaining_subscriptions()

* Thu Dec 22 2011 Jan Pazdziora 1.7.1-1
- Check for channel family entitlement counts.
- Also show what the certificate slot is called in the WebUI.
- Better explanation of slot changes.

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.66-1
- update copyright info

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.65-1
- updated translations

* Fri Dec 16 2011 Jan Pazdziora 1.6.64-1
- 756918 - cookie can be empty string, avoid having it as string "None" in the
  dump.

* Fri Dec 16 2011 Jan Pazdziora 1.6.63-1
- Allow systemid to be unicode.
- Revert "always return RPC data in plain string (utf-8 encoded)"

* Thu Dec 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.62-1
- persistdir have to be set before pkgdir
- call sync() which does the real work

* Thu Dec 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.61-1
- 676369 - create pkgdir with appropriate user and group
- 676369 - put downloaded packages into stage

* Wed Dec 14 2011 Jan Pazdziora 1.6.60-1
- 731912 - do not skip base channel detection based just on release change
  (tlestach@redhat.com)

* Tue Dec 13 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.59-1
- 747631 - exit loop when all packages are finished

* Mon Dec 12 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.58-1
- use global LOCK
- use systemExit instead of calling sys.stderr.write directly
- move repository setup to a separate method
- word-wrap to <80 chars and fix string concatenation
- CACHE_DIR is a constant so we declare it at the top of the file
- fixed indentation and whitespace
- move third-party module import yum lower

* Fri Dec 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.57-1
- postgresql bytea doesn't like backslashes

* Fri Dec 09 2011 Jan Pazdziora 1.6.56-1
- remove use of deprecated `apply` function (iartarisi@suse.cz)
- move comment to its proper place (iartarisi@suse.cz)
- fix indentation, whitespace and string concatenation (iartarisi@suse.cz)
- get the repo_type as an argument instead of reading it from the instance attr
  (iartarisi@suse.cz)
- move option parsing from reposync.py to the spacewalk-repo-sync script
  (iartarisi@suse.cz)
- use the print_msg function instead of print to also log the message
  (iartarisi@suse.cz)
- use new-style classes (iartarisi@suse.cz)
- remove unused `traceback` import and arrange std lib modules one per line
  (iartarisi@suse.cz)
- moved standard library imports to the top of the file (iartarisi@suse.cz)
- remove useless check for importing module (iartarisi@suse.cz)
- simplified systemExit function with what we use (iartarisi@suse.cz)
- Catch any psycopg2 errors and reraise them as sql_base.SQLError, in functions
  and procedures.

* Thu Dec 08 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.55-1
- 676369 - directory may not exist

* Wed Dec 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.54-1
- removed dead (commented out) code
- removed deprecated apply() function
- 760892 - set selinux=None if selinux is disabled

* Tue Dec 06 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.53-1
- 676369 - set pkgdir directly not via private API
- 621166 - let's enable yum_src tuning (via config file)

* Tue Dec 06 2011 Miroslav Suchý 1.6.52-1
- IPv6: order network interaces
- IPv6: implement macro rhn.system.net_interface.ip6_netmask for config files
  templates
- IPv6: implement macro rhn.system.net_interface.ip6_address for config files
  templates

* Mon Dec 05 2011 Miroslav Suchý 1.6.51-1
- IPv6: fix current macros for IPv4

* Mon Dec 05 2011 Jan Pazdziora 1.6.50-1
- We cannot rely on the order of returned records when ORDER BY clause is not
  used.
- IPv6: store NetIfaceInformation into __hardware (msuchy@redhat.com)
- print better representation to help debugging (msuchy@redhat.com)

* Mon Dec 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.49-1
- 676369 - sync packages directly to /var/satellite
- 676369 - move package to the final location
- 676369 - create tempfile under /var/satellite
- uploadPackage* function have been deprecated long time before Satellite 4.0
- read payload directly from inputstream

* Mon Dec 05 2011 Jan Pazdziora 1.6.48-1
- _query_get_slot_types not used, removing.
- IPv6: add new macro rhn.system.ip6_address for templates of configuration
  files (msuchy@redhat.com)
- cleaned up duplicated code (michael.mraka@redhat.com)

* Tue Nov 29 2011 Miroslav Suchý 1.6.47-1
- IPv6: filter out params, which are not used in query
- IPv6: do not pass to oracle more params than is necessary
- IPv6: if there is no data, do not try to access it
- IPv6: do not call constructor in reload
- IPv6: change backend to store IPv6 interfaces into DB
- IPv6: __load_from_db: load devices using its method save()

* Tue Nov 29 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.46-1
- removed dead function

* Mon Nov 28 2011 Miroslav Suchý 1.6.45-1
- fix typos in boolean variables (mc@suse.de)
- add missing import (mc@suse.de)

* Mon Nov 28 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.44-1
- having a table twice in select is mostly a bug

* Fri Nov 25 2011 Miroslav Suchý 1.6.43-1
- Ubuntu send request for translations, send 404 back and do not raise
  traceback (msuchy@redhat.com)
- Take Debian's alternative package names into account (slukasik@redhat.com)

* Wed Nov 23 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.42-1
- improve performance of query_client_get_file on PostgreSQL (parsonsa@bit-
  sys.com)

* Wed Nov 23 2011 Jan Pazdziora 1.6.41-1
- Need to name a subselect.

* Tue Nov 15 2011 Miroslav Suchý 1.6.40-1
- move common code to common function

* Tue Nov 15 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.39-1
- 738999 - aliases in update don't work

* Fri Nov 04 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.38-1
- 679335 - remove osa-dispatcher login credentials from rhn.conf

* Wed Nov 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.37-1
- support V4 RSA signatures

* Fri Oct 28 2011 Jan Pazdziora 1.6.36-1
- 600527 - during kickstart, check if at least one activation key allows config
  files to be deployed upon registration.
- typo fix (mzazrivec@redhat.com)

* Mon Oct 24 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.35-1
- 731692 - make number formating consistent across all units

* Tue Oct 18 2011 Miroslav Suchý 1.6.34-1
- 745102 - unify handlers of nullable columns

* Tue Oct 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.33-1
- package filters can be stored in database now

* Mon Oct 17 2011 Jan Pazdziora 1.6.32-1
- add an 'xmlrpc.errata.patch_names' capability (iartarisi@suse.cz)
- 600555 - removing the Management word from the error message because it is
  not Management entitlements we might be having problems with.
- consistent spacing (mzazrivec@redhat.com)

* Fri Oct 14 2011 Martin Minar <mminar@redhat.com> 1.6.31-1
- 745102 - if ip address is not set, convert "" to null (msuchy@redhat.com)

* Tue Oct 11 2011 Miroslav Suchý 1.6.30-1
- 745102 - accept IPv6 address in NETINFO record

* Tue Oct 11 2011 Miroslav Suchý 1.6.29-1
- 743259 - hasCapability is driven by version, not by value

* Mon Oct 10 2011 Jan Pazdziora 1.6.28-1
- 433325 - do not allow to register system with profile name less then 3
  characters (msuchy@redhat.com)

* Fri Oct 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.27-1
- 622490 - even if parent channel isn't in dump there might be some child
  channels
- 743259 - send IPv6 addresses only if server support it
- encode string to utf-8 before writing to output

* Tue Oct 04 2011 Miroslav Suchý 1.6.26-1
- 742905 - if thread will throw traceback do not forget to release lock, so
  other threads can continue
- 229836 - allow empty prefix for user

* Mon Oct 03 2011 Jan Pazdziora 1.6.25-1
- removed dead exception (michael.mraka@redhat.com)
- removed dead queries (michael.mraka@redhat.com)
- made syncCert() more readable (michael.mraka@redhat.com)

* Fri Sep 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.24-1
- 740542 - don't use executemany for queries with blobs

* Fri Sep 30 2011 Jan Pazdziora 1.6.23-1
- 621531 - update the path in the man page, plus some polishing.
- 621531 - update backend rhnConfig to use the new /usr/share/rhn/config-
  defaults location.
- 621531 - move /etc/rhn/default to /usr/share/rhn/config-defaults (backend).

* Wed Sep 28 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.22-1
- use COALESCE instead of NVL for compatibility with PostgreSQL (parsonsa@bit-
  sys.com)

* Thu Sep 22 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.21-1
- fix broken --list-channels option (parsonsa@bit-sys.com)
- Fix nvl2/case conversion (Joshua.Roys@gtri.gatech.edu)

* Mon Sep 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.20-1
- 732325 - nvl2 replace with ANSI case

* Mon Sep 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.19-1
- implemented Database.execute()

* Tue Sep 13 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.18-1
- 736127 - fixed /var/log/rhn/rhn_server_xmlrpc.log does not log IP addresses

* Mon Sep 12 2011 Miroslav Suchý 1.6.17-1
- add missing import sys

* Fri Sep 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.16-1
- small reposync speedup

* Fri Sep 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.15-1
- 735059 - modified TableInsert to use our direct blob insert

* Thu Sep 01 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.14-1
- implemented include/exclude package filtering for spacewalk-repo-sync

* Thu Aug 25 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.13-1
- fixed package lookup

* Fri Aug 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.12-1
- 593402 - cobbler-web is known to break our configuration

* Thu Aug 18 2011 Miroslav Suchý 1.6.11-1
- 723856 - remove unused variable
- if we use 1024 as base, we should use kiB, MiB, GiB
- 731692 - correct output of number beyond decimal point in sat-sync

* Thu Aug 18 2011 Tomas Lestach <tlestach@redhat.com> 1.6.10-1
- 658533 - remove default currency from backend part of rhn.conf
  (tlestach@redhat.com)

* Tue Aug 16 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.9-1
- 730452 - fixed table aliasses

* Mon Aug 15 2011 Miroslav Suchý 1.6.8-1
- make satCerts.py work on PostgreSQL

* Fri Aug 12 2011 Miroslav Suchý 1.6.7-1
- add missing import - sys

* Thu Aug 11 2011 Miroslav Suchý 1.6.6-1
- True and False constants are defined since python 2.4
- do not mask original error by raise in execption

* Fri Aug 05 2011 Simon Lukasik <slukasik@redhat.com> 1.6.5-1
- 725637 - documentation should correspond with the behavior
  (slukasik@redhat.com)

* Wed Aug 03 2011 Simon Lukasik <slukasik@redhat.com> 1.6.4-1
- In any case, do not attempt to remove /var/satellite (slukasik@redhat.com)
- extract method: unlink_package_file (slukasik@redhat.com)
- 701232 - remove unnecessary directories (slukasik@redhat.com)
- remove unused imports (slukasik@redhat.com)

* Tue Aug 02 2011 Simon Lukasik <slukasik@redhat.com> 1.6.3-1
- 673694 - process also child channels of custom channels (slukasik@redhat.com)

* Wed Jul 27 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.2-1
- import xmlrpclib directly
- Applying the encoding fix to copyright as well.

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Tue Jul 19 2011 Jan Pazdziora 1.5.45-1
- Updating the copyright years.

* Tue Jul 19 2011 Jan Pazdziora 1.5.44-1
- Merging Transifex changes for spacewalk-backend.
- New translations from Transifex for spacewalk-backend.
- Download translations from Transifex for spacewalk-backend.

* Tue Jul 19 2011 Jan Pazdziora 1.5.43-1
- Adding the spacewalk-backend-server.pot to repo.

* Tue Jul 19 2011 Jan Pazdziora 1.5.42-1
- update .po and .pot files for spacewalk-backend

* Fri Jul 15 2011 Jan Pazdziora 1.5.41-1
- do not use deprecated module "string" (msuchy@redhat.com)

* Wed Jul 13 2011 Jan Pazdziora 1.5.40-1
- 633400 - rhncfg-client lists lower-ranked config channel for file
  (mmello@redhat.com)

* Wed Jul 13 2011 Miroslav Suchý 1.5.39-1
- 695282 - censor password from registration.reserve_user if it appears in TB

* Mon Jul 11 2011 Miroslav Suchý 1.5.38-1
- optparse is here since python 2.3 - remove optik (msuchy@redhat.com)

* Fri Jul 08 2011 Miroslav Suchý 1.5.37-1
- do not log every action_extra_data as error (msuchy@redhat.com)

* Wed Jun 22 2011 Miroslav Suchý 1.5.36-1
- in sat-sync ETA cut off miliseconds (msuchy@redhat.com)
- make sat-sync ETA more precise (msuchy@redhat.com)

* Tue Jun 21 2011 Jan Pazdziora 1.5.35-1
- 676937 - allow to export all channels (msuchy@redhat.com)
- export from hosted does not know soft dependecies (msuchy@redhat.com)

* Mon Jun 13 2011 Jan Pazdziora 1.5.34-1
- 711805 - explicitly define the boolean behaviour of the object.

* Thu Jun 09 2011 Jan Pazdziora 1.5.33-1
- Fixing it's -> its typo.
- merge child_ids into the list, don't make it a list item
  (michael.mraka@redhat.com)

* Thu Jun 02 2011 Jan Pazdziora 1.5.32-1
- added errata.getErrataNamesById function to the API (iartarisi@suse.cz)

* Wed Jun 01 2011 Jan Pazdziora 1.5.31-1
- Fixing synopsis and example of spacewalk-repo-sync man page.

* Fri May 27 2011 Jan Pazdziora 1.5.30-1
- download packages in 4 simultanous threads (msuchy@redhat.com)

* Wed May 25 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.29-1
- timestamps expects YYYYMMDDHHMISS
- fixed table aliases

* Tue May 24 2011 Jan Pazdziora 1.5.28-1
- We need to specifically check for None when calling decode.

* Fri May 20 2011 Jan Pazdziora 1.5.27-1
- Removing %%{pythonrhnroot}/common/UserDictCase.py* from %%files.

* Fri May 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.26-1
- package path should contain epoch
- 694735 - incremental exports: honor rhn_date / sync_date for ks files

* Fri May 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.25-1
- merged backend/common/UserDictCase.py into rhnlib/rhn/UserDictCase.py

* Thu May 19 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.24-1
- 705002 - made query pg compatible

* Wed May 18 2011 Miroslav Suchý 1.5.23-1
- do not remove /var/satellite/redhat directory, satellite-sync expect it
- add missing function to pg Cursor
- 217531 - fix package count
- Refactoring of make_evr made MakeEvrError unused, removing.
- Removal of create_channel_families and create_channels made InvalidEntryError
  unused, removing.
- 702684 - made MPM_Header compatible with RPM_Header

* Mon May 16 2011 Michael Calmer <mc@suse.de> 1.5.22-1
- inherit from DependencyItem like other dep classes (mc@suse.de)
- test if checksum_type exists before accessing it (mc@suse.de)
- use fix_encoding method (mc@suse.de)
- fix encoding of package summary and description (mc@suse.de)

* Fri May 13 2011 Jan Pazdziora 1.5.21-1
- 698567 - give the transaction that we have to use to read the file header a
  sandbox database.

* Fri May 13 2011 Miroslav Suchý 1.5.20-1
- 695651 - mod_wsgi change header, flip it back to what we expect
  (msuchy@redhat.com)
- sgmlop parser could not return data in utf-8 (msuchy@redhat.com)
- 695651 - mimic req.connection.local_addr from mod_python (msuchy@redhat.com)

* Mon May 09 2011 Jan Pazdziora 1.5.19-1
- rhn-satellite-exporter with start-date and end-date (jbrazdil@redhat.com)
- fix utf-8 in emails (msuchy@redhat.com)

* Mon May 09 2011 Jan Pazdziora 1.5.18-1
- fix satsync with older spacewalk versions not providing weak deps
  (mc@suse.de)

* Mon May 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.17-1
- only one package per NVREA can be in channel, unlink the old one first
- link package also when the checksum has changed

* Thu May 05 2011 Miroslav Suchý 1.5.16-1
- 683200 - send emails as utf-8
- 683200 - convert hostname in subject from pune to unicode
- localize satsync messages
- provide estimation about remaining time for downloading rpm
- do not test if rhnParent can handle session caching

* Wed May 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.15-1
- some wierd packages have files in iso8859-1 not utf-8

* Mon May 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.14-1
- 701297 - don't try to read rpm header from mpm package

* Mon May 02 2011 Jan Pazdziora 1.5.13-1
- Method reload_packages not used in our code, removing.
- Removal of ReleaseChannelMapImport makes processReleaseChannelMap unused,
  removing.

* Fri Apr 29 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.12-1
- 696970 - disabled localization

* Mon Apr 25 2011 Jan Pazdziora 1.5.11-1
- workaround yum.update_md.UpdateNotice, which in rhel5 does not have
  __setitem__ (msuchy@redhat.com)
- pass pattern to the query (michael.mraka@redhat.com)

* Mon Apr 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.10-1
- 620486 - errata xml caching doesn't work for cloned channels
- fd's for already seen packages should be also closed
- 694735 - export ks files based on ks tree's last_modified
- removing curr_cfps since it is never used
- remove duplicate code

* Fri Apr 15 2011 Jan Pazdziora 1.5.9-1
- use RPMTAG numbers instead of names. (mc@suse.de)
- more weak deps stuff (mc@suse.de)
- implement weak dependencies (mc@suse.de)

* Thu Apr 14 2011 Jan Pazdziora 1.5.8-1
- 604175 - add option --include-custom-channels to satellite-sync which will
  sync all existing custom channels as well (unless -c is used).

* Wed Apr 13 2011 Jan Pazdziora 1.5.7-1
- Need to try cElementTree from xml.etree for RHEL 6.0 and SLES 11.
- made insert work both in postgresql and oracle (michael.mraka@redhat.com)

* Tue Apr 12 2011 Jan Pazdziora 1.5.6-1
- CVE-2010-1171 / 584118 - removing the channel /APP handler.

* Tue Apr 12 2011 Jan Pazdziora 1.5.5-1
- As cElementTree_iterparse is not available on old yums, fallback to
  cElementTree if needed.

* Tue Apr 12 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.4-1
- fixed errata export / import

* Mon Apr 11 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.3-1
- fixed sysdate (PG)
- fixed non-numeric revision (PG)
- unified_diff.next() throws StopIteration when there's no difference

* Mon Apr 11 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.2-1
- import blob directly (PG)
- postgresql doesn't understand for update of column (PG)

* Mon Apr 11 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.1-1
- fixed test_timestamp_3
- fixed packaging after spacewalk/common removal
- put spacewalk/common/* and common/* together
- fixed some more imports from spacewalk.common
- removed implicit import of rhnLog from spacewalk.common
- removed implicit import of rhnConfig from spacewalk.common
- removed duplicated import
- removed implicit import of rhnException from spacewalk.common
- removed implicit import of rhnTB from spacewalk.common
- removed implicit import of rhnException from spacewalk.common
- removed implicit import of RPC_Base from spacewalk.common
- removed implicit import of UserDictCase from spacewalk.common
- remove duplicate PREFIX for locale installation

* Fri Apr 08 2011 Miroslav Suchý 1.4.35-1
- fixed typo (michael.mraka@redhat.com)

* Fri Apr 08 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.34-1
- having table twice in a select is generally not a good idea
- replaced (+) with ANSI left join (PG)
- merged _query_get_file_* which differ only in a single condition

* Fri Apr 08 2011 Jan Pazdziora 1.4.33-1
- implement updateinfo => Errata import for spacewalk-repo-sync (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 1.4.32-1
- fix cs translation (msuchy@redhat.com)

* Fri Apr 08 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.31-1
- replaced (+) with ANSI left join (PG)

* Fri Apr 08 2011 Miroslav Suchý 1.4.30-1
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)
- update copyright years (msuchy@redhat.com)
- download spacewalk.spacewalk-backend from Transifex (msuchy@redhat.com)

* Thu Apr 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.29-1
- fixed variable name

* Wed Apr 06 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.28-1
- 663326 - return doesn't correctly trigger releaseLOCK()
- 663326 - prevent spacewalk-remove-channel to run when spacewalk-repo-sync is
  runnig

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.27-1
- idn_unicode_to_pune() has to return string

* Tue Apr 05 2011 Jan Pazdziora 1.4.26-1
- don't try to update signatures for non-rpm packages
  (michael.mraka@redhat.com)

* Wed Mar 30 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.25-1
- make_evr should accept source parameter
- call transports directly

* Wed Mar 30 2011 Miroslav Suchý 1.4.24-1
- always return RPC data in plain string (utf-8 encoded) (msuchy@redhat.com)
- 683200 - support IDN

* Wed Mar 30 2011 Jan Pazdziora 1.4.23-1
- 688626 - export md5 attribute also for objects without a checksum
  (mzazrivec@redhat.com)
- use xmlrpclib directly (msuchy@redhat.com)

* Wed Mar 23 2011 Jan Pazdziora 1.4.22-1
- fixing stray comma breaking package profile sync (jsherril@redhat.com)
- set envelope From to traceback email (msuchy@redhat.com)
- remove every reference to "up2date --register" - even in comments
  (msuchy@redhat.com)
- remove text "or up2date --register on Red Hat Enterprise Linux 3 or later"
  (msuchy@redhat.com)

* Tue Mar 15 2011 Simon Lukasik <slukasik@redhat.com> 1.4.21-1
- 687885 - do not treat expired token as a fault (slukasik@redhat.com)

* Mon Mar 14 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.20-1
- no more need for special insert when diff is empty
- removed unused _query_get_output_row
- set the blob directly in insert
- support for direct blob insert for oracle
- replaced 'connect by prior' with recursive function in python
- 670793 - don't fail on non-ascii config files
- fixed virtual KVM machines in the webui

* Thu Mar 10 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.19-1
- move server.mo from /usr/share/rhn/ to /usr/share/locale and rename it to
  spacewalk-backend-server
- posgtresql can't lock only one column
- replaced (+) with ansi left join - made ompare files work on postgresql
- 683546 - optparse isn't friendly to translations in unicode
- The file attribute has been renamed to filename

* Tue Mar 08 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.18-1
- Fixed postgresql error in osad

* Fri Mar 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.17-1
- removed blacklists from sync
- rhnBlacklistObsoletes is no more used
- data from blacklist.xml are unused for quite long time
- 679109 - localpath must be defined in except block

* Thu Mar 03 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.16-1
- removed rpm.readHeaderFromFD(), it brokes signatures

* Wed Mar 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.15-1
- merged/moved make_evr() implemetation into a single code
- removed duplicated fetchTraceback()
- The sanitizePath is not used after _populateFromFile removal, removing.

* Wed Mar 02 2011 Jan Pazdziora 1.4.14-1
- Prevent all nulls in a chunk (which are treated as strings) from affecting
  the subsequent chunks.
- Only try to show e.code when the exception is cx_Oracle._Error.

* Mon Feb 28 2011 Jan Pazdziora 1.4.13-1
- removed unused updateChannelFamilyInfo() (michael.mraka@redhat.com)
- removed dead function check_with_seclist() (michael.mraka@redhat.com)
- _populateFromFile() is dead after populateFromFile() removal
  (michael.mraka@redhat.com)
- populateFromFile is dead after createPackageFromFile() removal
  (michael.mraka@redhat.com)
- removed test for already removed createPackageFromFil()
  (michael.mraka@redhat.com)
- removed dead function createPackageFromFile() (michael.mraka@redhat.com)
- removed test for already removed create_channel_families()
  (michael.mraka@redhat.com)
- removed dead function create_channel_families() (michael.mraka@redhat.com)
- removed test for already removed create_channels() (michael.mraka@redhat.com)
- removed dead function create_channels() (michael.mraka@redhat.com)
- removed dead function dbiDate2timestamp() (michael.mraka@redhat.com)

* Mon Feb 28 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.12-1
- reverted bask to RHEL4 rpm read header code 
* Thu Feb 24 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.11-1
- RPMTransaction is dead after RPMReadOnlyTransaction removal
- SharedStateTransaction is dead after RPMReadOnlyTransaction removal
- RPMReadOnlyTransaction() is dead after get_package_header() change
- use size instead of archivesize

* Thu Feb 24 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.10-1
- set timeout after unsuccessful login
- removed unused/unsupported API

* Thu Feb 17 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.9-1
- fixed No module named common
- 677549 - do not require spacewalk-backend-libs in the same version

* Thu Feb 10 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.8-1
- fixed packaging problem

* Thu Feb 10 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.7-1
- fixed leaked filedescriptor in reposync

* Thu Feb 10 2011 Simon Lukasik <slukasik@redhat.com> 1.4.6-1
- Introducing an interface common for rpm, deb and mpm packages
  (slukasik@redhat.com)
- 675912 - fixed typo (michael.mraka@redhat.com)

* Tue Feb 08 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.5-1
- 517173 - unlink packages with different orgid

* Mon Feb 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.4-1
- 675359 - modified attribute is not always present
- l10n: Updates to German (de) translation

* Fri Feb 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.3-1
- 674510 - fixed procedure call (PG)
- 674528 - don't read signatures when there is no rpm (--no-rpms)
- With previous removals, getChannelAttribute is not used anymore, removing.
- The listChannelErrata is dead code by now (after the ISO dumper removal).
- The listChannelPackages is dead code by now (after the ISO dumper removal).
- The getKickstartTree is dead code by now (after the ISO dumper removal).
- With _lookup_last_modified gone, _lookup_last_modified_packages and
  _lookup_last_modified_ks_trees are dead code, removing.

* Fri Feb 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.2-1
- fixed postgresql failure on RHEL6
- 590608 - nullify jabber_ids from previous registrations

* Thu Feb 03 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1
- shortened and narrowed package sync logic
- moved checksum logic into ContentPackage
- yum repo metadata says epoch="0" even if it's NULL
- reformated sql query
- spacewalk-repo-sync should not download package which is already on disk
- fixed duplicated code
- Bumping package versions for 1.4

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 1.3.53-1
- 671464 - prevent unsigned rpms not to be recognized as rpms
  (tlestach@redhat.com)

* Fri Jan 28 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.52-1
- 671465 - fixed signature import

* Thu Jan 27 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.51-1
- 671464 - get right keyid for new Fedora keys
- 671464 - get right keyid for new RHEL6 rpms
- 671464 - although RHEL6 signature is SHA256 gpg it's marked as pgp in rpm
- 671462 - fixed path in debug output

* Wed Jan 26 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.50-1
- fixed error message
- 672277 - made --use-rhn-date and --use-sync-date mutually exclusive
- Report errors even when not -v was specified.

* Wed Jan 26 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.49-1
- fixed AttributeError: ContentSource instance has no attribute 'proxy'
- make osa ping work properly again

* Mon Jan 24 2011 Jan Pazdziora 1.3.48-1
- do not print TB if we get unknown type (msuchy@redhat.com)
- Make rhn-schema-version work on PostgreSQL.

* Fri Jan 21 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.47-1
- 657091 - honor http proxy setting for spacewalk-repo-sync

* Fri Jan 21 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.46-1
- 671466 - use ansi syntax in left join

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.45-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- update .po and .pot files for spacewalk-backend (tlestach@redhat.com)

* Thu Jan 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.44-1
- added spacewalk-data-fsck into rpm
- 670746 - fix malformed query _query_action_verify_packages

* Tue Jan 18 2011 Jan Pazdziora 1.3.43-1
- Split to just two parts.
- 670458 - check password policy only if we are really going to reserve user
  (msuchy@redhat.com)

* Tue Jan 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.42-1
- 650165 - fixed kickstart incremental export

* Mon Jan 17 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.41-1
- rpmbuid failure

* Mon Jan 17 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.40-1
- 650165 - _ChannelDumper should also understand use_rhn_date
- converted comments to docstrings
- do not check throttle within each request
- fixed whitespace

* Tue Jan 11 2011 Jan Pazdziora 1.3.39-1
- Use spacewalk-sql in satwho and satpasswd, thus making it work on PostgreSQL.
- code cleanup: there is no proxy < 4.1 in real word (msuchy@redhat.com)
- I wish python had a simple ternary operator (michael.mraka@redhat.com)

* Wed Jan 05 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.38-1
- 666939 - Insert current_timestamp instead of sysdate
- 666574 - autonomous_transaction not supported by PostgreSQL

* Mon Jan 03 2011 Jan Pazdziora 1.3.37-1
- With fix_url gone, exception InvalidUrlError gets unused, removing.
- 655207 - exit after unsuccessful rpm header read (mzazrivec@redhat.com)
- send with config file, its modified time (msuchy@redhat.com)
- 655207 - print the exception details into stdout (mzazrivec@redhat.com)
- hide cleartext password from traceback (michael.mraka@redhat.com)
- added overall usage summary and flex guest entitlement details to rhn-
  entitlement-report (michael.mraka@redhat.com)

* Thu Dec 30 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.36-1
- fixed a lot of pylint woarnings and errors
- removed dead rhnDatabaseCache
- Allow clients to retrieve debian packages

* Sun Dec 26 2010 Jan Pazdziora 1.3.35-1
- 619083 - we will try not to stringify the types.IntType and types.FloatType.

* Thu Dec 23 2010 Jan Pazdziora 1.3.34-1
- Need to stringify the epoch.
- fix error from 3fcd9f7cf736e8e85994e45d8cd96943ab5a2832 (msuchy@redhat.com)
- move function f_date from rhn_config_management.py to fileutils.py
  (msuchy@redhat.com)

* Wed Dec 22 2010 Jan Pazdziora 1.3.33-1
- Allow clients to retrieve metadata of debian channels (slukasik@redhat.com)

* Tue Dec 21 2010 Jan Pazdziora 1.3.32-1
- Need to alias column with AS for PostgreSQL.
- use difflib instead of external "diff -u" (msuchy@redhat.com)
- move function ostr_to_sym from config_common/file_utils to spacewalk-backend-
  libs (msuchy@redhat.com)
- 634963 - print diffs for "rhncfg-manager diff-revisions" if we differ in
  selinux context, ownership or attributes (msuchy@redhat.com)

* Tue Dec 21 2010 Jan Pazdziora 1.3.31-1
- Need to remove gentree from Makefile as well.

* Mon Dec 20 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.30-1
- removed obsoleted ISO generator code
- 653163 - sort child channels

* Fri Dec 17 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.29-1
- fixed egg-info packaging
- 658422 - rebuild errata cache after reposync finishes

* Thu Dec 16 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.28-1
- fixed %%files for spacewalk-backend-libs

* Thu Dec 16 2010 Jan Pazdziora 1.3.27-1
- Dropping satellite_tools/exporter/exporter.py from the Makefile and %%files.

* Wed Dec 15 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.26-1
- 624092 - update package if pushing using --force and package with same NVREA
  already exist
- no need to lookup dictionary, when we have this information in local variable
- make Table class more debugable

* Wed Dec 15 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.25-1
- removed dead code
- fixed number of pylint reported errors
- fixed Module sat doesn't support our API
- remove block of code from for-loop

* Mon Dec 13 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.24-1
- fixed number of errors reported by pylint
- 652852 - delete related RepoData when updating a package

* Fri Dec 10 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.23-1
- removed read code
- fixed imports
- 655207 - log corrupted package header read
- 653814 - set X-RHN-Satellite-XML-Dump-Version header
- update-packages: update package file list functionality

* Fri Dec 03 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.22-1
- 659348 - import checksum-type correctly
- 659348 - <rhn-package-file> attribute is checksum-type not checksum_type

* Fri Dec 03 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.21-1
- Fault, ResponseError and ProtocolError import has been removed from rpclib
- File import has been removed from rpclib
- fixed column aliases (PG)

* Wed Dec 01 2010 Jan Pazdziora 1.3.20-1
- Ignore the %%check results for now.

* Wed Dec 01 2010 Lukas Zapletal 1.3.19-1
- 644985 - SELinux context cleared from RHEL4 rhncfg-client
- Correcting indentation for configFilesHandler.py
- 656294 - sync channels only from rhn_parent

* Wed Dec 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.18-1
- add BuildRequires: python-hashlib (msuchy@redhat.com)

* Wed Dec 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.17-1
- fix import of xmlrpclib (msuchy@redhat.com)

* Tue Nov 30 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.16-1
- moved db backend selection into a single place
- removed dead RegistrationNumber()
- removed dead code together with its invalid comment
- python 2.4+ (RHEL5+) has hasattr(gettext, 'GNUTranslations') == True

* Mon Nov 29 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.15-1
- fixed unit tests
- run backend unit test in rpm build time

* Thu Nov 25 2010 Lukas Zapletal 1.3.14-1
- Fixing missing method parameter in rhn_config_management
- fixed typo
- don't require server unsubscribe when --skip-channels is used
- added --skip-channels to spacewalk-remove-channel

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.13-1
- removed unused imports

* Wed Nov 24 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.12-1
- 653163 - fix typo (msuchy@redhat.com)

* Tue Nov 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.11-1
- removed unused imports
- remove unused variable
- remove unreachable code
- fixed pylint warnings
- Handle both the empty string (convert it to NULL) and numbers (convert them
  to strings) in epochs.
- added spacewalk-data-fsck

* Mon Nov 22 2010 Lukas Zapletal 1.3.10-1
- Reverting two commits on packages.py
- Revert "Changing time to timestamp in SQL select (PG)"

* Mon Nov 22 2010 Lukas Zapletal 1.3.9-1
- Solving nonexisting Numeric->Varchar case in packages.py (PG)
- Package data are being deleted from view rather than from table (PG)
- Changing time to timestamp in SQL select (PG)

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.8-1
- 650165 - propagate use_rhn_date down to Dumper
- fixed sgml documentation

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.7-1
- 650165 - let user specify which date for incremental export use

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.6-1
- removed redundant code
- merged duplicate code
- 652852 - dirs and links have no checksum
- l10n: Updates to German (de) translation

* Thu Nov 18 2010 Lukas Zapletal 1.3.5-1
- 653163 - sort channels in output of satellite-sync

* Thu Nov 18 2010 Lukas Zapletal 1.3.4-1
- Fixing error in backend spec (unpackaged file)

* Tue Nov 16 2010 Lukas Zapletal 1.3.3-1
- Adding round brackets to evr (multiple commits)

* Tue Nov 16 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- fixed iss
- fixed mod_wsgi configuration
- removed /PKG_UPLOAD leftovers
- l10n: Updates to German (de) translation
- 652613 - set ownership to apache:apache by default
- 652625 - fixed file path

* Mon Nov 15 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- 652815 - satellite-sync speed up
- 652815 - don't resync packages with wrong path when called with --no-rpms

* Sun Nov 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.72-1
- speed up satellite-sync - skip packages we already processed
- speed up satellite-sync - download and parse only missing packages
- kickstart files should be processed one by one
- replaced hashPackageId() with hash_object_id()

* Fri Nov 12 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.71-1
- fixed import of removed function, fixed inversed set operator
- removed unnecessary double assigning

* Fri Nov 12 2010 Lukas Zapletal 1.2.70-1
- Adding missing SQL AS keywords (several patches)
- do not raise exception in exception in case stream is None

* Thu Nov 11 2010 Lukas Zapletal 1.2.69-1
- Adding missing AS keyword to SELECT clause 
- Force EVR to be strings in the backend 

* Thu Nov 11 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.68-1
- removed dead unique() and intersection()
- replaced own intersection() and unique() with faster builtin set operations

* Thu Nov 11 2010 Lukas Zapletal 1.2.67-1
- Fixing space in SQL bind parameter 
- Keyword MINUS is not recognized by PostgreSQL 
- Fixing indentation in spacewalk-remove-channel 
- l10n: Updates to German 
- Revert "l10n: Updates to Swedish 
- l10n: Updates to Swedish 

* Thu Nov 11 2010 Jan Pazdziora 1.2.66-1
- Update copyright years in backend.

* Wed Nov 10 2010 Jan Pazdziora 1.2.65-1
- use ansi syntax in left join (mzazrivec@redhat.com)

* Wed Nov 10 2010 Jan Pazdziora 1.2.64-1
- removed dead _lookup_last_modified() (michael.mraka@redhat.com)
- removed dead _generate_executemany_data() (michael.mraka@redhat.com)

* Wed Nov 10 2010 Jan Pazdziora 1.2.63-1
- fixed Exception exceptions.AssertionError: <exceptions.AssertionError
  instance at 0x2b4a22e18368> in <bound method Syncer.__del__ of
  <spacewalk.satellite_tools.satsync.Syncer instance at 0x2b4a22e1a0e0>>
  ignored (michael.mraka@redhat.com)

* Tue Nov 09 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.62-1
- fixed exporter issues caused by code removal

* Mon Nov 08 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.61-1
- modified satsync to use uniform interface for disk and wire dumps

* Sat Nov 06 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.60-1
- merged duplicated code in kickstart_guest.py
- merged "attempt to avoid giving out the compat-* packages" blocks
- merged packages to list translation blocks into function
- merged duplicated file checking code into procedure
- merged action code into a single function
- reused code for simple dump_* functions
- merged the same query originaly defined in two places
- merged duplicated code from _add_dists() and _update_dists()
- merged duplicated code in list_packages_sql() and list_all_packages_sql()
- merged duplicated code from list_channel_families() and list_channels()
- SourcePackageContainer can now also reuse diskImportLibContainer
- set ignoreUploaded = 1 in SourcePackageImport by default
- PackageContainer can now also reuse diskImportLibContainer
- set ignoreUploaded = 1 in PackageImport by default
- merged endContainerCallback() definiton into superclass
- merged get_*_handler() code
- redefined SourcePackageContainer via SyncHandlerContainer
- redefined PackageContainer via SyncHandlerContainer
- redefined ShortPackageContainer via SyncHandlerContainer
- redefined KickstartableTreesContainer via SyncHandlerContainer
- redefined ErrataContainer via SyncHandlerContainer
- created general SyncHandlerContainer and redefined ChannelContainer using the
  general one
- removed duplicated _send_headers_rpm()
- fixed XML_Dumper namespace
- reused BaseQueryDumper() fore some more classes
- merged trivial set_iterator() classes into BaseQueryDumper()
- merged checksum handling into BaseChecksumRowDumper()
- reused BaseSubelementDumper() for some more classes
- merged a lot of classes which had differed only in dump_sublement() method
- _get_kickstartable_trees() rewritten via _get_ids()
- merged _get_package_ids() and _get_errata_ids()
- merged rhnSQL.prepare() and h.execute() calls which differs only in query and
  args
- merged duplicated code for writing dumps
- merged id verification code
- fixed typo
- merged _get_key()
- call original dump_subelement() instead of creating _dump_subelement() in
  every subclass
- DatabaseStatement() does exactly what rhnSQL does; removing
- fixed typos
- merged NonAuthenticatedDumper.dump_kickstartable_trees() back to
  XML_Dumper.dump_kickstartable_trees()
- h is used only in verify_errata=True branch
- merged NonAuthenticatedDumper.dump_errata() back to XML_Dumper.dump_errata()
- h is used only in verify_packages=True branch
- merged NonAuthenticatedDumper._packages() back to XML_Dumper._packages()
- added method stubs to main XML_Dumper class
- removed code already commented out
- merged NonAuthenticatedDumper.dump_channel_packages_short() back to
  XML_Dumper.dump_channel_packages_short()
- merged dumper._ChannelsDumper changes back to exportLib._ChannelDumper

* Thu Nov 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.59-1
- merged import / download loop code into procedure
- merged several Traceback blocks
- merged StreamProducer setup into its constructor
- moved channel printing code to _printChannel()
- moved progress bar blocks into function

* Thu Nov 04 2010 Lukas Zapletal 1.2.58-1
- Adding missing colon in channelImport.py 

* Wed Nov 03 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.57-1
- merged simple sql fetches into a single command
- merged channelManagePermission() and revokeChannelPermission()
- every function calls get('session') and _validate_session(session)
- merged duplicated code into _get_file_revision()
- moved duplicate code for 'dists' and 'release' to a procedure

* Wed Nov 03 2010 Lukas Zapletal 1.2.56-1
- Adding one parameter to to_number functions to be PG compatible
- Fixing query in dumper to be PostgreSQL compatible 
- Rewriting SQL JOIN to ANSI syntax in test-dump-channel 
- Rewriting SQL JOIN to ANSI syntax in exporter 
- Rewriting SQL JOIN to ANSI syntax in disk_dumper 
- Rewriting SQL JOIN to ANSI syntax in spacewalk-remove-channel
- 644239 - do not check minor version of xml_dump_version 

* Wed Nov 03 2010 Jan Pazdziora 1.2.55-1
- fixed couple of root_dir leftovers from commit
  6a6e58f490b97f941687b56f38e29aad1d6ed69f (michael.mraka@redhat.com)

* Tue Nov 02 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.54-1
- remove RootDir (msuchy@redhat.com)
- fixing package push error 'Not all variables bound', 'ORGID'
  (jsherril@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 1.2.53-1
- remove RootDir (msuchy@redhat.com)
- fixing package push error 'Not all variables bound', 'ORGID'
  (jsherril@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 1.2.52-1
- Update copyright years in backend/.
- allow to enable/disable QOS in config file (msuchy@redhat.com)
- do not throttle by default (msuchy@redhat.com)
- update .po and .pot files for spacewalk-backend

* Tue Nov 02 2010 Jan Pazdziora 1.2.51-1
- fixed Error importing xp: No module named handlers.app.packages
  (michael.mraka@redhat.com)

* Mon Nov 01 2010 Jan Pazdziora 1.2.50-1
- Use current_timestamp instead of SYSDATE.
- fixing package upload, to pass in checksums (jsherril@redhat.com)
- fixing wsgiHandler to look in new location for apacheServer
  (jsherril@redhat.com)
- Use current_timestamp with numtodsinterval instead of sysdate.
- Fixing decimal2intfloat -- the function is passed str, not decimal.Decimal;
  we just try to convert to int or float.
- The conversion should take place both for remote and local connections.

* Mon Nov 01 2010 Jan Pazdziora 1.2.49-1
- Use _buildExternalValue to properly sanitize Unicode strings.

* Mon Nov 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.48-1
- 612581 - take ownership of /usr/lib/python2.7/site-packages/spacewalk/wsgi
  (msuchy@redhat.com)
- 612581 - change egrep to grep -E (msuchy@redhat.com)
- even getPackageChecksum() and getPackageChecksumBySession() can be merged
  into a single function (michael.mraka@redhat.com)
- fixed typo and syntax error (michael.mraka@redhat.com)
- merged getSourcePackageChecksum() into getPackageChecksum()
  (michael.mraka@redhat.com)
- merged getSourcePackageChecksumBySession() to getPackageChecksumBySession()
  (michael.mraka@redhat.com)
- merged duplicated code into _get_package_checksum()
  (michael.mraka@redhat.com)
- reordered commands to put checksum stuff together (michael.mraka@redhat.com)
- merged 2 calls with just different arguments (michael.mraka@redhat.com)
- moved X-RHN-Action stuff into one place (michael.mraka@redhat.com)
- moved duplicated code to a function (michael.mraka@redhat.com)

* Fri Oct 29 2010 Jan Pazdziora 1.2.47-1
- For Function in PostgreSQL, we have to not just execute, but also fetch the
  value to return.
- Move the SQL munging messages to debug level 6, to be above the "Executing
  SQL" message level.

* Fri Oct 29 2010 Jan Pazdziora 1.2.46-1
- Removing select with rownum. It seems not that useful anyway.

* Fri Oct 29 2010 Jan Pazdziora 1.2.45-1
- Function fix_url not used anywhere, removing; removing its tests as well.
- The common.rhn_memusage is also only used by tests, moving to test/attic.
- Class CVE does not seem to be used, removing.
- Moved server.rhnServerGroup to test/attic.
- Moved server.rhnActivationKey to test/attic, not shipped.
- Method _execute_next does not seem to be used, removing.
- Method _do_snapshot does not seem to be used in Satellite, removing.
- Method _count_channel_servers not used in _channelPackageSubscription in
  Satellite, removing.
- Method checkSatEntitlement not used in Satellite code, hosted only, removing.
- Method updateAndPrint not used, removing.
- Method addToAndPrint not used, removing.
- Method addFromPackageBatch not used, removing.
- The comment says we do not want to use rpmLabelCompare, let us just remove
  it.
- The method _handle_virt_guest_params was commented out for ages; the
  virt_type processing is done in create_system anyway.

* Fri Oct 29 2010 Jan Pazdziora 1.2.44-1
- /XP handler defines just 4 calls identical to /APP calls
  (michael.mraka@redhat.com)
- removed unused class WarningParseException (michael.mraka@redhat.com)
- removed unused class VirtualizationListenerError (michael.mraka@redhat.com)

* Wed Oct 27 2010 Jan Pazdziora 1.2.43-1
- Class UpdateSlots unused, removing.
- Exception SatCertNoFreeEntitlementsException not used, removing.
- Classes _KickstartTreeTypeDumper and _KickstartInstalTypeDumper do not seem
  to be used, removing.
- Exceptions IncompleteLimitInfo and IncompleteLimitInfo* not used, removing.
- Exception genServerCertError not used, removing.
- Exception ForceNotSpecified not used, removing.
- Class ConfigFileMissingStatInfo not used, removing.
- The rhn_timer.py does not seem to be used anywhere, removing.
- Class SourcePackageFile does not seem to be invoked, removing.
- Class ServerGroupTypeDumper not used anywhere, removing.

* Wed Oct 27 2010 Lukas Zapletal 1.2.42-1
- Fixing c89830b90cb36bd6a79641553c5091c57af8fb8e typo 

* Wed Oct 27 2010 Lukas Zapletal 1.2.41-1
- Fixing typo in driver_postgresql.py 
- Class ReleaseChannelMapImport does not seem to be called, removing.
- fixed NameError: name 'SourcePackageImport' is not defined
- removed redundant empty tagMaps 
- reused load_sql
- XXX: not used currently; removing 

* Wed Oct 27 2010 Lukas Zapletal 1.2.40-1
- In PostgreSQL NUMERIC types are returned as int or float now
- Rewritten DECODE to ANSI CASE-WHEN syntax for yum 
- Class FileWireSource does not seem to be used, removing.
- Class ChannelProductsDumper does not seem to be used, removing.
  

* Wed Oct 27 2010 Jan Pazdziora 1.2.39-1
- Previous commit leaves __single_query unused, removing.
- Six find_by_* functions do not seem to be called by our code, removing.
- Removal of spacewalk-backend-upload-server makes source_match not called
  anywhere, removing.
- The _timeString0 function looks unused, we shall consider it a dead code.
- The sql_exception_text utility function never called, seems like a dead code.
- The sortHeaders is not called in our code base, removing.
- That setup_old function in test does not seem to be called, we better remove
  it.
- If remove_listener not in our code, remove(remove_listener).
- Function register_system not called, removing.
- Method parse_url not used in backend, removing as dead code.
- The method _line_value does not seem to be used in the test.
- Removing get_kickstart_label which does not seem to be used anywhere.
- Removing function create_user from test.
- After removal of __check_unique_email_db, fault 102 is not longer used.
- Method check_unique_email (and __check_unique_email_db) not used anywhere,
  removing.
- Exception PackageConflictError was only used in check_package_exists,
  removing.
- Removal of spacewalk-backend-upload-server makes check_package_exists unused,
  removing.
- Method channels_for_org not called, removing as dead code.
- Method build_sql_args is not called, removing.
- Method auth_org_access is not used in our code, removing as dead code.

* Mon Oct 25 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.38-1
- 623966 - add man page for rhn-entitlement-report
- 623964 - add man page for update-packages
- 623967 - write man page for spacewalk-update-signatures
- if package is not on disk do not throw TB

* Mon Oct 25 2010 Jan Pazdziora 1.2.37-1
- The psycopg2 seems to be handling unicode strings just fine.
- packages_cursor() and _source_packages_cursor() are dead; removing
  (michael.mraka@redhat.com)
- errata_cursor() and _errata_cursor() are dead; removing
  (michael.mraka@redhat.com)

* Mon Oct 25 2010 Jan Pazdziora 1.2.36-1
- Reset the System Currency multipliers to the original values
  (colin.coe@gmail.com)
- Need to truncate the values upon select as well.

* Fri Oct 22 2010 Jan Pazdziora 1.2.35-1
- Remove duplicates from package changelog.
- Load the appropriate database backend.
- Replace sysdate with current_timestamp.
- Need to avoid inserting empty strings, we use NULL (None) instead.

* Fri Oct 22 2010 Jan Pazdziora 1.2.34-1
- Put import sys back, needed for sys.argv.

* Fri Oct 22 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.33-1
- 612581 - removing /usr/share/rhn from PYTHONPATH
- 612581 - fixing dynamic import

* Thu Oct 21 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.32-1
- 612581 - move python modules from /usr/share/rhn to python site-packages

* Wed Oct 20 2010 Jan Pazdziora 1.2.31-1
- Changing backend (satellite-sync) to use the new rhnPackageChangeLogRec and
  rhnPackageChangeLogData tables.
- autonomous_transaction not supported by PostgreSQL.

* Tue Oct 19 2010 Jan Pazdziora 1.2.30-1
- check_package_spec() already defined in handlers/xmlrpc/up2date.py
  (michael.mraka@redhat.com)
- startswith(), endswith() are builtin functions since RHEL4
  (michael.mraka@redhat.com)
- _delete_channel() is dead after delete_channel() removal
  (michael.mraka@redhat.com)
- _delete_channel_family() is dead after delete_channel_families() removal
  (michael.mraka@redhat.com)
- removed delete_channel_families() -  it is used only in self unit tests
  (michael.mraka@redhat.com)
- removed delete_channel() - it is used only in self unit test
  (michael.mraka@redhat.com)
- Insert current_timestamp instead of sysdate.
- Move the debugging print to log_debug.
- Use numtodsinterval instead of the arithmetics.
- Revert "Using the interval syntax instead of the arithmetic."

* Mon Oct 18 2010 Jan Pazdziora 1.2.29-1
- Using the interval syntax instead of the arithmetic.
- If the epoch is an empty string, make it None (NULL), to avoid bad surprise
  in PostgreSQL later.
- Replace sysdate with current_timestamp in insert.
- If the checksum value is empty string, do not try to look it up.

* Mon Oct 18 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.28-1
- remove package spacewalk-backend-upload-server

* Mon Oct 18 2010 Lukas Zapletal 1.2.27-1
- Constraint vn_rhnservernetinterface_broadcast fixed (PostgreSQL)

* Mon Oct 18 2010 Jan Pazdziora 1.2.26-1
- Fix the placeholder tagging.
- Even when handling evrs, we do not want to store empty strings, we want to
  store NULLs because that is what Oracle will make of them anyway.
- Not only we do not want to convert NULLs to empty strings, we have to convert
  empty strings to NULLs.
- Make the comps-updating block PostgreSQL compatible.
- Add processing of the params parameter for anonymous PL/pgSQL blocks.
- The tag in dollar quoting cannot start with number, which can happen with
  SHA1s from time to time.
- Reserved words problem for Postgresql fixed correctly (lzap+git@redhat.com)

* Fri Oct 15 2010 Jan Pazdziora 1.2.25-1
- Reserved words problem for Postgresql fixed (lzap+git@redhat.com)
- Now that we have unique key on rhnChannelComps(channel_id), we can simplify
  the select which searches for the comps record.
- Prevent satellite-sync from inserting empty strings when it means to insert
  NULLs.

* Wed Oct 13 2010 Lukas Zapletal 1.2.24-1
- Procedure call now general (update_needed_cache) in backend
- Vn_constriant violation in Postgres (vn_rhnpackageevr_epoch)
- Postgres reserved word fix 
- Vn_constriant violation in Postgres 
- Sysdate changed to current_timestamp 
- ANSI syntax for outer join during system registration 
- Debug log from postgresql backend driver removed 
- Postgres python backend driver functions support 
- Postgres savepoint support in backend code 

* Wed Oct 13 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.23-1
- speed up queries
- deleted unused code
- 642142 - Fix to make sat-activate zero out ents that are not in the certificate

* Tue Oct 12 2010 Lukas Zapletal 1.2.22-1
- Sysdate replaced with current_timestamp during client reg
- Use e.pgerror instead of e.message for psycopg2.OperationalError.

* Tue Oct 12 2010 Lukas Zapletal 1.2.21-1
- Decode function replaced with case-when in backend

* Tue Oct 12 2010 Jan Pazdziora 1.2.20-1
- Load the appropriate backend and initialize it (twice).
- Load the appropriate backend and initialize it.
- 640526: Fixed a missed logic for entitlement  purging (paji@redhat.com)

* Thu Oct 07 2010 Jan Pazdziora 1.2.19-1
- We cannot insert empty string and depend on the database to convert it to
  null for "is null" to work -- this will fail on PostgreSQL.
- Fix the logic of the adjusted_port.
- Load the appropriate backend and initialize it (rhnPackageUpload.py).
- The AUTONOMOUS_TRANSACTION does not seem to be needed, plus it is not
  supported in PostgreSQL; removing.
- fixing stray comma (jsherril@redhat.com)
- log_debug is not used in sql_base.py, removing the import.

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.18-1
- replaced local copy of compile.py with standard compileall module
- removed a lot of dead code
- 637155 - pad --start-date, --end-date with zeros

* Thu Sep 23 2010 Shannon Hughes <shughes@redhat.com> 1.2.17-1
- modify reposync logrotate to include channel label log files
  (shughes@redhat.com)
- fixed spec after file rename (michael.mraka@redhat.com)

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.16-1
- 634559 - fixed component name

* Thu Sep 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.15-1
- 634280 - errata should remain associated with already synced channels
- 634263 - allow guests to register across orgs

* Mon Sep 20 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.14-1
- 627566 - update package checksum with value found in database
- 629986 - updating channels last synced time from spacewalk-repo-sync
- initCFG('server') before initDB

* Tue Sep 14 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.2.13-1
- fixing brokeness with spacewalk-update-signatures
- --db option is no longer valid

* Fri Sep 10 2010 Justin Sherrill <jsherril@redhat.com> 1.2.12-1
- 626764 - adding man page for spacewalk-repo-sync (jsherril@redhat.com)
- style fixes (jsherril@redhat.com)
- 571355 - fixing issue where packages that were physically deleted are not re-
  downloaded during a reposync (jsherril@redhat.com)

* Wed Sep 08 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.11-1
- 555046 - when installtime change, update package in db
- create string representation of object dbPackage for better debugging
- 555046 - use constants instead hardcoded values
- fixing common typo pacakges -> packages (tlestach@redhat.com)
- remove oval files during errata import (mzazrivec@redhat.com)

* Mon Sep 06 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.10-1
- 573630 - reused pl/sql implementation of update_needed_cache in python
- fixing broken string substitiution (wrong number of arguments)

* Mon Aug 30 2010 Justin Sherrill <jsherril@redhat.com> 1.2.9-1
- 626749 - fixing spacewalk-repo-sync to ignore source packages
  (jsherril@redhat.com)
- adding missing commit to make repo generation after reposync work again
  (jsherril@redhat.com)
- 579588 - adding a more stern warning message to activating a ceertificate of
  a different version (jsherril@redhat.com)
- 593896 - Moved Kickstart Parition UI logic (paji@redhat.com)

* Tue Aug 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.8-1
- fixed update_errata_cache_by_channel job for channels in NULL org

* Thu Aug 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.7-1
- 623699 - systemid is not mandatory for ISS
- 624732 - use original config file names
- localization of satellite-sync
- 591050 - satellite sync report type of disk dump

* Tue Aug 17 2010 Justin Sherrill <jsherril@redhat.com> 1.2.6-1
- fixing small mistake where the wrong variable name was 
  used (jsherril@redhat.com)

* Tue Aug 17 2010 Justin Sherrill <jsherril@redhat.com> 1.2.5-1
- 619337 - making it so that repodata will be scheduled for regeneration on all
  channels that a package is in.  This will be ignored if not needed (i.e. last
  modified date is not updated) (jsherril@redhat.com)

* Tue Aug 17 2010 Shannon Hughes <shughes@redhat.com> 1.2.4-1
- cartesian product is seldomly wanted (michael.mraka@redhat.com)
- Revert "612581 - move all python libraries to standard python path"
  (msuchy@redhat.com)

* Fri Aug 13 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.3-1
- 612581 - move all python libraries to standard python path
  (msuchy@redhat.com)
- 612581 - for every Requires(pre) add pure Requires (msuchy@redhat.com)
- 612581 - removing notes (msuchy@redhat.com)
- 612581 -  use %%{__python} macro rather then direct call of python
  (msuchy@redhat.com)
- 612581 - use %%global instead of %%define (msuchy@redhat.com)
- 612581 - use macro only for F12/RHEL-5 (msuchy@redhat.com)
- 612581 - use BR python2-devel rather then python-devel (msuchy@redhat.com)
- 589524 - select packages, erratas and kickstart trees according to import
  date (michael.mraka@redhat.com)
- Revert "589524 - select packages, erratas and kickstart trees according to
  import date" (michael.mraka@redhat.com)

* Wed Aug 11 2010 Jan Pazdziora 1.2.2-1
- Check if the function used for the anonymous block already exists -- do not
  attempt to create it again.
- Quote percent char to avoid it from being considered as a placeholder by
  psycopg2.
- With PostgreSQL, the lob value that we get is already a read-only buffer;
  let's stringify it.
- Change the syntax in backend to match python-psycopg2.
- If host is none (we are using the Unix domain socket), we should not pass the
  host parameter at all.
- Replace pgsql by psycopg2 which should give us live upstream again.

* Wed Aug 11 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.1-1
- 614345 - fixed ISS server component name
- 591050 - add meta information to dump

* Tue Aug 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.48-1
- Revert "591050 - add meta information to dump" (msuchy@redhat.com)

* Tue Aug 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.47-1
- l10n: Updates to German (de) translation (ttrinks@fedoraproject.org)
- 591050 - add meta information to dump (msuchy@redhat.com)
- dead code - we set end_date, but later we always use self.end_date. Dtto for
  start_date (msuchy@redhat.com)
- code style - expand tabs to whitespace (msuchy@redhat.com)

* Mon Aug 09 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.46-1
- l10n: Updates to Swedish (sv) translation (goeran@fedoraproject.org)
- l10n: German translation added (gkoenig@fedoraproject.org)

* Tue Aug 03 2010 Partha Aji <paji@redhat.com> 1.1.45-1
- got the rhncfg manager diff revisions to work with symlinks (paji@redhat.com)
- Fixed config_mgmt diff stuff (paji@redhat.com)

* Fri Jul 30 2010 Jan Pazdziora 1.1.44-1
- It is dbname without underscore for PostgreSQL.
- 619699 - do not blow out if we get unicode string (msuchy@redhat.com)

* Thu Jul 29 2010 Partha Aji <paji@redhat.com> 1.1.43-1
- Config Management schema update + ui + symlinks (paji@redhat.com)
- send only actions which we are able to cache (msuchy@redhat.com)
- add comment to function (msuchy@redhat.com)
- 577868 - adding proper handling of multiline key/value values
  (jsherril@redhat.com)
- 582646 - making spacewalk-remove-channel communicate better about what child
  channels a channel has (jsherril@redhat.com)

* Fri Jul 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.42-1
- unified database connection information
- rename rhn_server_*.conf files
- 617188 - fixed name of Swedish translation file

* Tue Jul 20 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.41-1
- fix /var/log/rhn permissions
- add missing import

* Mon Jul 19 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.40-1
- add logging hooks (msuchy@redhat.com)
- fix sql syntax error (msuchy@redhat.com)

* Mon Jul 19 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.39-1
- fix syntax error (msuchy@redhat.com)

* Fri Jul 16 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.38-1
- fix build error (msuchy@redhat.com)
- 615298 - if rpm install time is None, do not pass it to time.localtime
  (msuchy@redhat.com)

* Fri Jul 16 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.37-1
- removed handlers/app/rhn_mpm

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.36-1
- check if staging_content_enabled is enabled for our organization

* Thu Jul 15 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.35-1
- fix syntax errors (assignments, negations)

* Thu Jul 15 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.34-1
- fix requires for spacewalk-backend-sql
- 614667 - provide better error message

* Wed Jul 14 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.33-1
- define new parameter dry_run for all actions (msuchy@redhat.com)
- basic framework for prefetching content from spacewalk (msuchy@redhat.com)
- 604094 - fixing issue where package profile sync would not be scheduled if
  associated with a kickstart profile (jsherril@redhat.com)
- code cleanup - remove unused function schedule_virt_pkg_install
  (msuchy@redhat.com)
- Cleaned up web_customer, rhnPaidOrgs, and rhnDemoOrgs inaddition to moving
  OrgImpl- Org. These are unused tables/views/columns.. Added upgrade scripts
  accordingly (paji@redhat.com)
- adding missing import for inter-satellite-sync (jsherril@redhat.com)
- fixing import errors for inter-satellite sync (jsherril@redhat.com)

* Mon Jul 12 2010 Justin Sherrill <jsherril@redhat.com> 1.1.32-1
- fixing missing import (jsherril@redhat.com)

* Mon Jul 12 2010 Justin Sherrill <jsherril@redhat.com> 1.1.31-1
- 613585 - fixing inter satellite sync and removing HandlerWrap
  (jsherril@redhat.com)
- fixing missing import (jsherril@redhat.com)

* Fri Jul 09 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.30-1
- create virtual package spacewalk-backend-sql-virtual (msuchy@redhat.com)
- removed code which called rhn_ep package because rhn_ep had vanished long
  time ago (michael.mraka@redhat.com)

* Thu Jul 08 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.29-1
- remove shebang from handlers/xmlrpc/get_handler.py (msuchy@redhat.com)
- provide Provides: (msuchy@redhat.com)
- macros should not be used in changelog (msuchy@redhat.com)

* Thu Jul 08 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.28-1
- move %%defattr before %%doc (msuchy@redhat.com)
- rename /usr/share/rhn/satellite_tools/updateSignatures.py to /usr/bin
  /spacewalk-update-signatures (msuchy@redhat.com)
- add epoch to Provides (msuchy@redhat.com)
- logrotate scripts should have noreplace flag (msuchy@redhat.com)
- forgot to save file after resolving conflict during rebase of
  7d48d4d7ab096551c7a53c7670c76ec83c441303 (msuchy@redhat.com)
- wrap long lines (msuchy@redhat.com)
- remove shebang from modules (msuchy@redhat.com)
- fix spelling error (msuchy@redhat.com)
- add logrotate entry for reposync.log (msuchy@redhat.com)
- fix not standard dir permisions (msuchy@redhat.com)
- fix Makefile - pack new renamed logrotate files (msuchy@redhat.com)
- rename logrotate/rhn_server_satellite to logrotate/spacewalk-backend-tools
  (msuchy@redhat.com)
- rename logrotate/rhn_package_push to logrotate/spacewalk-backend-package-
  push-server (msuchy@redhat.com)
- rename logrotate/rhn_package_upload to logrotate/spacewalk-backend-upload-
  server (msuchy@redhat.com)
- rename logrotate/rhn_server to logrotate/spacewalk-backend-server
  (msuchy@redhat.com)
- rename logrotate/rhn_sat_export_internal to logrotate/spacewalk-backend-iss-
  export (msuchy@redhat.com)
- rename logrotate/rhn_server_sat to logrotate/spacewalk-backend-iss
  (msuchy@redhat.com)
- rename logrotate/rhn_config_management_tool to logrotate/spacewalk-backend-
  config-files-tool (msuchy@redhat.com)
- rename logrotate/rhn_config_management to logrotate/spacewalk-backend-config-
  files (msuchy@redhat.com)
- rename logrotate/rhn_server_applet to logrotate/spacewalk-backend-applet
  (msuchy@redhat.com)
- rename logrotate/rhn_server_app to logrotate/spacewalk-backend-app
  (msuchy@redhat.com)
- rename logrotate/rhn_server_xmlrpc to logrotate/spacewalk-backend-xmlrpc
  (msuchy@redhat.com)
- rename ./logrotate/rhn_server_xp to logrotate/spacewalk-backend-xp
  (msuchy@redhat.com)
- set default config files readable by all users (msuchy@redhat.com)
- add to license PYTHON since we use compile.py (msuchy@redhat.com)
- add licensing files to %%doc (msuchy@redhat.com)
- spelling error (msuchy@redhat.com)
- make config files readable (msuchy@redhat.com)
- 453457 - extract from package spacewalk-backend-sql new packages spacewalk-
  backend-sql-oracle and spacewalk-backend-sql-postgresql (msuchy@redhat.com)

* Wed Jul 07 2010 Justin Sherrill <jsherril@redhat.com> 1.1.27-1
- 612163 - fixing issue with satellite sync where rh-public channel family
  information is not set properly (jsherril@redhat.com)
- create repogen after set of packages pushed instead of individually
  (shughes@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.26-1
- We need to force port into integer. (jpazdziora@redhat.com)
- adding new virtualization strings for RHEL 6 (jsherril@redhat.com)
- bug fixing for reposync (shughes@redhat.com)
- modified reposync script to handle 1:many channel content source objects
  (shughes@redhat.com)

* Wed Jun 30 2010 Jan Pazdziora 1.1.25-1
- We now call prepare with params for PostgreSQL, for Oracle we will take the
  parameter and ignore it.
- fixing small issue with wsgi handler where status was not a string
  (jsherril@redhat.com)
- adding removed option during alphabetization of command line arguments
  (jsherril@redhat.com)

* Tue Jun 29 2010 Jan Pazdziora 1.1.24-1
- We want to pull the backend type from the config file as well.
- Add initial support for anonymous PL/pgSQL blocks.
- adding flex guest detection at registration time (jsherril@redhat.com)
- few fixes for rhn cert activation, cert activation now works and populates
  max_members correctly, but not populating fve_max_members yet
  (jsherril@redhat.com)
- a few fixse for sat cert handling (jsherril@redhat.com)
- first attempt at adding flex guest to sat cert processing
  (jsherril@redhat.com)
- 608677 - export rhnChannelProduct information into a channel dump
  (mzazrivec@redhat.com)
- 608657 - if --consider-full is set, interpret disk dump as full export,
  otherwise it is used as incremental dump (msuchy@redhat.com)
- 608657 - add option --consider-full to man page of satellite-sync and to
  output of --help (msuchy@redhat.com)
- sort command line parameters alphabeticaly (msuchy@redhat.com)

* Mon Jun 28 2010 Jan Pazdziora 1.1.23-1
- Remove a debugging print.
- do need to check date, we can get anything (msuchy@redhat.com)
- evr should be parsed from the end (msuchy@redhat.com)
- Parse the default_db; the DNS part (the one after @) is DBI-style connect
  string.

* Fri Jun 18 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.22-1
- fix rpmlint warning (msuchy@redhat.com)
- fix rpmlint warning (msuchy@redhat.com)
- fix rpmlint warning (msuchy@redhat.com)
- remove shebang from module (msuchy@redhat.com)
- remove shebang from module (msuchy@redhat.com)
- remove shebang from module (msuchy@redhat.com)
- remove shebang from module (msuchy@redhat.com)
- fixed wording for incompatible checksum error (michael.mraka@redhat.com)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)

* Wed Jun 09 2010 Justin Sherrill <jsherril@redhat.com> 1.1.21-1
- 600323 - fixing checksums KeyError with rhnpush and channel association
  (jsherril@redhat.com)
- fix broken solaris package downloads
- 600323 - fixing checksums KeyError with rhnpush (jsherril@redhat.com)

* Tue Jun 08 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.20-1
- more exporter code cleanup
- 589524 - select packages, erratas and kickstart trees according to import

* Thu Jun 03 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.19-1
- removed duplicated code from export routines
* Mon May 31 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.18-1
- fixed package build error

* Fri May 28 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.17-1
- removed code relying on dead rhnDumpSnapshot* tables

* Thu May 27 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.16-1
- block old spacewalk from syncing sha256 channels via ISS
- improved performance of linking packages during satellite-sync

* Wed May 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.15-1
- 589299 - excluded checksum_list from headers

* Tue May 18 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.14-1
- satellite-sync optimization

* Fri May 14 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.13-1
- fixed performance issue in satellite-sync
- update po files
- l10n: russian added

* Tue May 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.12-1
- modified satellite-sync to new xml dumps

* Mon May 03 2010 Jan Pazdziora 1.1.11-1
- 585233 - the has-comps attribute will no longer be used by hosted.
- add dependency information for DEB packages (lukas.durfina@gmail.com)

* Fri Apr 30 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.10-1
- Support for uploading deb packages (lukas.durfina@gmail.com)

* Fri Apr 30 2010 Jan Pazdziora 1.1.9-1
- 585233 - use log2stderr instead of the (debugging) print.
- 585233 - fix the logic handling has_comps and missing comps_last_modified.
- implemented <checksums> in <rhn-package-short> (michael.mraka@redhat.com)

* Thu Apr 29 2010 Jan Pazdziora 1.1.8-1
- 585233 - replace has-comps with rhn-channel-comps-last-modified.
- 585233 - use the rhn-channel-comps-last-modified element instead of boolean
  has-comps.
- fixed HandlerWrap class implementation from commit
  356bddff66b3f7c50ff06f7062d8d111c3f189ff (michael.mraka@redhat.com)
- rhnLib's timestamp2dbtime not used anywhere, removing as dead code.
- The checksumtype is now called checksum_type.

* Tue Apr 27 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.6-1
- implemented dump version 3.6 in rhn-satellite-exporter 

* Tue Apr 27 2010 Jan Pazdziora 1.1.5-1
- 585233 - add support for syncing comps data.

* Thu Apr 22 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.4-1
- networkRetries is set in /etc/sysconfig/rhn/up2date and not in rhn.conf

* Tue Apr 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- fixing build error on RHEL 5

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- merge 2 duplicate byterange module to common.byterange
- bumping spec files to 1.1 packages

