# Macros

%define cvs_package SatConfig/llgen
%define install_prefix /home/httpd/html/nocpulse

# Package specific stuff
Name:         SatConfig-longlegs
Version:      4.3.1
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Long Legs Satellite Configuration System - Server
Source:	      SatConfig-longlegs-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     llconfig.cgi
Requires:     perl, np-config
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix

%description

SatConfig-longlegs is the cgi mechanism by which Longlegs Netsaint configuration files are generated and propagated.  

%prep
# Prep for build. This is entirely abstract - you should not need to change it.
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p %install_prefix
cp llconfig.cgi %install_prefix
cp llconfig.sh %install_prefix

%point_scripts_to_correct_perl 


%files
%attr(755,nocpulse,nocpulse) %dir %install_prefix
%attr(755,nocpulse,nocpulse) %install_prefix/llconfig.sh
%attr(755,nocpulse,nocpulse) %install_prefix/llconfig.cgi


%clean
%abstract_clean_script
