# Macros

%define cvs_package    SatConfig/ApacheDepot

%define basedir /opt/apache_depot

%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         SatConfig-ApacheDepot
Source9999: version
Version: %(echo `awk '{ print $1 }' %{SOURCE9999}`)
Release: %(echo `awk '{ print $2 }' %{SOURCE9999}`)
Summary:      ApacheDepot directory structure
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    NOCpulse (c) 2000
Vendor:       NOCpulse
Prefix:	      %install_prefix
Buildroot:    %buildroot

%description

Installs dir structure for Apache depot

%prep
%setup
%build
# nothing to build

%install
mkdir -p %buildroot%basedir/bin
mkdir -p %buildroot%basedir/cgi-bin
mkdir -p %buildroot%basedir/cgi-mod-perl
mkdir -p %buildroot%basedir/conf
mkdir -p %buildroot%basedir/htdocs/depot
mkdir -p %buildroot%basedir/icons
mkdir -p %buildroot%basedir/include
mkdir -p %buildroot%basedir/libexec
mkdir -p %buildroot%basedir/logs
mkdir -p %buildroot%basedir/man
mkdir -p %buildroot%basedir/proxy
mkdir -p %buildroot%basedir/templates



%files
%basedir

%clean
%abstract_clean_script
