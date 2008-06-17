# Macros

%define cvs_package    SatConfig/ApacheDepot

%define basedir /opt/apache_depot

%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         SatConfig-ApacheDepot
Version:      1.0.0
Release:      0
Packager:     Dave Parker <dparker@nocpulse.com>
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
%entirely_abstract_build_step
%build
# nothing to build

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
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
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
rm -rf %buildroot
cd $RPM_BUILD_DIR
rm -rf SatConfig
