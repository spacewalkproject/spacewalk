%global rhnroot %{_prefix}/share/rhn
%global rhnconfigdefaults %{rhnroot}/config-defaults
%global rhnconf %{_sysconfdir}/rhn
%global m2crypto m2crypto

%if 0%{?rhel} && 0%{?rhel} < 6
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}
%endif

%if 0%{?fedora} >= 23 || 0%{?suse_version} > 1320 || 0%{?rhel} >= 8
%{!?python3_sitelib: %global python3_sitelib %(%{__python3} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%global python3rhnroot %{python3_sitelib}/spacewalk
%global build_py3 1
%endif

%if 0%{?fedora} || 0%{?rhel} >= 7
%{!?pylint_check: %global pylint_check 1}
%endif

%if 0%{?fedora} || 0%{?rhel}
%global apacheconfd %{_sysconfdir}/httpd/conf.d
%global apache_user apache
%global apache_group apache
%global apache_pkg httpd
%endif

%if 0%{?suse_version}
%{!?pylint_check: %global pylint_check 0}
%global apacheconfd %{_sysconfdir}/apache2/conf.d
%global apache_user wwwrun
%global apache_group www
%global apache_pkg apache2
%global m2crypto python-m2crypto
%endif

%if  0%{?fedora} >= 28  || 0%{?rhel} >= 8
%global python_prefix python2
%else
%global python_prefix python
%endif

%global pythonrhnroot %{python_sitelib}/spacewalk

Name: spacewalk-backend
Summary: Common programs needed to be installed on the Spacewalk servers/proxies
License: GPLv2
Version: 2.9.2
Release: 1%{?dist}
URL:       https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
Requires: python, rpm-python
# /etc/rhn is provided by spacewalk-proxy-common or by spacewalk-config
Requires: /etc/rhn
Requires: rhnlib >= 2.5.74
# for Debian support
Requires: %{python_prefix}-debian
Requires: %{name}-libs >= 1.1.16-1
%if 0%{?rhel} > 5
Requires: pyliblzma
%endif
%if 0%{?pylint_check}
BuildRequires: spacewalk-python2-pylint
%endif
BuildRequires: /usr/bin/msgfmt
BuildRequires: /usr/bin/docbook2man
BuildRequires: docbook-utils
BuildRequires: python2-spacewalk-usix
%if 0%{?fedora} || 0%{?rhel} > 5 || 0%{?suse_version} > 1310
BuildRequires: rhnlib >= 2.5.74
BuildRequires: python2-rhn-client-tools
BuildRequires: rpm-python
BuildRequires: %{python_prefix}-crypto
BuildRequires: %{python_prefix}-debian

BuildRequires: python2-gzipstream
BuildRequires: yum
BuildRequires: %{m2crypto}
%endif
Requires(pre): %{apache_pkg}
Requires: %{apache_pkg}
Requires: python2-spacewalk-usix
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
Summary: Core functions providing SQL connectivity for the Spacewalk backend modules
Requires(pre): %{name} = %{version}-%{release}
Requires: %{name} = %{version}-%{release}
Obsoletes: rhns-sql < 5.3.0
Provides: rhns-sql = 1:%{version}-%{release}
Requires: %{name}-sql-virtual = %{version}-%{release}
Requires: python2-spacewalk-usix

%description sql
This package contains the basic code that provides SQL connectivity for
the Spacewalk backend modules.

%package sql-oracle
Summary: Oracle backend for Spacewalk
Requires: python(:DBAPI:oracle)
Requires: python2-spacewalk-usix
Provides: %{name}-sql-virtual = %{version}-%{release}

%description sql-oracle
This package contains provides Oracle connectivity for the Spacewalk backend
modules.

%package sql-postgresql
Summary: Postgresql backend for Spacewalk
Requires: python-psycopg2 >= 2.0.14-2
Requires: python2-spacewalk-usix
Provides: %{name}-sql-virtual = %{version}-%{release}

%description sql-postgresql
This package contains provides PostgreSQL connectivity for the Spacewalk
backend modules.

%package server
Summary: Basic code that provides Spacewalk Server functionality
Requires(pre): %{name}-sql = %{version}-%{release}
Requires: %{name}-sql = %{version}-%{release}
Requires: python2-spacewalk-usix
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
Requires: %{name}-server = %{version}-%{release}
Requires: rpm-python
Requires: python2-spacewalk-usix
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
Requires: %{name}-server = %{version}-%{release}
Requires: python2-spacewalk-usix
Obsoletes: rhns-applet < 5.3.0
Provides: rhns-applet = 1:%{version}-%{release}

%description applet
These are the files required for running the /APPLET handler, which
provides the functions for the Spacewalk applet.

%package app
Summary: Handler for /APP
Requires: %{name}-server = %{version}-%{release}
Requires: python2-spacewalk-usix
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
Requires: rpm-python
Requires: %{name}-xml-export-libs = %{version}-%{release}
Requires: python2-spacewalk-usix

%description iss-export
%{name} contains the basic code that provides server/backend
functionality for a variety of XML-RPC receivers. The architecture is
modular so that you can plug/install additional modules for XML-RPC
receivers and get them enabled automatically.

This package contains listener for the Server XML dumper.

%package libs
Summary: Spacewalk server and client tools libraries
%if 0%{?suse_version}
BuildRequires: python-devel
%else
Requires: python
BuildRequires: python2-devel
Conflicts: %{name} < 1.7.0
Requires: python2-spacewalk-usix
%endif

%description libs
Libraries required by both Spacewalk server and Spacewalk client tools.

%if 0%{?build_py3}

%package -n python3-%{name}-libs
Summary: Spacewalk client tools libraries for Fedora 23
BuildRequires: python2-devel
BuildRequires: python3-devel
Conflicts: %{name} < 1.7.0
%if 0%{?suse_version}
Requires:       python3-base
%else
Requires: python3-libs
%endif
Requires: python3-spacewalk-usix

%description -n python3-%{name}-libs
Libraries required by Spacewalk client tools on Fedora 23.

%endif

%package config-files-common
Summary: Common files for the Configuration Management project
Requires: %{name}-server = %{version}-%{release}
Requires: python2-spacewalk-usix
Obsoletes: rhns-config-files-common < 5.3.0
Provides: rhns-config-files-common = 1:%{version}-%{release}

%description config-files-common
Common files required by the Configuration Management project

%package config-files
Summary: Handler for /CONFIG-MANAGEMENT
Requires: %{name}-config-files-common = %{version}-%{release}
Obsoletes: rhns-config-files < 5.3.0
Provides: rhns-config-files = 1:%{version}-%{release}

%description config-files
This package contains the server-side code for configuration management.

%package config-files-tool
Summary: Handler for /CONFIG-MANAGEMENT-TOOL
Requires: %{name}-config-files-common = %{version}-%{release}
Requires: python2-spacewalk-usix
Obsoletes: rhns-config-files-tool < 5.3.0
Provides: rhns-config-files-tool = 1:%{version}-%{release}

%description config-files-tool
This package contains the server-side code for configuration management tool.

%package package-push-server
Summary: Listener for rhnpush (non-XMLRPC version)
Requires: %{name}-server = %{version}-%{release}
Obsoletes: rhns-package-push-server < 5.3.0
Provides: rhns-package-push-server = 1:%{version}-%{release}

%description package-push-server
Listener for rhnpush (non-XMLRPC version)

%package tools
Summary: Spacewalk Services Tools
Requires: %{name}-xmlrpc = %{version}-%{release}
Requires: %{name}-app = %{version}-%{release}
Requires: %{name}
Requires: spacewalk-certs-tools
Requires: spacewalk-admin >= 0.1.1-0
Requires: python2-gzipstream
Requires: python2-rhn-client-tools
%if 0%{?fedora} || 0%{?rhel} > 6
Requires: pyliblzma
%endif
%if 0%{?fedora} || 0%{?rhel}
Requires: python2-devel
Requires: mod_ssl
%endif
Requires: %{name}-xml-export-libs
Requires: cobbler20
Requires: rhnlib  >= 2.5.57
Requires: python2-spacewalk-usix
Requires: python-requests
Requires: %{m2crypto}
%if 0%{?fedora} || 0%{?rhel} > 5
BuildRequires: python-requests
%endif
Obsoletes: rhns-satellite-tools < 5.3.0
Obsoletes: spacewalk-backend-satellite-tools <= 0.2.7
Provides: spacewalk-backend-satellite-tools = %{version}-%{release}
Provides: rhns-satellite-tools = 1:%{version}-%{release}

%description tools
Various utilities for the Spacewalk Server.

%package xml-export-libs
Summary: Spacewalk XML data exporter
Requires: %{name}-server = %{version}-%{release}
Requires: python2-spacewalk-usix
Obsoletes: rhns-xml-export-libs < 5.3.0
Provides: rhns-xml-export-libs = 1:%{version}-%{release}

%description xml-export-libs
Libraries required by various exporting tools

%package cdn
Summary: CDN tools
Requires: %{name}-server = %{version}-%{release}
Requires: python2-spacewalk-usix
Requires: subscription-manager
Requires: %{m2crypto}
Requires: python-argparse

%description cdn
Tools for syncing content from Red Hat CDN

%prep
%setup -q

%build
make -f Makefile.backend all

%install
install -d $RPM_BUILD_ROOT%{rhnroot}
install -d $RPM_BUILD_ROOT%{pythonrhnroot}
make -f Makefile.backend install PREFIX=$RPM_BUILD_ROOT \
    MANDIR=%{_mandir} APACHECONFDIR=%{apacheconfd}

%if 0%{?build_py3}
install -d $RPM_BUILD_ROOT%{python3rhnroot}/common
cp $RPM_BUILD_ROOT%{pythonrhnroot}/__init__.py \
    $RPM_BUILD_ROOT%{python3rhnroot}/
cp $RPM_BUILD_ROOT%{pythonrhnroot}/common/__init__.py \
    $RPM_BUILD_ROOT%{python3rhnroot}/common
cp $RPM_BUILD_ROOT%{pythonrhnroot}/common/{checksum.py,cli.py,rhn_deb.py,rhn_mpm.py,rhn_pkg.py,rhn_rpm.py,stringutils.py,fileutils.py,rhnLib.py} \
    $RPM_BUILD_ROOT%{python3rhnroot}/common
%endif
export PYTHON_MODULE_NAME=%{name}
export PYTHON_MODULE_VERSION=%{version}
%find_lang %{name}-server

%if 0%{?fedora} || 0%{?rhel} > 6
sed -i 's/#LOGROTATE-3.8#//' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/spacewalk-backend-*
sed -i 's/#DOCUMENTROOT#/\/var\/www\/html/' $RPM_BUILD_ROOT%{rhnconfigdefaults}/rhn.conf
%endif
%if 0%{?suse_version}
sed -i 's/#LOGROTATE-3.8#.*/    su root www/' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/spacewalk-backend-*
sed -i 's/#DOCUMENTROOT#/\/srv\/www\/htdocs/' $RPM_BUILD_ROOT%{rhnconfigdefaults}/rhn.conf
pushd $RPM_BUILD_ROOT
find -name '*.py' -print0 | xargs -0 python %py_libdir/py_compile.py
popd

%if 0%{?build_py3}
%py3_compile -O %{buildroot}/%{python3rhnroot}
%endif
%endif

%clean

%check
cp %{pythonrhnroot}/common/usix.py $RPM_BUILD_ROOT%{pythonrhnroot}/common
make -f Makefile.backend PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib} test || :

%if 0%{?pylint_check}
# check coding style
export PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib}:/usr/lib/rhn:/usr/share/rhn
spacewalk-python2-pylint $RPM_BUILD_ROOT%{pythonrhnroot}/common \
                         $RPM_BUILD_ROOT%{pythonrhnroot}/satellite_exporter \
                         $RPM_BUILD_ROOT%{pythonrhnroot}/satellite_tools \
                         $RPM_BUILD_ROOT%{pythonrhnroot}/cdn_tools \
                         $RPM_BUILD_ROOT%{pythonrhnroot}/upload_server \
                         $RPM_BUILD_ROOT%{pythonrhnroot}/wsgi
%endif

rm -f $RPM_BUILD_ROOT%{pythonrhnroot}/common/usix.py*

%pre server
OLD_SECRET_FILE=%{_var}/www/rhns/server/secret/rhnSecret.py
if [ -f $OLD_SECRET_FILE ]; then
    install -d -m 750 -o root -g %{apache_group} %{rhnconf}
    mv ${OLD_SECRET_FILE}*  %{rhnconf}
