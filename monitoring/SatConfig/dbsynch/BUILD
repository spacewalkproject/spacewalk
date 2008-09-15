# Macros

%define cvs_package SatConfig/dbsynch
%define install_prefix /home/nocpulse/bin

# Package specific stuff
Name:         SatConfig-dbsynch
Version:      1.3.0
Release:      0
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Satellite Configuration System - database synchronizer
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    Red Hat, Inc (c) 2001-2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package


%description

SatConfig-dbsynch defines a mechanism by which config pusher logic can explicitly
tell the current state database to synchronize itself with the config db

%prep
%entirely_abstract_build_step

%build

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%install_prefix
install -o root -g root -m 700 synch.sh $RPM_BUILD_ROOT%install_prefix
install -o root -g root -m 700 synch.sqplus $RPM_BUILD_ROOT%install_prefix

%point_scripts_to_correct_perl
%make_file_list 

%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
