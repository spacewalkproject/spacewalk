# Macros

%define cvs_package SatConfig/bootstrap

%define install_prefix /home/nocpulse/bin
%define init_prefix    /etc/rc.d/init.d
%define sysv_prefix    /etc/rc.d/rc3.d
%define sysv_dir       /etc/rc.d/np.d

# Package specific stuff
Name:         SatConfig-bootstrap
Version:      1.9.1
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Satellite Configuration System - satellite id installer
Source:	      SatConfig-bootstrap-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl np-config NPusers
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

SatConfig-bootstrap queries NOCpulse for the contents of the netsaintId file

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%install_prefix
mkdir -p $RPM_BUILD_ROOT%init_prefix
mkdir -p $RPM_BUILD_ROOT%sysv_dir
cp npBootstrap.pl $RPM_BUILD_ROOT%install_prefix

%point_scripts_to_correct_perl


%files
%attr(755,nocpulse,nocpulse) %install_prefix/npBootstrap.pl


%clean
%abstract_clean_script