fi

%post server
if [ ! -e %{rhnconf}/rhn.conf ]; then
    exit 0
fi

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
%{pythonrhnroot}/common/rhnLog.py*
%{pythonrhnroot}/common/rhnMail.py*
%{pythonrhnroot}/common/rhnTB.py*
%{pythonrhnroot}/common/rhnRepository.py*
%{pythonrhnroot}/common/rhnTranslate.py*
%{pythonrhnroot}/common/RPC_Base.py*
%attr(770,root,%{apache_group}) %dir %{_var}/log/rhn
# Workaround for strict-whitespace-enforcement in httpd
%attr(644,root,%{apache_group}) %config %{apacheconfd}/aa-spacewalk-server.conf
# config files
%attr(755,root,%{apache_group}) %dir %{rhnconfigdefaults}
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn.conf
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
%{pythonrhnroot}/server/importlib/contentSourcesImport.py*
%{rhnroot}/server/handlers/__init__.py*

# Repomd stuff
%dir %{pythonrhnroot}/server/repomd
%{pythonrhnroot}/server/repomd/__init__.py*
%{pythonrhnroot}/server/repomd/domain.py*
%{pythonrhnroot}/server/repomd/mapper.py*
%{pythonrhnroot}/server/repomd/repository.py*
%{pythonrhnroot}/server/repomd/view.py*

# the cache
%attr(755,%{apache_user},%{apache_group}) %dir %{_var}/cache/rhn
%attr(755,root,root) %dir %{_var}/cache/rhn/satsync
# config files
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server.conf

# main httpd config
%attr(644,root,%{apache_group}) %config %{apacheconfd}/zz-spacewalk-server.conf

# wsgi stuff
%attr(644,root,%{apache_group}) %config %{apacheconfd}/zz-spacewalk-server-wsgi.conf
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

%if 0%{?suse_version}
%dir %{rhnroot}/server
%dir %{rhnroot}/server/handlers
%endif

