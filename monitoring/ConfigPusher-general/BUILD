# Macros

%define cvs_package    ConfigPusher-general

%define install_prefix /home/nocpulse
%define exe_dir        %install_prefix/bin
%define cfg_dir        %install_prefix/etc
%define libexec_dir    %install_prefix/libexec
%define var_dir        %install_prefix/var
%define archive_dir    %var_dir/archives

%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         ConfigPusher-general
Version:      1.2.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      ConfigPusher Configuration System - general setup, used by many packages
Source:       ConfigPusher-general-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     SatConfig-general
PreReq:       NPusers
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000 - 2003
Vendor:       Red Hat, Inc.
Prefix:       %install_prefix
Buildroot:    %buildroot

%description

ConfigPusher-general sets up directories and other items shared by many
packages to make a satellite work.  Blatant hack since SatConfig-general
now provides so much sysv replacement stuff we don't want it on a
ConfigPusher box.

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p %buildroot%install_prefix
mkdir -p %buildroot%exe_dir
mkdir -p %buildroot%cfg_dir
mkdir -p %buildroot%libexec_dir
mkdir -p %buildroot%var_dir
mkdir -p %buildroot%archive_dir

%files
%attr(755,nocpulse,nocpulse) %dir %install_prefix
%attr(755,nocpulse,nocpulse) %dir %exe_dir
%attr(755,nocpulse,nocpulse) %dir %cfg_dir
%attr(755,nocpulse,nocpulse) %dir %libexec_dir
%attr(755,nocpulse,nocpulse) %dir %var_dir
%attr(755,nocpulse,nocpulse) %dir %archive_dir

%clean
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
rm -rf %buildroot
cd $RPM_BUILD_DIR