%files xmlrpc
%doc LICENSE
%dir %{rhnroot}/server/handlers/xmlrpc
%{rhnroot}/server/handlers/xmlrpc/*
%dir %{pythonrhnroot}/server/action
%{pythonrhnroot}/server/action/*
%dir %{pythonrhnroot}/server/action_extra_data
%{pythonrhnroot}/server/action_extra_data/*
# config files
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_xmlrpc.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-xmlrpc

%files applet
%doc LICENSE
%dir %{rhnroot}/server/handlers/applet
%{rhnroot}/server/handlers/applet/*
# config files
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_applet.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-applet

%files app
%doc LICENSE
%dir %{rhnroot}/server/handlers/app
%{rhnroot}/server/handlers/app/*
# config files
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_app.conf
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
%{pythonrhnroot}/common/checksum.py*
%{pythonrhnroot}/common/cli.py*
%{pythonrhnroot}/common/fileutils.py*
%{pythonrhnroot}/common/rhn_deb.py*
%{pythonrhnroot}/common/rhn_mpm.py*
%{pythonrhnroot}/common/rhn_pkg.py*
%{pythonrhnroot}/common/rhn_rpm.py*
%{pythonrhnroot}/common/stringutils.py*
%{pythonrhnroot}/common/rhnLib.py*
%{pythonrhnroot}/common/timezone_utils.py*
%{pythonrhnroot}/__init__.py*
%{pythonrhnroot}/common/__init__.py*

%if 0%{?build_py3}
%files -n python3-%{name}-libs
%doc LICENSE
%{python3rhnroot}/common/checksum.py
%{python3rhnroot}/common/cli.py
%{python3rhnroot}/common/fileutils.py
%{python3rhnroot}/common/rhn_deb.py
%{python3rhnroot}/common/rhn_mpm.py
%{python3rhnroot}/common/rhn_pkg.py
%{python3rhnroot}/common/rhn_rpm.py
%{python3rhnroot}/common/stringutils.py
%{python3rhnroot}/common/rhnLib.py*
%{python3rhnroot}/__init__.py
%{python3rhnroot}/common/__init__.py
%{python3rhnroot}/__pycache__/__init__.*
%{python3rhnroot}/common/__pycache__
%if 0%{?suse_version}
%dir %{python3rhnroot}
%dir %{python3rhnroot}/common
%dir %{python3rhnroot}/__pycache__
%endif
%endif

%files config-files-common
%doc LICENSE
%{pythonrhnroot}/server/configFilesHandler.py*
%dir %{pythonrhnroot}/server/config_common
%{pythonrhnroot}/server/config_common/*

%files config-files
%doc LICENSE
%dir %{rhnroot}/server/handlers/config
%{rhnroot}/server/handlers/config/*
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_config-management.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-config-files

%files config-files-tool
%doc LICENSE
%dir %{rhnroot}/server/handlers/config_mgmt
%{rhnroot}/server/handlers/config_mgmt/*
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_config-management-tool.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-config-files-tool

%files package-push-server
%doc LICENSE
%dir %{rhnroot}/upload_server
%{rhnroot}/upload_server/__init__.py*
%dir %{rhnroot}/upload_server/handlers
%{rhnroot}/upload_server/handlers/__init__.py*
%{rhnroot}/upload_server/handlers/package_push
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_upload.conf
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_upload_package-push.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-package-push-server

%files tools
%doc LICENSE
%doc README.ULN
%attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_satellite.conf
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
%attr(755,root,root) %{_bindir}/spacewalk-update-signatures
%attr(755,root,root) %{_bindir}/spacewalk-data-fsck
%attr(755,root,root) %{_bindir}/spacewalk-fips-tool
%{pythonrhnroot}/satellite_tools/contentRemove.py*
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
%{pythonrhnroot}/satellite_tools/download.py*
%dir %{pythonrhnroot}/satellite_tools/disk_dumper
%{pythonrhnroot}/satellite_tools/disk_dumper/__init__.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss_ui.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss_isos.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/iss_actions.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/dumper.py*
%{pythonrhnroot}/satellite_tools/disk_dumper/string_buffer.py*
%dir %{pythonrhnroot}/satellite_tools/repo_plugins
%attr(755,root,%{apache_group}) %dir %{_var}/log/rhn/reposync
%{pythonrhnroot}/satellite_tools/repo_plugins/__init__.py*
%{pythonrhnroot}/satellite_tools/repo_plugins/yum_src.py*
%{pythonrhnroot}/satellite_tools/repo_plugins/uln_src.py*
%{pythonrhnroot}/satellite_tools/repo_plugins/deb_src.py*
%config %attr(644,root,%{apache_group}) %{rhnconfigdefaults}/rhn_server_iss.conf
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
%{_mandir}/man8/spacewalk-fips-tool.8*
%{_mandir}/man8/spacewalk-remove-channel.8*
%{_mandir}/man8/spacewalk-repo-sync.8*
%{_mandir}/man8/spacewalk-data-fsck.8*
%{_mandir}/man8/spacewalk-update-signatures.8*
%{_mandir}/man8/update-packages.8*

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

%files cdn
%attr(755,root,root) %{_bindir}/cdn-sync
%{pythonrhnroot}/cdn_tools/*.py*
%attr(755,root,%{apache_group}) %dir %{_var}/log/rhn/cdnsync
%config(noreplace) %{_sysconfdir}/logrotate.d/spacewalk-backend-cdn
%{_mandir}/man8/cdn-sync.8*
%if 0%{?suse_version}
%dir %{pythonrhnroot}/cdn_tools
%endif

%changelog
* Thu Apr 12 2018 Jiri Dostal <jdostal@redhat.com> 2.9.2-1
- Sat export evauated severity 0 as None

* Fri Apr 06 2018 Tomas Kasparek <tkasparek@redhat.com> 2.9.1-1
- 1198723 - rhnRepository.py: add support for Debian / Ubuntu Release files
- Bumping package versions for 2.9.

* Mon Mar 26 2018 Jiri Dostal <jdostal@redhat.com> 2.8.57-1
- 1549546 - Allow spacewalk-channel to add parent channel.

* Fri Mar 23 2018 Jan Dobes <jdobes@redhat.com> 2.8.56-1
- fixing incorrect syntax of format string
- fixing incorrect syntax of format string
- pylint: Unused variable 'frag' (unused-variable)

* Fri Mar 23 2018 Jiri Dostal <jdostal@redhat.com> 2.8.55-1
- refactoring ljust methods in print
- Hack: Try to build an URL that works for SUSE SCC downloads, based on PR #617

* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.54-1
- Make spec file follow guidelines for fedora28+

* Tue Mar 20 2018 Jiri Dostal <jdostal@redhat.com> 2.8.53-1
- Fixing newline error in translation
- Updating copyright years for 2018
- Regenerating .po and .pot files for spacewalk-backend.
- Updating .po translations from Zanata

* Thu Mar 01 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.52-1
- require python2 version of spacewalk-usix for backend server

* Thu Mar 01 2018 Jiri Dostal <jdostal@redhat.com> 2.8.51-1
- 1550001 - KeyError: 'severity' caught when exporting channel with rhn-
  satellite-exporter

* Wed Feb 28 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.50-1
- build python3-spacewalk-backend on rhel8

* Fri Feb 23 2018 Grant Gainey 2.8.49-1
- 1534417 - sanitize pwds in backup files and http-proxy-pwds as well

* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 2.8.48-1
- Update to use newly separated spacewalk-python[2|3]-pylint packages

* Tue Feb 13 2018 Grant Gainey 2.8.47-1
- 1540981 - Clarify error-reporting when checksum_cache is bad

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.46-1
- clean up specfile

* Thu Feb 08 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.45-1
- fix pylint 2.0

* Thu Feb 08 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.44-1
- fix pylint warnings

* Thu Feb 08 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.43-1
- support syncing of modules during ISS
- export modules in rhn-satellite-exporter
- support downloading modules.yaml from backend
- retrieve module metadata when syncing yum type repository
- provide a way how to retrieve module files for yum type repositories

* Mon Feb 05 2018 Grant Gainey 2.8.42-1
- 1537098 - Teach packageImport to ignore flags RPM doesn't know

* Thu Jan 25 2018 Jiri Dostal <jdostal@redhat.com> 2.8.41-1
- Fix syncing severity

* Wed Jan 24 2018 Jiri Dostal <jdostal@redhat.com> 2.8.40-1
- 1538096 - Security erratum severity is not being synced using synchronization
  tools

* Wed Jan 17 2018 Jan Dobes <jdobes@redhat.com> 2.8.39-1
- 1534417 - hide plaintext password in spacewalk-debug archive

* Wed Jan 17 2018 Jiri Dostal <jdostal@redhat.com> 2.8.38-1
- Keep the authtoken appended to the URL when downloading repo content

* Mon Jan 08 2018 Jan Dobes <jdobes@redhat.com> 2.8.37-1
- 1507553 - include unmapped channels in channel list and EOL channel list
- 1507553 - change message to warning and don't display with default verbose
  setting

* Fri Jan 05 2018 Jan Dobes <jdobes@redhat.com> 2.8.36-1
- still can print custom channels with CDN repos without mappings
- 1525858 - add --list-eol option to show more info about channel's end-of-life
  dates

* Fri Jan 05 2018 Jan Dobes <jdobes@redhat.com> 2.8.35-1
- 1525858 - print note that channel reached EOL already
- 1525858 - improve wording

* Tue Jan 02 2018 Jan Dobes <jdobes@redhat.com> 2.8.34-1
- 1525858 - display expired EOL status if available

* Mon Dec 11 2017 Jan Dobes <jdobes@redhat.com> 2.8.33-1
- 1509955 - pass http headers to downloader

* Fri Dec 01 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.32-1
- localhost is not local - port versus socket

* Fri Dec 01 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.31-1
- Update manpage for satelite-sync.
- Add --ignore-proxy option to satelite-sync.
- try to find whole dependency tree, not only direct dependencies

* Tue Nov 14 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.30-1
- 1494575 - use only version in channel release

* Mon Nov 13 2017 Jan Dobes 2.8.29-1
- copy usix before tests are executed

* Mon Nov 13 2017 Jan Dobes 2.8.28-1
- disable unsupported-assignment-operation in this block, this seems to be
  false-positive error
- rename variables to match method headers of parent classes (pylint arguments-
  differ)
- compare value instead of identity
- move to setup_repo method and execute only when no_mirrors is False
- these arguments differ intentionally
- fixing len-as-condition pylint rule
- re-enable pylint on Fedora

* Wed Nov 08 2017 Jan Dobes 2.8.27-1
- Change the virtualization backend not to duplicate data in case host and
  guests are in different organizations

* Mon Nov 06 2017 Jan Dobes 2.8.26-1
- fix joining strings

* Fri Nov 03 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.25-1
- yum ContentSource() should set number of packages during raw listing.

* Fri Nov 03 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.24-1
- convert release to long while checking which is older or newer
- Do not import ignored errata

* Tue Oct 31 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.23-1
- process comps file before package import
- yum on RHEL6 has no idea about environments

* Fri Oct 27 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.22-1
- convert only bytes

* Wed Oct 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.21-1
- pylint fixes

* Wed Oct 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.20-1
- make rhn_rpm python3 compatible
- open checksummed files in binary mode

* Wed Oct 25 2017 Jan Dobes <jdobes@redhat.com> 2.8.19-1
- mention package groups in help
- detect and parse package groups in filters
- split only using comma then strip

* Tue Oct 24 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.18-1
- add new spacewalk-repo-sync command line option to synopsis of man-page

* Tue Oct 24 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.17-1
- add new parameter '--show-packages' for spacewalk-repo-sync.

* Mon Oct 23 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.16-1
- spacewalk-backend: fix package name on SUSE and build py3 on Tumbleweed
- fixing previous commit
- improve comment
- join two ifs

* Mon Oct 16 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.15-1
- fix the inconsistency in spacewalk-repo-sync documentation.

* Thu Oct 12 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.14-1
- 1455139 - fix processing '--parent' option.

* Wed Oct 04 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.13-1
- 1456719 - don't move NULL org packages to the current org

* Mon Oct 02 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.12-1
- require python2 version of rhn-client-tools on all platforms
- fix syntax error 'release..split'

* Wed Sep 27 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.11-1
- 1494575 - 2 parts of version are enough to dermine minor release
- 1494575 - RHEL7 sends also release - drop it as it's not needed

* Tue Sep 26 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.10-1
- fix pylint issues: Unused argument 'url' (unused-argument)

* Mon Sep 25 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.9-1
- 1402418 - add output formatting for reposync

* Fri Sep 15 2017 Jan Dobes 2.8.8-1
- bz1490801 - [RFE] skip child channels with no repo during sync

* Thu Sep 14 2017 Jan Dobes 2.8.7-1
- 1486285 - write manifest to default location after activation succeeded

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.6-1
- purged changelog entries for Spacewalk 2.0 and older

* Tue Sep 05 2017 Jan Dobes 2.8.5-1
- 1456719 - fixing mixed-indentation and bad-continuation pylint issues

* Mon Sep 04 2017 Jan Dobes 2.8.4-1
- 1456719 - save the package to the same org as erratum

* Tue Aug 29 2017 Jan Dobes 2.8.3-1
- it's now python2-gzipstream

* Mon Aug 21 2017 Jan Dobes 2.8.2-1
- 1464540 - get relative path better

* Fri Aug 18 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.1-1
- 1482981 - stop synchronization if no space left on device
- Bumping package versions for 2.8.

* Mon Aug 14 2017 Jan Dobes 2.7.137-1
- 1477344 - select all null-org channels and then fiter them

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.136-1
- 1477753 - precompile py3 stuff
- 1477753 - use standard brp-python-bytecompile

* Mon Aug 07 2017 Jan Dobes 2.7.135-1
- 1459878 - cdn-sync of custom channel should unlink errata from channel if
  repository is removed

* Mon Aug 07 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.134-1
- 1450445 - check url of repository contains protocol name

* Wed Aug 02 2017 Jan Dobes 2.7.133-1
- 1477667 - don't unlink packages if --no-packages is used

* Wed Aug 02 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.132-1
- 1476924 - log to stderr
- 1449124 - run db-control report only on postgresql

* Tue Aug 01 2017 Jan Dobes 2.7.131-1
- 1476924 - set SSL certificates during ContentSource initialization, not later

* Tue Aug 01 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.130-1
- update copyright year

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.129-1
- update copyright year

* Fri Jul 28 2017 Jan Dobes 2.7.128-1
- 1446271 - support dumping of product names

* Thu Jul 27 2017 Jan Dobes 2.7.127-1
- 1466229 - sync as many errata as possible by default, skip faulty errata

* Thu Jul 27 2017 Jan Dobes 2.7.126-1
- 1451771 - catch IncorrectEntitlementsFileFormatError exception and improve
  messages

* Tue Jul 25 2017 Jan Dobes 2.7.125-1
- 1461339 - don't sync errata with empty package list if these packages were
  filtered

* Thu Jul 20 2017 Jan Dobes 2.7.124-1
- 1472970 - parse both providedProducts and derivedProvidedProducts

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.123-1
- fixed msgfmt/translation error

* Tue Jul 18 2017 Jan Dobes 2.7.122-1
- 1450374 - fixing typos in man page

* Mon Jul 17 2017 Jan Dobes 2.7.121-1
- fixing pylint - Unused variable 'index' (unused-variable)

* Mon Jul 17 2017 Jan Dobes 2.7.120-1
- Regenerating .po and .pot files for backend
- Updating .po translations from Zanata

* Fri Jun 30 2017 Eric Herget <eherget@redhat.com> 2.7.119-1
- PR 500 - correcting email address in change log.  Not able/willing to change
  email addresses in individual commits, however.

* Tue Jun 27 2017 Valérian Beaudoin <valouille@users.noreply.github.com>
- PR 502 - fix model objects do not support item assignment errors and tuple
  indices must be integers, not str errors
- PR 502 - Correcting unused variable 'index' following the use of enumerates
- PR 502 - Correcting C0200 and refactoring
- PR 502 - Indentation & using IOError instead of UpdateNoticeException
- PR 502 - Moving "import re" & adding "import fnmatch"
- PR 502 - Adding filters feature to deb_src.py

* Tue Jun 27 2017 Marc Dahlhaus <ossdev@dahlhaus.it>
- PR 500 - Another try to fix the test suite
- PR 500 - Fix version string for test-suite
- PR 500 - Fix typo
- PR 500 - Add epoch information for deb packages

* Fri Jun 23 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.116-1
- 1449172 - make documentation in man page and --help consistent

* Thu Jun 22 2017 Grant Gainey 2.7.115-1
- Fix bug introduced in 46f1320 preventing RPM removal.
- 1434043 - Fix spacewalk-data-fsck removing SRPMs associated with RPM

* Tue Jun 20 2017 Jiri Dostal <jdostal@redhat.com> 2.7.114-1
- remove not implemented option

* Thu Jun 08 2017 Grant Gainey 2.7.113-1
- 1425137 - fix remaining backend/manpage.sgml issues

* Thu Jun 08 2017 Jan Dobes 2.7.112-1
- 1438854 - improve message
- 1438854 - unlink all packages when there isn't any repository attached in
  strict mode
- 1406178 - two typos in cdn-sync --help output

* Mon Jun 05 2017 Jan Dobes 2.7.111-1
- 1439758 - close Curl handle
- 1439758 - workaround - make sure first item from queue is performed alone to
  prevent multi-threading NSS error
- 1439758 - split single download queue into multiple download queues based on
  SSL certificates

* Fri May 26 2017 Jan Dobes 2.7.110-1
- 1455795 - move to different file to not conflict with web.default_mail_from
  in Java code

* Thu May 25 2017 Jan Dobes 2.7.109-1
- 1455433 - don't trim channel content if there is major sync error in any
  repository

* Wed May 24 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.108-1
- disable pylint on Fedora 26 because it's python3
- 1348575 - rhn-charsets is meant to be run only under root user

* Wed May 24 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.107-1
- more pylint warning fixes

* Wed May 24 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.106-1
- fixed pylint warnings
- hashlib is included in python since RHEL6

* Tue May 23 2017 Eric Herget <eherget@redhat.com> 2.7.105-1
- 1434786 - Unable to run cdn-sync if older channels do not exist anymore

* Fri May 19 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.104-1
- 1439622 - return no row if user has no privs for the server
- 1439622 - don't let disabled user log in

* Thu May 18 2017 Eric Herget <eherget@redhat.com> 2.7.103-1
- 1434913 - fix exit code to indicate error in other commands when not
  activated with CDN

* Wed May 17 2017 Jan Dobes 2.7.102-1
- 1427238 - normalize repository path to detect if it's part of any channels or
  not
- 1427238 - handle . and .. in path
- 1427238 - fixing leaf detection

* Mon May 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.101-1
- 1450496 - Revert "1357480 - get_possible_orgs function never called? ->
  removed"

* Fri May 12 2017 Jan Dobes 2.7.100-1
- fixing deb plug-in
- updating help and man page
- use repository type value from DB if it's possible

* Thu May 11 2017 Gennadii Altukhov <galt@redhat.com> 2.7.99-1
- 1447296 - fix examples in man page of satellite-sync
- 1449914 - fixing 'NoneType' object is not iterable if no rows are selected

* Wed May 10 2017 Jan Dobes 2.7.98-1
- satellite-sync (iss) - enhancements to channel selection

* Wed May 10 2017 Gennadii Altukhov <galt@redhat.com> 2.7.97-1
- 1444894 - normalize path to an RHSM manifest

* Wed May 10 2017 Jan Dobes 2.7.96-1
- 1447296 - update man pages about batch size parameter
- 1447296 - make batch size configurable

* Wed May 10 2017 Jan Dobes 2.7.95-1
- 1446118 - wildcard support for channel names

* Wed May 10 2017 Jan Dobes 2.7.94-1
- 1437835, 1441096 - updating help
- 1447296 - can't rely on index in to_process, if last item has to_link only,
  last chunk of packages is not imported
- 1437835, 1441096 - optimize linking packages to channel
- 1437835, 1441096 - disassociate packages later or keep them in channel if
  they are same but missing package path
- 1449374 - there may be multiple packages with given checksum in different
  orgs
- 1437835, 1441096 - upload with force to update missing package file paths on
  existing packages
- 1437835, 1441096 - change metadata_only to just not keep packages after
  download

* Tue May 09 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.93-1
- 1444519 - org_id column can hold NULL
- 1444894 - normalize path to an RHSM manifest
- 1447296 - add package_import_skip_changelog option to speed reposync up
- 1446198 - finish work in threads when KeyboardInterrupt occurs during download
- 1446198 - fixing semantic error

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.92-1
- 1444047 - fix errata lookup for NULL org

* Wed May 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.91-1
- 1415193 - fix line with a mention about ISS synchronization

* Wed May 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.90-1
- 1415193 - remove mention about a live synchronization from satellite-sync man
  page

* Tue May 02 2017 Gennadii Altukhov <galt@redhat.com> 2.7.89-1
- 1447296 - optimize package importing during syncing a software channel
- 1446198 - fixing pylint

* Tue May 02 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.88-1
- 1444519 - allow sync of the same erratum to more orgs
- 1444047 - look only for errata from the same org

* Fri Apr 28 2017 Eric Herget <eherget@redhat.com> 2.7.87-1
- 1342977 - Repository sync can causes ORA-01878 on insertion of timestamp that
  doesn't exist in timezone - fix python 2.4 build

* Fri Apr 28 2017 Jan Dobes 2.7.86-1
- 1446198 - do not store SSL certificates per repository on disk cache
- 1446198 - define CACHE_DIR once

* Fri Apr 28 2017 Laurence Rochfort <laurence.rochfort@oracle.com>
- 1342977 - Prevent ORA-01878 on repository sync.
- Add timezone_utils.py to libs files for BZ 1342977

* Fri Apr 28 2017 Jan Dobes 2.7.84-1
- 1445957 - default_mail_from key exists but may be empty
- Remove unused imports.

* Thu Apr 27 2017 Eric Herget <eherget@redhat.com> 2.7.83-1
- 1434913 - cdn-sync could provide information that the satellite is not
  activated - lock release fix

* Thu Apr 27 2017 Jan Dobes 2.7.82-1
- 1446198 - fixing number of thread input
- 1446198 - update imports
- 1446198 - update build configuration
- 1446198 - move downloading to module and don't block reusing connections

* Wed Apr 26 2017 Gennadii Altukhov <galt@redhat.com> 2.7.81-1
- revert 200924587a237b57d70d780a637c867c04393438 we don't need to remove
  interrupted downloads, because we don't use yum to download packages anymore.

* Tue Apr 25 2017 Jan Dobes 2.7.80-1
- 1445220 - make sure each channel family label is selected only once

* Fri Apr 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.79-1
- replace dots in method names with underscore
- do not fail with a traceback when media.1 is requested

* Thu Apr 20 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.78-1
- 1441135 1434471 - be more specific about catched exception

* Wed Apr 19 2017 Jan Dobes 2.7.77-1
- 1434787 - adding logrotate
- 1434787 - adding logging to candlepin_api
- 1434787 - adding logging to manifest
- 1434787 - adding logging to activation
- 1434787 - adding logging to rhn_satellite_activate

* Tue Apr 18 2017 Jan Dobes 2.7.76-1
- 1439721 - subset of log2disk messages is good to include in email too
- 1439721 - adding to spacewalk-repo-sync
- 1439721 - making traceback_mail overridable
- 1439721 - send email report

* Mon Apr 17 2017 Eric Herget <eherget@redhat.com> 2.7.75-1
- 1434913 - cdn-sync could provide information that the satellite is not
  activated

* Tue Apr 11 2017 Eric Herget <eherget@redhat.com> 2.7.74-1
- 1434913 - cdn-sync could provide information that the satellite is not
  activated

* Fri Apr 07 2017 Jan Dobes 2.7.73-1
- 1397762 - adding examples section
- 1397762 - add option to display info about currently used manifest
- 1397762 - use candlepin API server from manifest
- 1397762 - rename --cdn-deactivate to just --deactivate
- 1397762 - rotate manifest on deactivation
- 1397762 - parse meta json file
- 1397762 - get name and API URL from manifest
- 1397762 - be more descriptive
- 1397762 - provide option for immediate activation and rename parameters
- 1439949 - Set a maximum limit to include the PostgreSQL logs into the
  spacewalk-debug tarball.
- Enhances performance by copying just the pertinent files under /var/rhn/log.
  A lot of the times, external files are mistakenly saved there by sysadmins
  such as database dumps, etc.

* Thu Apr 06 2017 Gennadii Altukhov <galt@redhat.com> 2.7.72-1
- 1434786 - add indentation for missing channels in an error message

* Wed Apr 05 2017 Jan Dobes 2.7.71-1
- 1418025 - fixing behavior to work with --force-kickstarts parameter

* Wed Apr 05 2017 Jan Dobes 2.7.70-1
- 1438807 - fixing long line
- 1434769 - removing old return codes from comment

* Tue Apr 04 2017 Jan Dobes 2.7.69-1
- 1397762 - fixing long lines

* Tue Apr 04 2017 Jan Dobes 2.7.68-1
- 1438854 - adding example for deleting custom repo

* Tue Apr 04 2017 Jan Dobes 2.7.67-1
- 1438807 - display channel sync error causes on default verbosity and improve
  them
- 1438807 - label may not be in db_channel if channel doesn't exist
- 1434471 - raise Database exception up to stack and stop syncing.
- 1434471 - raise unified exception from database drivers if it's not possible
  to execute SQL statement

* Mon Apr 03 2017 Jan Dobes 2.7.66-1
- 1397762 - fix build on RHEL 5

* Fri Mar 31 2017 Jan Dobes 2.7.65-1
- 1397762 - update man page
- 1397762 - use at least some verbosity levels in cdn_tools modules

* Fri Mar 31 2017 Jan Dobes 2.7.64-1
- 1397762 - fixing pylint
- 1397762 - adding Candlepin API to call manifest refresh
- 1397762 - call Candlepin API to download manifests and implement missing
  pieces of code
- 1397762 - adding handler for calling Candlepin API requests with export
  manifest support

* Fri Mar 24 2017 Jiri Dostal <jdostal@redhat.com> 2.7.63-1
- Make spacewalk-remove-channel python3 compatible

* Fri Mar 24 2017 Jiri Dostal <jdostal@redhat.com> 2.7.62-1
- filter channels to removed by patern with '*' - e.g. 'fedora19*'
- Fix suboptimal wording

* Thu Mar 23 2017 Jan Dobes 2.7.61-1
- 1427231 - set interrupt callback to not retry
- 1427231 - it's not necessarily interrupted by user and the return code should
  not be zero
- 1427231 - propagate first detected fatal exception from child threads and
  interrupt downloading

* Thu Mar 23 2017 Gennadii Altukhov <galt@redhat.com> 2.7.60-1
- 1434786 - show list of non-available channels at the beginning of syncing

* Thu Mar 23 2017 Gennadii Altukhov <galt@redhat.com> 2.7.59-1
- 1434786 - ignore channels which are not exist or not available

* Mon Mar 20 2017 Gennadii Altukhov <galt@redhat.com> 2.7.58-1
- 1433365 - show error message if we cannot download repomd.xml during counting
  packages
- 1433365 - fix http proxy configuration for yum_src

* Mon Mar 20 2017 Gennadii Altukhov <galt@redhat.com> 2.7.57-1
- 1418025 - fix package downloading for Kickstart addons. Add parsing repodata
  for addons repository and download all packages according to its location.
- 1427231 - if package was not downloaded and message-less Exception catched,
  don't print empty line and don't print to stream on default verbose setting

* Thu Mar 16 2017 Jan Dobes 2.7.56-1
- 1430236 - fixing 'WARNING:  there is already a transaction in progress' in
  postgresql logs

* Wed Mar 15 2017 Jan Dobes 2.7.55-1
- 1428749 - fixing redundant tag
- 1428749 - adding note about threads

* Tue Mar 14 2017 Jan Dobes 2.7.54-1
- 1427238 - update man page
- 1427238 - cleanup orphaned repositories not attached to any channel
- 1427238 - there should not be custom repositories assigned, delete them if
  they are
- 1427238 - handle sync after first repo was added, last repo was removed
- 1427238 - splitting into two functions and mark as synced after repos are
  assigned
- 1427238 - ContentSourceImport can't unlink last associated repository, do it
  differently
- 1427238 - move to repository file
- 1427238 - support counting packages in custom channels
- 1427238 - removing unreachable code, channels without content sources are
  filtered out earlier
- 1427238 - put common code into separate method
- 1427238 - work without channel mappings
- break mappings dependency on spacewalk
- 1427238 - list all provided repositories separately, not associated with
  channels because it's in channel list output already anyway
- 1427238 - list custom CDN channels and sorting repositories
- 1427238 - load org_id of synced channels
- 1427238 - rename --cdn-certificates to shorter --cdn-certs
- 1427238 - change --list-repositories option to be used only together with
  --list-channels and --cdn-certificates
- 1427238 - shuffle verbosity levels a bit and fix messages
- 1427238 - adding --add-repo and --delete-repo parameter to sync specific
  repos to custom channel
- 1427238 - make sure content is in null org, not in custom org
- 1427238 - check if it's really leaf, fixing error when incomplete path is
  searched
- 1427238 - support linking ContentSource to existing channels during their
  import
- 1427238 - update function creating ContentSource to work with specified repos
- 1427238 - split checking function
- 1427238 - list channels syncing from given repository
- 1427238 - filter channels with lost entitlement and include custom repos with
  null content source assigned

* Mon Mar 13 2017 Grant Gainey 2.7.53-1
- 1427625 - Move aa-spacewalk-server.conf to backend from server
- remove old code used for testing

* Tue Mar 07 2017 Grant Gainey 2.7.52-1
- 1427625 - Fix garbage-char in file (??)
- 1419867 - fixing 'NoneType object is not iterable' error

* Mon Mar 06 2017 Jan Dobes 2.7.51-1
- 1427851 - fixing spaces

* Fri Mar 03 2017 Jan Dobes 2.7.50-1
- 1419867 - provide option for forcibly syncing all errata, similarly as in
  satsync
- 1419867 - do not import always all errata by default for performance reasons
- 1419867 - don't re-insert existing files again

* Fri Mar 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.49-1
- fix pylint warning
- Updated links to github in spec files
- 1428834 - show sys.path as string if anything goes wrong
- Migrating Fedorahosted to GitHub

* Fri Mar 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.48-1
- 1418025 - sync RPM packages for addons in Kickstart Tree
- Fix: selection of primary interface

* Thu Mar 02 2017 Jan Dobes 2.7.47-1
- 1427220 - trigger repodata generation after and only if channel packages are
  updated
- 1419867 - do not re-subscribe packages to channel if nothing was added

* Thu Mar 02 2017 Jan Dobes 2.7.46-1
- 1419867 - simplyfying nested blocks
- wrong-import-position is not present in pylint on Fedora 23

* Wed Mar 01 2017 Jan Dobes 2.7.45-1
- 1419867 - cache correct path of uploaded package
- don't use keys() to iterate over a dictionary

* Tue Feb 28 2017 Grant Gainey 2.7.44-1
- 1427625 - Add strict-httpd-workaround *FIRST* in httpd conf files
  (bz is a SW-clone of BZ#1422518)

* Mon Feb 27 2017 Jan Dobes 2.7.43-1
- 1419867 - adding checksum cache for reposync to speed up syncing already
  synced channel

* Fri Feb 24 2017 Jan Dobes 2.7.42-1
- Postgresql 9.6 support

* Fri Feb 24 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.41-1
- Fixing wrong-import-position (C0413) for backend.
- Fixing ungrouped-imports for backend
- Fixing trailing-newlines for backend
- Fixing consider-iterating-dictionary for backend

* Fri Feb 24 2017 Jan Dobes 2.7.40-1
- align number to right in output

* Thu Feb 23 2017 Jan Dobes 2.7.39-1
- 1401497 - fixing case when there isn't any valid SSL cert
- 1401497 - fixing 'ERROR: expected a readable buffer object' on Oracle

* Thu Feb 23 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.38-1
- temporarily copy usix into buildroot for pylint check

* Tue Feb 21 2017 Jan Dobes 2.7.37-1
- 1425137 - fixing element CODE undefined
- 1425137 - close term tags

* Mon Feb 20 2017 Gennadii Altukhov <galt@redhat.com> 2.7.36-1
- 1390241 - catch exception InvalidArchError and send back an error message

* Fri Feb 17 2017 Jan Dobes 2.7.35-1
- 1401497 - fixing empty select

* Thu Feb 16 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.34-1
- require spacewalk-usix in buildtime for pylint

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.33-1
- __init__.py should be owned by backend-libs package
- delete usix source

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.32-1
- fix specfile
- require spacewalk-usix indead of spacewalk-backend-usix
- remove spacewalk-backend-usix package

* Tue Feb 14 2017 Jan Dobes 2.7.31-1
- 1420288 - support importing KS files with other checksum type than md5

* Tue Feb 14 2017 Gennadii Altukhov <galt@redhat.com> 2.7.30-1
- 1418044 - check ISS case in cdn-sync

* Thu Feb 09 2017 Jan Dobes 2.7.29-1
- 1401497 - complain about certificates during activation
- 1401497 - adding more details of current SSL certificates in DB
- 1401497 - support creating repository tree with only repos provided by single
  client certificate
- 1401497 - catch on higher level to not mark missing repositories as found
  repositories with no SSL certificates
- 1401497 - check SSL dates in reposync
- 1401497 - check if there is any not-expired ssl set
- 1401497 - adding function for checking certificate dates
- 1401497 - fixing repository tree population functions to support multiple ssl
- 1401497 - fixing import of SSL certificates to import them all
- require python-argparse for spacewalk-backend-cdn
- Fix typo

* Wed Feb 01 2017 Jan Dobes 2.7.28-1
- 1414454 - setting channel_access to private as a default

* Tue Jan 31 2017 Gennadii Altukhov <galt@redhat.com> 2.7.27-1
- 1413788 - change error messages in satellite-sync and rhn-satellite-activate

* Wed Jan 25 2017 Gennadii Altukhov <galt@redhat.com> 2.7.26-1
- fix failed packages counting if we cannot download some package

* Wed Jan 25 2017 Gennadii Altukhov <galt@redhat.com> 2.7.25-1
- 1415193 - fix man page for satellite-sync
- 1413788 - improve error messages for obsolete options in satellite-sync and
  rhn-satellite-activate

* Mon Jan 23 2017 Jan Dobes 2.7.24-1
- 1414697 - fixing pylint
- 1316708 - fixing case when postgresql is installed but spacewalk is using
  Oracle
-   bz#1316708 - added the capability for spacewalk-debug to capture the
  pg_catalog information from PostgreSQL

* Thu Jan 19 2017 Jan Dobes 2.7.23-1
- 1414697 - proxy can't be specified in multiple parameters on all versions of
  urlgrabber

* Thu Jan 19 2017 Gennadii Altukhov <galt@redhat.com> 2.7.22-1
- 1395815 - change permissions for /var/satellite/rhn* after syncing of a
  channel

* Wed Jan 18 2017 Gennadii Altukhov <galt@redhat.com> 2.7.21-1
- bz1412600 - error during syncing duplicated channel's labels

* Mon Jan 16 2017 Gennadii Altukhov <galt@redhat.com> 2.7.20-1
- 1406462 - add possibility to use previous manifest

* Thu Jan 12 2017 Gennadii Altukhov <galt@redhat.com> 2.7.19-1
- 1412617 - Oracle backend returns LOB object not a string, convert to string

* Fri Jan 06 2017 Gennadii Altukhov <galt@redhat.com> 2.7.18-1
- 1406462 - print help if no options were provided for rhn-satellite-activate

* Wed Jan 04 2017 Jan Dobes 2.7.17-1
- 1409434 - fixing mirror expansion

* Wed Jan 04 2017 Jan Dobes 2.7.16-1
- 1410149 - fixing activation on s390x
- 1410146 - fixing entitlements without provided products

* Tue Jan 03 2017 Gennadii Altukhov <galt@redhat.com> 2.7.15-1
- fix usability bug in reposync
- 1406038 - show number of packages which are failed during a channel syncing

* Tue Jan 03 2017 Jan Dobes 2.7.14-1
- 1409434 - this option works differently on different yum versions, reverting
  for now
- 1409434 - make baseurls in good format when not expanding mirrors
- 1409434 - don't have to be in try block

* Mon Jan 02 2017 Jan Dobes 2.7.13-1
- 1401488 - Fixes the following error on errata-sync: ERROR: cannot concatenate
  'str' and 'int' objects

* Mon Jan 02 2017 Jan Dobes <jdobes@redhat.com> 2.7.12-1
- 1409434 - fixing parameters
- 1409434 - fixing pylint

* Mon Jan 02 2017 Jan Dobes <jdobes@redhat.com> 2.7.11-1
- 1409434 - make updating repodata default
- 1409434 - log2stderr will not get it into log files
- 1409434 - remove downloaded packages as well
- 1409434 - returning ret_code is expected
- 1409434 - adding option for overwriting kickstart data
- 1409434 - do not try to link not imported package to channel
- 1409434 - add multithreaded download to reposync
- 1409434 - fixing broken pipe on long output and release locks
- 1409434 - consistent time
- 1409434 - improve list format
- 1409434 - suppress "Unknown channel family" messages
- 1409434 - support counting single channel
- 1409434 - fixing argument format
- 1409434 - download all repomd first and skip repositories with up to date
  repomd
- 1409434 - configurable threads
- 1409434 - work with mirrors
- 1409434 - work with proxy
- 1409434 - changing parameter format, add function for setting parameters, add
  text log class
- 1409434 - retry download, checksum etc.
- 1409434 - adding multi-threaded downloader
- 1409434 - repodata can contain only sha word
- 1409434 - we can skip mirror expansion in cdnsync
- 1409434 - adding function to check if there is newer repomd in repository
  than in cache
- 1409434 - support keeping repomd in cache

* Mon Dec 19 2016 Gennadii Altukhov <galt@redhat.com> 2.7.10-1
- 1395815 - fix permissions for Kickstart Tree paths

* Fri Dec 16 2016 Gennadii Altukhov <galt@redhat.com> 2.7.9-1
- 1405039 - continue syncing if we cannot download some packages
- close log file handler for yum plugin to avoid file descriptors leak

* Thu Dec 15 2016 Gennadii Altukhov <galt@redhat.com> 2.7.8-1
- 1404033 - return non-zero return code if channel has no URL associated

* Thu Dec 15 2016 Gennadii Altukhov <galt@redhat.com> 2.7.7-1
- 1397417 - fix memory leaks in cdn-sync and spacewalk-repo-sync. * remove a
  circular dependency between YumRepository and ContentSource * optimize memory
  consumption

* Mon Dec 12 2016 Gennadii Altukhov <galt@redhat.com> 2.7.6-1
- 1403898 - spacewalk-repo-sync returns non-zero return code if some problems
  occured

* Mon Dec 12 2016 Gennadii Altukhov <galt@redhat.com> 2.7.5-1
- 1397427 - add non-zero return code and error message if some problems
  occurred during syncing

* Wed Nov 30 2016 Jan Dobes 2.7.4-1
- 1387173 - only user repositories should be allowed to configure, accessing
  self.yumbase.repos.repos can take long, do it once

* Mon Nov 28 2016 Jan Dobes 2.7.3-1
- 1387173 - make possible to configure by channel
- 1387173 - make sure org_id is string
- 1387173 - make possible to setup repository configuration with guessable name
  and keep org_id information

* Mon Nov 21 2016 Jan Dobes 2.7.2-1
- 1395207 - recognize downloaded headers by yum

* Tue Nov 15 2016 Jan Dobes 2.7.1-1
- 1395214 - download treeinfo to cache directory to not create folder in
  kickstart directory if there isn't any treeinfo
- 1395214 - evaluate kickstart trees properly
- Bumping package versions for 2.7.

* Wed Nov 09 2016 Gennadii Altukhov <galt@redhat.com> 2.6.74-1
- Revert Project-Id-Version for translations

* Wed Nov 09 2016 Gennadii Altukhov <galt@redhat.com> 2.6.73-1
- properly extract path
- add missing newline in string

* Tue Nov 08 2016 Jan Dobes 2.6.72-1
- fixing case when local repository has packages in subdirectories
- Regenerating .po and .pot files for backend
- Updating .po translations from Zanata

* Mon Nov 07 2016 Jan Dobes 2.6.71-1
- kickstart repositories are not required when syncing with --no-kickstarts

* Fri Nov 04 2016 Jan Dobes 2.6.70-1
- adding support for incremental imports from mount point
- disabling RHN satsync in code
- do cast to None earlier to prevent crash if --no-packages is used
- adding missed disconnected option

* Thu Nov 03 2016 Jan Dobes 2.6.69-1
- update man page
- import channel families after signature is checked and fix return code if
  manifest validation fails
- always check mappings
- use disconnected option to not subscribe to sat repo
- removing remote activation functions
- save manifest to default location
- read certificate from manifest only
- making cdn activation mandatory in this script
- removing unsupported options
- fixing list of channels when there are only child channels available
- adding mount point parameter

* Wed Oct 26 2016 Jan Dobes 2.6.68-1
- rename and remove untrue comments

* Tue Oct 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.6.67-1
- fix: NameError: global name 'get' is not defined.
- always save certificate
- refactoring in activation

* Mon Oct 24 2016 Jan Dobes 2.6.66-1
- fixing number of values

* Fri Oct 21 2016 Jan Dobes 2.6.65-1
- check if relevant repository is enabled
- filter source repositories by default
- fixing the result dictionary
- fixing channel family not found in mapping

* Thu Oct 20 2016 Jan Dobes 2.6.64-1
- fixing pylint
- this directory needs to be created after cleanup
- set repository location in runtime, not hardcoded in DB
- cleanup and moving repository logic from cdnsync to repository module
- package name is now known
- adding classes to work with CDN repositories
- do not print RHN messages if (de)activating CDN
- refactor and add option to deactivate CDN
- removing usage of product mapping and saving repositories from manifest
  instead
- support populating SSL information
- require mapping package
- load repository urls from manifest
- make sure all old certs/keys are gone
- fixing occurences in code
- check for presence of all headers
- headers can sometimes arrive in lowercase

* Fri Oct 14 2016 Grant Gainey 2.6.63-1
- Update specfile to remove references to RHN

* Thu Oct 13 2016 Gennadii Altukhov <galt@redhat.com> 2.6.62-1
- fix pylint wrong-import-order
- reverting pylint change - method cannot be called, it's not instance

* Mon Oct 10 2016 Jan Dobes 2.6.61-1
- fixing pylint

* Mon Oct 10 2016 Jan Dobes 2.6.60-1
- detect already activated system
- adding force parameter
- cleaning, removing even older API references to not get confused
- activate system registered to RHSM
- adding new parameter to save current behavior

* Fri Oct 07 2016 Gennadii Altukhov <galt@redhat.com> 2.6.59-1
- fix setting of default kickstart installation type
- fix list of urls in yum_src repo plugin.
- require m2crypto in -tools package
- get uuid of system if registered in RHSM

* Wed Oct 05 2016 Jan Dobes 2.6.58-1
- adding m2crypto dependency

* Wed Oct 05 2016 Jan Dobes 2.6.57-1
- check signature in code

* Tue Oct 04 2016 Gennadii Altukhov <galt@redhat.com> 2.6.56-1
- fix spacewalk-backend build * we still need to build spacewalk-backend on
  RHEL5 to use two subpackages spacewalk-backend-libs and spacewalk-backend-
  usix on cliend side. spacewalk-backend-tools uses python-requests module wich
  is absent in RHEL5 repos, so I removed it from BuildDependencies, but leave
  in Dependencies, maybe it can be installed manually.

* Tue Oct 04 2016 Gennadii Altukhov <galt@redhat.com> 2.6.55-1
- fix dependencies for CDN-Sync
- fix spec file to build CDN-Sync on RHEL5 reverted
  (7e629f0f5ead8aa4c8c6f2e5c0ee4a3cb85e0474)
- fix python backend code to be compatible with Python 2.4

* Thu Sep 29 2016 Grant Gainey 2.6.54-1
- 1372721 - Handle the case where a user has no timezone/locale setting

* Thu Sep 15 2016 Gennadii Altukhov <galt@redhat.com> 2.6.53-1
- cdn-sync - fix man page

* Thu Sep 15 2016 Gennadii Altukhov <galt@redhat.com> 2.6.52-1
- fix yum plugin naming, based on an url, because it can be a metalink
- remove hardcoded METADATA_EXPIRE, use value from config file
- cdn-sync - clear repodata before syncing repository

* Thu Sep 15 2016 Gennadii Altukhov <galt@redhat.com> 2.6.51-1
- cdn-sync  - add fixes in packages counting: - if we have the same package in
  different repositories of channel, we count it only one time - count packages
  for base channel

* Tue Sep 13 2016 Jan Dobes 2.6.50-1
- fixing pylint: too-many-nested-blocks
- fixing pylint: wrong-import-order
- fixing pylint: unsubscriptable-object

* Mon Sep 12 2016 Jan Dobes 2.6.49-1
- fixing pylint

* Fri Sep 09 2016 Jan Dobes 2.6.48-1
- adding logrotate files
- adding logging of spacewalk-repo-sync script

* Wed Sep 07 2016 Jan Dobes 2.6.47-1
- a bit more magic is needed for gpg check satellite certificate
- changing log format
- log cdnsync module

* Wed Sep 07 2016 Gennadii Altukhov <galt@redhat.com> 2.6.46-1
- fixup man page for cdn-sync

* Tue Sep 06 2016 Gennadii Altukhov <galt@redhat.com> 2.6.45-1
- add man page for cdn-sync

* Tue Sep 06 2016 Jan Dobes 2.6.44-1
- try to speed up RHEL kickstart syncing by not downloading release-notes

* Mon Sep 05 2016 Jan Dobes 2.6.43-1
- dropping quiet flag, it's not much useful now
- try to recover from incorrect updateinfo.xml
- change log level handling in reposync
- adding some basic info into man page
- unused variable
- split reposync and cdnsync log directories
- fixing TypeError when filename is None
- kickstarts from external repositories have full path in DB

* Fri Sep 02 2016 Jan Dobes 2.6.42-1
- fixing rhnpush

* Fri Sep 02 2016 Gennadii Altukhov <galt@redhat.com> 2.6.41-1
- reposync - rewrite HTML parser for Kickstart repositories
- Added the capability for spacewalk-debug to grab the user's preferences for
  timezone and language locale
- fixing path

* Tue Aug 30 2016 Gennadii Altukhov <galt@redhat.com> 2.6.40-1
- add possibility to use certificate from manifest

* Fri Aug 26 2016 Jan Dobes 2.6.39-1
- make sure images from treeinfo are included regardless on directory listing
- do not show internal DB id
- detect treeinfo file
- split listing files and downloading
- there can be missing mappings for kickstart trees currently
- do cdn activation in rhn-satellite-activate
- add manifest parameter for rhn-satellite-activate
- dropping cdn-activate script

* Mon Aug 22 2016 Jan Dobes 2.6.38-1
- update kickstart syncing code
- fixing pylint: too-many-nested-blocks, little refactoring

* Thu Aug 18 2016 Jan Dobes 2.6.37-1
- fixing import
- apply formatting changes on file in original location and drop it from cdn
  dir
- fixing pylint: too-many-nested-blocks, no need for else
- adding support for release channel mapping

* Wed Aug 17 2016 Jan Dobes <jdobes@redhat.com> 2.6.36-1
- fixing pylint: wrong-import-position, wrong-import-order
- fixing pylint: wrong-import-position
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-position
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order,ungrouped-imports
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-position
- fixing pylint: consider-using-enumerate
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-position
- fixing pylint: wrong-import-position
- fixing pylint: wrong-import-order
- fixing pylint: No value for argument 'tb' in constructor call (no-value-for-
  parameter)
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixed SyntaxError " b'' " for RHEL5

* Tue Aug 16 2016 Jan Dobes 2.6.35-1
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: simplifiable-if-statement
- fixing pylint: unneeded-not
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-order
- fixing pylint: wrong-import-position
- sys.exitfunc is deprecated since Python 2.4
- more pylint and pep8 fixes

* Tue Aug 16 2016 Jan Dobes 2.6.34-1
- fixing pylint issues
- drop disconnected activation on spacewalk, there is not much to insert and
  not possible to update counts
- call signature check directly instead of calling external (also dropped) perl
  script
- include files in packages
- bringing back tool for activation

* Mon Aug 15 2016 Jan Dobes 2.6.33-1
- do not change package_from_filename header

* Fri Aug 12 2016 Jan Dobes 2.6.32-1
- set header_end to value where we stop reading
- split maximally once or we lost part of the release sometimes
- get package format from filename
- check downloaded file
- add basic plug-in for syncing deb repo
- there are errata with intentionally empty package list, cannot skip them

* Thu Aug 11 2016 Gennadii Altukhov <galt@redhat.com> 2.6.31-1
- share repodata between yum_src and cdnsync

* Tue Aug 09 2016 Gennadii Altukhov <galt@redhat.com> 2.6.30-1
- cdn-sync - check proxy port number

* Tue Aug 09 2016 Jan Dobes 2.6.29-1
- initialize before _load_entitlements is called
- check if there are any available channels first
- filter channel families with ssl credentials - they are 'activated'
- fixing listing of channels for some empty channel families

* Mon Aug 08 2016 Jan Dobes 2.6.28-1
- handle missing cdn mappings
- W0201: attribute defined outside init
- string.join is deprecated

* Mon Aug 08 2016 Jan Dobes 2.6.27-1
- do not download comps if not downloading packages
- pass less parameters inside class
- fixing --no-packages

* Fri Aug 05 2016 Gennadii Altukhov <galt@redhat.com> 2.6.26-1
- Impove error message about missing parent channels
- cdn-sync - add debug-level verification
- cdn-sync - add proxy url convertor from ascii to puny
- cdn-sync - remove temporary certificates

* Fri Aug 05 2016 Gennadii Altukhov <galt@redhat.com> 2.6.25-1
- fix pep8 'Line too long'
- bugfix - typo in variable name
- cdn-sync - add to syncing kickstartable trees: - parameterized values for
  rhnKSTreeType and rhnKSInstallType - possibility to select kickstartable
  trees with NULL organisation id
- bugfix - remove temporary file if there is an error during downloading by
  yum-wrapper
- cdn-sync - exclude kickstart repositories only if we have them in config file

* Thu Aug 04 2016 Jan Dobes 2.6.24-1
- handle not existing channels
- we don't support RHEL 5 already

* Wed Aug 03 2016 Jan Dobes 2.6.23-1
- better look for existing erratum by advisory name now
- always set advisory with version number and be different than advisory_name
- do not crash for now

* Wed Aug 03 2016 Jan Dobes 2.6.22-1
- support strict package subscription to channel
- fixing pep8
- unused import
- unused variable

* Fri Jul 29 2016 Jan Dobes 2.6.21-1
- simplify and allow to use other parameters without channel parameter
- rename to plural to have same parameter as in satsync
- show more info like in satsync
- Revert "check if DB is running"

* Fri Jul 29 2016 Jan Dobes 2.6.20-1
- check if DB is running

* Thu Jul 28 2016 Gennadii Altukhov <galt@redhat.com> 2.6.19-1
- cdn-sync - add handling of database connection error
- bugfix - Check connection to a DB is open before make commit()
- Make reraising of exception compatible with Python 2 and 3. Additional
  changes to commit 20ba5c63b13b2afe0a4c0340cc5538dae8f5c018
- simplify condition

* Wed Jul 27 2016 Gennadii Altukhov <galt@redhat.com> 2.6.18-1
- build cdn-sync only for RHEL > 5 and Fedora
- cdn-sync - add syncing of kickstart repositories - reposync now doesn't
  terminate a program if one of channels doesn't exist - add posibility to
  exclude some repos from syncing

* Wed Jul 27 2016 Jan Dobes 2.6.17-1
- fixing typo
- count total time of sync

* Tue Jul 26 2016 Jan Dobes 2.6.16-1
- distinct by checksum to connect multiple packages with same nevrao to
  erratum, not only one of them
- fixing multiple packages in null org without channel - pick the last one
- support syncing only RPMs metadata

* Tue Jul 26 2016 Eric Herget <eherget@redhat.com> 2.6.15-1
- 1345843 - sane output when diff of binary config files

* Wed Jul 20 2016 Gennadii Altukhov <galt@redhat.com> 2.6.14-1
- cdn-sync -  fix pylint warnings and errors
- bug fix in cache of reposync when several repos assigned on channel
- cdn-sync - change path for cache repodata, do not save primary.xml and
  repomd.xml on disk
- cdn-sync - show progress bar during updating repodata
- cdn-sync - add number of packages to channel listing output
- cdn-sync - Implement cdn-sync parameter for repodata updating
- cdn-sync - Implement cdn-sync parameter for just listing assigned
  repositories for channels
- cdn-sync - bugfix in listing child channels. Show only those of child
  channels which belong to channel families from manifest.
- cdn-sync - add workaroud for missing RHN to CDN source matching * checking
  that we have mapping in config json * if channel doesn't have at least one
  source, skip it during syncing
- cdn-sync - add exceptions to handling during channel import
- cdn-sync - add parameter to print current configuration file
- cdn-sync - add support of different debug levels for cdn-sync and reposync
- cdn-sync - use the same config (CFG object) for cdn-sync, reposync and yum-
  repo-plugin
- cdn-sync - add parameters for http proxy and blocking of concurrent runs of
  cdn-sync

* Tue Jul 19 2016 Grant Gainey 2.6.13-1
- change default checksum type to sha256 for debían packages. Usage of SHA256
  is recommended in https://wiki.debian.org/RepositoryFormat#Size.2C_MD5sum.2C_
  SHA1.2C_SHA256.2C_SHA512 This should also fix RH BZ 1348321
- Fixes unnecessary removal of whitespaces in package dependencies. Needed for
  correct creation of Packages.gz
- 1226329 - sense support for debian packages

* Mon Jul 18 2016 Jiri Dostal <jdostal@redhat.com> 2.6.12-1
- 1357480 - get_possible_orgs function never called? -> removed

* Tue Jul 12 2016 Grant Gainey 2.6.11-1
- 1355884 - teach xmlWireSource to be able to write to tempfile

* Fri Jul 01 2016 Jiri Dostal <jdostal@redhat.com> 2.6.10-1
- spacewalk-repo-sync fix for missing -c parameter

* Wed Jun 22 2016 Jiri Dostal <jdostal@redhat.com> 2.6.9-1
- 1348575 - Many tools from spacewalk-backend-tools package returning Python
  tracebacks when run under non-root user
- list only custom channels

* Mon Jun 20 2016 Jan Dobes 2.6.8-1
- pep8
- fixing pylint

* Mon Jun 20 2016 Jan Dobes 2.6.7-1
- Revert "sync content strictly - only packages from batch will be in channel"

* Wed Jun 15 2016 Jan Dobes 2.6.6-1
- make CDN root configurable

* Wed Jun 15 2016 Jan Dobes 2.6.5-1
- do not delete and insert everything on every call
- Revert "old families should not be visible after reactivation"

* Tue Jun 14 2016 Jan Dobes 2.6.4-1
- fix satellite-sync and do not delete and insert on every cdn-sync
- simlify content sources import and do not delete and insert on every cdn-sync
- fixing incorrect name of variable

* Mon Jun 13 2016 Jan Dobes 2.6.3-1
- fixing pylint in cdnsync module and little refactoring
- fixing pylint in activation module
- fixing pylint in contentRemove module
- missing import

* Fri Jun 10 2016 Jan Dobes 2.6.2-1
- make possible to clear packages in null-org outside channels (partially
  synced channels)
- add functions to remove content outside channels
- move spacewalk-remove-channel code into new module
- sync content strictly - only packages from batch will be in channel
- allow reposync to subscribe packages to channel strictly
- show which channel is processed
- support --no-errata
- support --no-packages
- fixing synced channel indicator
- list skipped errata
- it's not an error
- channel families may not be in filtered list
- find ssl keys for families
- unlock null org channels
- run sync
- import content sources for channels
- teach backend to insert content sources
- dist channel mapping
- insert channel metadata
- adding available channel listing
- add linking channel families with certificates
- refactor to class
- insert families matching product data only
- old families should not be visible after reactivation
- lookup in separate function
- fix rhnContentSourceSsl -> rhnContentSsl in code
- import channel families
- reusing previously dropped satellite certificate class
- insert SSL credentials from file and manifest into DB
- start to build -cdn package
- refactoring satCerts to make possible insert into single org/null org

* Tue Jun 07 2016 Jan Dobes 2.6.1-1
- print() prints '()' in python 2 instead of expected empty line
- fix chgrp call on openSUSE
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.43-1
- fix missing new line in translation
- updating copyright years
- Regenerating .po and .pot files for spacewalk-backend.
- Updating .po translations from Zanata

* Fri May 20 2016 Grant Gainey 2.5.42-1
- fix isSUSE check

* Wed May 18 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.41-1
- Only trigger virtualization notification on server save when the
  virtualization data is not falsy

* Fri May 13 2016 Gennadii Altukhov <galt@redhat.com> 2.5.40-1
- moving rhnLib.py into spacewalk-backend-libs package,
- Fix check for local URI

* Thu May 12 2016 Gennadii Altukhov <galt@redhat.com> 2.5.39-1
- change build dependency on python-devel, because we don't use Python3 during
  package building

* Wed May 11 2016 Gennadii Altukhov <galt@redhat.com> 2.5.38-1
- fix imports of usix

* Tue May 10 2016 Grant Gainey 2.5.37-1
- spacewalk-backend: build on openSUSE - specfile fixes
- spacewalk-backend: build on openSUSE
- 1331271 - fix string concatenation

* Mon Apr 25 2016 Gennadii Altukhov <galt@redhat.com> 2.5.36-1
- Add missing sys imports

* Fri Apr 22 2016 Gennadii Altukhov <galt@redhat.com> 2.5.35-1
- Add mode to open packages as 'binary'
- Fix relative imports for python backend-common libs
- Automatic commit of package [spacewalk-backend] release [2.5.34-1].
- fix building of spacewalk-backend

* Fri Apr 22 2016 Tomas Lestach <tlestach@redhat.com> 2.5.34-1
- fix building of spacewalk-backend

* Thu Apr 21 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.33-1
-

* Thu Apr 21 2016 Gennadii Altukhov <galt@redhat.com> 2.5.32-1.git.1.151aa47
- Add missing import 'sys'

* Wed Apr 20 2016 Gennadii Altukhov <galt@redhat.com> 2.5.31-1.git.1.151aa47
- Add new packages for spacewalk-backend-libs and usix
- Fix usix module to run under Python 3

* Tue Apr 19 2016 Gennadii Altukhov <galt@redhat.com> 2.5.30-1
- Resolve conflicts between usix and backend-libs
- Fix pylint warnings/fails
- fix usix next() import and usage

* Mon Apr 18 2016 Gennadii Altukhov <galt@redhat.com> 2.5.29-1
- Fix 'iteritems' in backend Python 2/3 compatibility
- Fix '.next()' in backend Python 2/3 compatibility
- Add import of 'reduce' function in backend for Python 3 compatibility
- Fix 'exc_type' in backend code for Python 2/3 compatibility
- Fix 'unicode' in backend code for Python 2/3 compatibility
- Fix 'apply' in backend code for Python 2/3 compatibility
- Fix 'maxint' in backend code for Python 2/3 compatibility
- Fix 'exitfunc' in backend code for Python 2/3 compatibility
- Fix 'raw_input' in backend code for Python 2/3 compatibility
- Fix imports in backend code for Python 2/3 compatibility
- Fix data types in backend code for Python 2/3 compatibility
- Fix 'dict' in backend code for Python 2/3 compatibility
- Add __bool__ in backend code for Python 2/3 compatibility
- Fix 'filter' in backend code for Python 2/3 compatibility
- Fix 'map' in backend code for Python 2/3 compatibility
- Fix 'xrange' in backend code for Python 2/3 compatibility
- Fix 'octal' format of number in backend code for Python 2/3 compatibility
- Fix 'raise' in backend code for Python 2/3 compatibility
- Fix 'except' in backend code for Python 2/3 compatibility
- Fix 'has_key' in backend code for Python 2/3 compatibility
- Fix 'print' in backend code for Python 2/3 compatibility
- Add micro-six python module to write code that runs on Python 2 and 3

* Wed Mar 23 2016 Jan Dobes 2.5.28-1
- qemu-kvm guests created on my Fedora 22 have following signature, mark them
  as virtual

* Tue Mar 22 2016 Jan Dobes 2.5.27-1
- 1320025 - call notify guest before subscribing to channels too and refactor
  code

* Fri Mar 18 2016 Jan Dobes 2.5.26-1
- Fix for bz1309337 'rhnreg_ks doesn't work with activation key'

* Wed Mar 09 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.25-1
- 1276569 - we need to import either cx_Oracle or psycopg2

* Thu Mar 03 2016 Jan Dobes <jdobes@redhat.com> 2.5.24-1
- 1308486 - better never import foreign private channel families, custom
  channels will be synced into your org anyway
- 1308486 - org_id of channel family is probably never filled, just not make
  private channel families public

* Wed Mar 02 2016 Jan Dobes 2.5.23-1
- all strings should be truncated, not only unicode instances

* Fri Feb 26 2016 Jan Dobes 2.5.22-1
- make sure truncated value does not contain incomplete characters

* Fri Feb 19 2016 Grant Gainey 2.5.21-1
- 1303422 - allow sat-sync-error-email to be configurable

* Thu Feb 18 2016 Jan Dobes 2.5.20-1
- pulling *.po translations from Zanata
- fixing current *.po translations

* Thu Feb 18 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.19-1
- Remove self from staticmethod
- Fix Python errors from CI build and rename sort function for consistency.
- Remove custom latest RPM handling in spacewalk-repo-sync and use the same
  logic as reposync from yum-utils instead.

* Fri Feb 05 2016 Grant Gainey 2.5.18-1
- 1305051 - fix broken 'raise' on error

* Tue Feb 02 2016 Jan Dobes 2.5.17-1
- 1303524 - do not import errata to all synced channels because some may not
  have all packages synced
- 1276569 - improve message

* Mon Feb 01 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.16-1
- 1276569 - fix pylint

* Fri Jan 29 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.15-1
- 1276569 - advise users to purge satsync cache on IntegrityError

* Thu Jan 28 2016 Jan Dobes 2.5.14-1
- 1302817 - making sure packages without errata are included
- 1302817 - fixing invalid query

* Fri Jan 22 2016 Jan Dobes 2.5.13-1
- 1301137 - update guest also on re-registration
- 1301137 - allow to change uuid of already registered guests
- 1301137 - there can be guests without hypervisor registered
- fixing exception when reactivating system without base channel and without
  any available

* Thu Jan 21 2016 Gennadii Altukhov <galt@redhat.com> 2.5.12-1
- 1051018 - Added filename in the error message of satellite-sync, in case file
  has wrong size
- 1281775 - Added processing of ValueError exception, during spacewalk-data-
  fsck

* Tue Jan 19 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.11-1
- local variable 'primif' referenced before assignment

* Thu Jan 14 2016 Jan Dobes 2.5.10-1
- cleaning few old translations
- removing old duplicate template file

* Tue Jan 12 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.9-1
- 1297752 1297753 - allow client responses to be in Unicode

* Thu Dec 10 2015 Jan Dobes 2.5.8-1
- making synced channels in null org visible to all orgs

* Mon Dec 07 2015 Jan Dobes 2.5.7-1
- fixing append to None when no org is found

* Fri Dec 04 2015 Jan Dobes 2.5.6-1
- when installing insert default SSL crypto key with null org

* Mon Nov 30 2015 Tomas Lestach <tlestach@redhat.com> 2.5.5-1
- fix typo: lastest -> latest

* Tue Nov 24 2015 Jan Dobes 2.5.4-1
- ignore all not any longer supported entitlements
- backend: remove repoll parameter from
  rhn_entitlements.remove_server_entitlement()
- backend: do not use rhn_entitlements.repoll_virt_guest_entitlements() anymore
- backend: errno 20220 (Server Group Membership exceeded) is not thrown anymore
- backend: remove use of rhn_entitlements.activate_system_entitlement()
- satCert, satsync: checkstyle fixes
- satsync.py: fix merge error
- backend: remove max_members from unit tests
- remove max_member update from rhnServerGroup
- drop rhnFault 91
- ISS: export 10 system entitlements and import none
- drop rhn-entitlement-report
- remove comments
- remove unused function entitlement_grants_service()
- It should always work to add with enterprise_entitled
- Removed unused exception
- backend: dead code removal
- rhn-satellite-activate: manual references removed
- rhn-satellite-activate: dropped
- satellite-sync: don't sync the certificate
- server_class.py: remove dead code
- rhnHandler: don't check for certificate expiry
- satCerts.py: remove comment reference to dropped file
- rhn_satellite_activate: remove unused validateSatCert function
- rhn_satellite_activate: don't check certificate validity
- rhn_satellite_activate: outdated comment removed
- import: don't import rhnVirtSubLevel
- import: don't import from rhnSGTypeVirtSubLevel
- import: don't import table rhnChannelFamilyVirtSubLevel
- export refactoring: remove unused parameters/fields
- export refactoring: remove unused query
- export: don't export rhnChannelFamilyVirtSubLevel
- export refactoring: unused attributes removed
- import refactoring: unused attribute removed
- backend: remove virtualization host platform entitlement references
- backend: remove references to nonlinux entitlements
- backend: remove comments that are not relevant anymore
- backend: remove references to the update entitlement
- rhn-entitlement-report: don't filter update entitlements
- python backend unit tests: remove references to provisioning_entitled
- registration.py: remove references to provisioning_entitled in documentation
- backend: remove references to provisioning_entitled
- backend: commented code removed
- backend: unused reg_num parameter removed from documentation
- Change error message for NoBaseChannel Exception
- Remove monitoring from cert tools
- Remove traces of monitoring from registration.py doc
- backend: do not set max_members of rhnChannelFamily
- backend: do not set values for max_members and current_members
- backend: remove unused ChannelFamilyPermissions class
- backend: remove special handling for SubscriptionCountExceeded
- backend: remove unused imports
- entitlement-report: remove channel entitlement views
- backend: remove unused ChannelFamilyPermissionsImport() and
  processChannelFamilyPermissions
- backend: remove populate_channel_family_permissions and
  purge_extra_channel_families from sync_handler
- backend: remove local handling of channel family members from satsync
- backend: remove channel subscription checks from rhn-satellite-activate
- backend: update rhn_channel.subscribe_server signature
- backend: remove usage of update_family_counts
- backend: remove available_subscriptions from channel object
- backend: remove family count handling from server_kickstart
- backend: remove family count handling from server_token

* Sun Oct 18 2015 Aron Parsons <aronparsons@gmail.com> 2.5.3-1
- don't print python object details in reposync.py

* Mon Oct 12 2015 Jiri Dostal <jdostal@redhat.com> 2.5.2-1
- [RFE] spacewalk-repo-sync: support multiple '-c channel' as in satellite-sync

* Wed Oct 07 2015 Aron Parsons <aronparsons@gmail.com> 2.5.1-1
- recognize RDO OpenStack instances as virtual systems
- Bumping package versions for 2.5.

* Wed Sep 23 2015 Jan Dobes 2.4.23-1
- Pulling updated *.po translations from Zanata.

* Mon Sep 21 2015 Jan Dobes 2.4.22-1
- 1250351 - make sure ks tree label is valid

* Fri Sep 18 2015 Jan Dobes 2.4.21-1
- Realigning arguments to process_batch to conform to indentation standards -
  see https://www.python.org/dev/peps/pep-0008/#indentation
- Fixed spelling of _proces_batch -> _process_batch.

* Thu Sep 10 2015 Tomas Lestach <tlestach@redhat.com> 2.4.20-1
- call xz to decompress comps file directly, if pyliblzma not available

* Tue Sep 08 2015 Jan Dobes 2.4.19-1
- 1201007 - handle existing file
- optimize experssion

* Mon Sep 07 2015 Tomas Lestach <tlestach@redhat.com> 2.4.18-1
- 1260735 - set domain name for sender address in rhn-satellite-exporter

* Fri Aug 28 2015 Jan Dobes 2.4.17-1
- Fixes orabug 20623622 spacewalk-repo-sync error: maximum recursion depth
  exceeded error when syncing to ULN via a proxy server

* Tue Aug 25 2015 Grant Gainey 2.4.16-1
- 1256918 - Handle package_group == None on push

* Tue Aug 18 2015 Jiri Dostal <jdostal@redhat.com> 2.4.15-1
- 1097634 - reposync fixed pylint warnings

* Fri Aug 14 2015 Jiri Dostal <jdostal@redhat.com> 2.4.14-1
- RFE 1097634 - fixed package sorting             - removed package
  disassociation

* Fri Aug 07 2015 Jan Dobes 2.4.13-1
- use hostname instead of localhost for https connections

* Tue Aug 04 2015 Jiri Dostal <jdostal@redhat.com> 2.4.12-1
-  - patch for reposync (pylint)

* Thu Jul 30 2015 Jiri Dostal <jdostal@redhat.com> 2.4.11-1
- [RFE] - --latest feature for spacewalk-repo-sync

* Fri Jul 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.10-1
- require cobbler20 - Spacewalk is not working with upstream cobbler anyway
- remove un-intentional changes
- 1181152 - XSS when altering user details and going somewhere where you are
  choosing user         - Escaped tags in real names

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.9-1
- remove Except KeyboardInterrupt from imports
- remove Except KeyboardInterrupt from imports
- remove un-necessary try-except construct

* Fri Jun 26 2015 Jan Dobes 2.4.8-1
- 1235827 - there is no such restriction for user names

* Thu Jun 11 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.7-1
- Recommends is not ignored on older systems

* Wed Jun 10 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.6-1
- add weak dependency on cobbler20

* Wed May 27 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.5-1
- fix pylint warnings on Fedora 22

* Thu May 21 2015 Matej Kollar <mkollar@redhat.com> 2.4.4-1
- 1175516 - Typos in rhn-entitlement-report output

* Thu May 14 2015 Stephen Herr <sherr@redhat.com> 2.4.3-1
- do not reset primary network interface at hardware refresh (bnc#895071)
- set primary interface during registration (bnc#929058)

* Tue May 12 2015 Stephen Herr <sherr@redhat.com> 2.4.2-1
- Implement the new rpm weak dependency tags.

* Fri Apr 24 2015 Matej Kollar <mkollar@redhat.com> 2.4.1-1
- remove whitespace from .sgml files
- Copyright texts updated to SUSE LLC
- Bumping package versions for 2.4.

* Fri Mar 27 2015 Stephen Herr <sherr@redhat.com> 2.3.52-1
- 1206350 - Add API to Satellite for Proxy to check client token validity
- 1206350 - send error headers even on 404 response

* Mon Mar 23 2015 Grant Gainey 2.3.51-1
- Standardize pylint-check to only happen on Fedora
- Import topic, summary and collected references from updateinfo.xml on
  reposync

* Thu Mar 19 2015 Grant Gainey 2.3.50-1
- Updating copyright info for 2015

* Wed Mar 18 2015 Stephen Herr <sherr@redhat.com> 2.3.49-1
- 1203406 - make Satellite able to respond to if-modified-since requests

* Tue Mar 10 2015 Tomas Lestach <tlestach@redhat.com> 2.3.48-1
- removing unused backend perl tests

* Mon Mar 09 2015 Jan Dobes 2.3.47-1
- 1197765 - support postgresql92 from software collections

* Thu Mar 05 2015 Stephen Herr <sherr@redhat.com> 2.3.46-1
- backend: check for reboot type only

* Wed Feb 25 2015 Tomas Lestach <tlestach@redhat.com> 2.3.45-1
- removing system details edit.pxt as it was ported to java

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.44-1
- convert empty string to null for DMI values
- init the second DB connection only when needed
- Fix the primary key definition for rhnPackageFile
- Do not include obsolete rhn_monitoring.conf
- spacewalk-debug should not collect monitoring logs
- remove nocpulse user and group from spacewalk-debug

* Fri Feb 13 2015 Stephen Herr <sherr@redhat.com> 2.3.43-1
- 1192608 - disable pylint warning

* Fri Feb 13 2015 Stephen Herr <sherr@redhat.com> 2.3.42-1
- 1192608 - moving import to be more local to make builders happy

* Fri Feb 13 2015 Stephen Herr <sherr@redhat.com> 2.3.41-1
- 1192608 - add support for lzma compressed yum metadata files

* Fri Feb 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.40-1
- Bump also also BuildRequires for consistency

* Fri Feb 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.39-1
- Bumping required version of rhnlib

* Tue Feb 03 2015 Matej Kollar <mkollar@redhat.com> 2.3.38-1
- Updating function names

* Fri Jan 30 2015 Stephen Herr <sherr@redhat.com> 2.3.37-1
- 1187358 - don't crash re-registrations if the original owner has been deleted

* Fri Jan 30 2015 Grant Gainey 2.3.36-1
- 1104087 - Some cleanup and tweaks
- 1104087 - Adding option [-g|--config]

* Fri Jan 30 2015 Tomas Lestach <tlestach@redhat.com> 2.3.35-1
- Adding on the spacewalk-data-fsck man page the option --remove-mismatch
- add funcionality on spacewalk-data-fsck to remove the RPM which does not
  match checksum

* Fri Jan 30 2015 Matej Kollar <mkollar@redhat.com> 2.3.34-1
- 1070866 - sw-repo-sync fails to sync kickstart.

* Wed Jan 28 2015 Matej Kollar <mkollar@redhat.com> 2.3.33-1
- 1005772 - Add appropriate(?) censorship

* Thu Jan 22 2015 Matej Kollar <mkollar@redhat.com> 2.3.32-1
- More pep8
- Some more pep8 while we are at it

* Wed Jan 21 2015 Matej Kollar <mkollar@redhat.com> 2.3.31-1
- Old Pylint workaround
- Fix Pylint on Fedora 21: manual fixes
- Fix Pylint on Fedora 21: autopep8

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.30-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Thu Dec 18 2014 Stephen Herr <sherr@redhat.com> 2.3.29-1
- teach sat-sync to ignore monitoring entitlements for backwards compatibility

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.28-1
- Remove solaris support from backend
- drop monitoring code and monitoring schema

* Mon Dec 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.27-1
- 1170616 - create (and label) /var/cache/rhn/satsync

* Tue Dec 02 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.25-1
- 1021057 - fixed double-counting of systems subscribed to more than one
  channel

* Tue Nov 18 2014 Stephen Herr <sherr@redhat.com> 2.3.24-1
- 1122626 - different registration paths should lock tables in the same order
  This could potentially cause deadlocks

* Thu Nov 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.23-1
- 1150010 - deny read-only user from accessing XMLRPC API

* Mon Nov 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.22-1
- 1162107 - sanitize db_* config values

* Thu Oct 30 2014 Tomas Lestach <tlestach@redhat.com> 2.3.21-1
- start enforcing minimum password length for satpasswd

* Fri Oct 24 2014 Matej Kollar <mkollar@redhat.com> 2.3.20-1
- 1151386 - Fix cleanup when DB init goes wrong

* Thu Oct 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.19-1
- 1152271 - sanitize db_name config value

* Wed Oct 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.18-1
- 1148163 - fixed variable name

* Tue Sep 30 2014 Stephen Herr <sherr@redhat.com> 2.3.17-1
- remove deprecated allowed_iss_slaves config option

* Fri Sep 26 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.16-1
- 1144008 - support for xz compressed repos

* Tue Sep 16 2014 Stephen Herr <sherr@redhat.com> 2.3.15-1
- 1142412 - backend should correctly checksum config files with macros in them

* Fri Sep 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.14-1
- Add /usr/share/rhn/config-defaults in spacewalk-debug
- 1138275 - spacewalk-debug is not fully postgreSQL aware.

* Thu Sep 11 2014 Stephen Herr <sherr@redhat.com> 2.3.13-1
- 959567 - use sha256 checksums for config files instead of md5

* Wed Sep 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.12-1
- 1022484 - ask for new password twice

* Fri Sep 05 2014 Jan Dobes 2.3.11-1
- 1115007 - correct UTF8 config files from being marked as binary

* Fri Sep 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.10-1
- 1021057 - do not double-count systems subscribed to more than one channel
  from the same channel family

* Fri Aug 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.9-1
- fix traceback when pushing rpms with archive size > 4GB

* Tue Aug 19 2014 Stephen Herr <sherr@redhat.com> 2.3.8-1
- 1119459 - queue server for errata cache update when package list changes

* Tue Aug 19 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.7-1
- recognize oVirt node as virtual system

* Fri Aug 15 2014 Stephen Herr <sherr@redhat.com> 2.3.6-1
- 1128893 - sw-repo-sync does not work for chann that are children of non-
  custom parents

* Mon Aug 11 2014 Stephen Herr <sherr@redhat.com> 2.3.5-1
- 1128893 - repo-sync should work even if parent is not custom channel
- 1122438 - SQL syntax fix (extraneous comma)

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- Update spacewalk-backend.spec

* Mon Jul 21 2014 Stephen Herr <sherr@redhat.com> 2.3.3-1
- 1023557 - Speed up satellite-sync by avoiding commonly-called dblink_exec

* Thu Jul 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- pylint fixes for 2a3787142af8185d3b7a95d31b681b3cabba852a

* Thu Jul 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- 1120261 - added code to update-packages to fix changelog encoding

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.43-1
- 1005729 - man rhn-satellite-exporter org
- fix copyright years
- 1009961 - rhn-satellite-exporter man page update
- 1009430 - rhn-satellite-exporter/spacewalk-remove-channel as non-root

* Tue Jul 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.42-1
- fixed name collision
- old python needs maketrans()

* Tue Jul 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.41-1
- moved ContentPackage to repo_plugins to avoid relative imports
- selecting password once shall be enough

* Mon Jun 30 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.40-1
- max_bytes is unused
- fixed ProductNamesContainer instance has no attribute 'tagStack'

* Fri Jun 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.39-1
- pylint fixes

* Fri Jun 27 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.38-1
- fixed pylint errors in satellite_tools

* Thu Jun 26 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.37-1
- 1043005 - fixed rhnLog namespace

* Fri Jun 20 2014 Stephen Herr <sherr@redhat.com> 2.2.36-1
- 1108370 - enable proxy to serve files from its cache for kickstarts

* Fri Jun 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.35-1
- disable read-only users access of the backend api

* Fri Jun 06 2014 Stephen Herr <sherr@redhat.com> 2.2.34-1
- 1105282 - additional spacewalk backend methods and capability needed

* Thu Jun 05 2014 Stephen Herr <sherr@redhat.com> 2.2.33-1
- 1105282 - Spacewalk changes needed to support collisionless proxy lookaside

* Mon Jun 02 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.32-1
- rpm initialization bug has been resloved

* Fri May 30 2014 Stephen Herr <sherr@redhat.com> 2.2.31-1
- 517468 - Adding option [-p|--parent]

* Fri May 23 2014 Stephen Herr <sherr@redhat.com> 2.2.30-1
- 517468 - make format backwards compatible for python 2.4
- 517468 - Correct the unindents to fix the logic.
- 517468 - Adding option [-d|--dry-run]

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.29-1
- spec file polish
- fixed 'empty separator' error

* Fri May 16 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.28-1
- rewrite uln_src plugin as yum_src plugin subclass
- Added Oracle Unbreakable Linux Network integration to spacewalk-repo-sync
- 1094526 - remove trailing semi-colon from SQL query as this breaks Oracle
- Raise error if channel cannot be subscribed
- python tests: made easier to toggle db backend

* Tue May 13 2014 Tomas Lestach <tlestach@redhat.com> 2.2.27-1
- let reposync ContentPackage return regular nevra

* Mon May 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.26-1
- query channels only in --list mode

* Tue Apr 29 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.25-1
- spacewalk-fips-tool: add manual page

* Mon Apr 28 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.24-1
- spacewalk-fips-tool: tool to help with client certificate conversion

* Fri Apr 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.23-1
- fix variable name

* Thu Apr 24 2014 Stephen Herr <sherr@redhat.com> 2.2.22-1
- 1089678 - Format oldRoute to match newRoute, so that rhnServerPath isn't
  updated every time
- 517468 - Adding option [-l|--list]

* Wed Apr 23 2014 Stephen Herr <sherr@redhat.com> 2.2.21-1
- 578835 - [RFE] Add --justks to sw-remove-channel
- 1088813 - sw-remove-channel --justdb has no impact on ks trees.
- 1086348 - rename channel-with-childs to channel-with-children
- 1086348 - [RFE] Add option to spacewalk-remove-channel parent

* Tue Apr 15 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.20-1
- updated (conflicting) rpm package has been pushed to Fedora 19 updates

* Mon Apr 14 2014 Jan Dobes <jdobes@redhat.com> 2.2.19-1
- fixing syntax error

* Thu Apr 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.18-1
- add server side code for handling clientcert.update_client_cert
- update_systemid: routine to update server secret and client certificate
- Added spacewalk-data-fsck man page(8)

* Tue Apr 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.17-1
- fixed client registration

* Fri Apr 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.16-1
- 903068 - fixed debian repo generation
- make spacewalk-repo-sync work with null org channels

* Tue Apr 01 2014 Stephen Herr <sherr@redhat.com> 2.2.15-1
- 1083226 - uniquify repo-sync packages in case of bad metadata

* Tue Apr 01 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.14-1
- 1025781 - allow MD5 config file checksums in fips mode

* Tue Apr 01 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.13-1
- use getHashlibInstance() wrapper to access hashlib object instance
- 1020895 - allow to compute md5 package checksum in fips mode

* Mon Mar 31 2014 Stephen Herr <sherr@redhat.com> 2.2.12-1
- set reboot action status to sucess after the reboot
- 1025750 - getFileChecksum: add used_for_security boolean parameter

* Fri Mar 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.11-1
- server certificates to use a sha256 hash by default

* Tue Mar 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.10-1
- we need to be catching one more error message from gpg
- delete non-existing directory on interrupted downloads

* Mon Mar 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.9-1
- satpasswd man page: mention -s / --stdin options
- satpasswd supports SHA-256 encrypted user passwords

* Mon Mar 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.8-1
- RPC session hash: md5 -> sha256
- Support SHA-256 encrypted user passwords

* Fri Mar 14 2014 Stephen Herr <sherr@redhat.com> 2.2.7-1
- reposync: remove interrupted downloads
- More appropriate data structure

* Fri Mar 07 2014 Stephen Herr <sherr@redhat.com> 2.2.6-1
- 1045083 - not all machines provide manufacturer, was not None safe

* Thu Mar 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- remove usage of web_contact.old_password from code

* Wed Mar 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.4-1
- 1072872 - fixed loop variable name

* Tue Mar 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.3-1
- 1041346 - spacewalk-remove-channel man page update

* Fri Feb 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.2-1
- python: consolidate backen/server tests
- python tests: fixed rhnsql-tests

* Tue Feb 25 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- 1067443 - specify package only with version

* Mon Feb 24 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.54-1
- 1067443 - workaround for rpm-python bug

* Fri Feb 21 2014 Stephen Herr <sherr@redhat.com> 2.1.53-1
- 1045083 - update openstack guest requirements

* Thu Feb 20 2014 Stephen Herr <sherr@redhat.com> 2.1.52-1
- 1045083 - Detect OpenStack guests as virtual so they can consume flex guest

* Tue Feb 18 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.51-1
- 1064296 - rename variable so it doesn't colide with reserved word

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

