# Macros

%define cvs_package    ssl_bridge
%define logdir         /home/nocpulse/var
%define install_prefix /home/nocpulse/bin
%define logrotate_dir  /etc/logrotate.d
%define user           nocpulse
%define group          nocpulse

# Package specific stuff
Name:         ssl_bridge
Version:      1.9.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      SSL bridge
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl 
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003.  All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

Provides an authenticating relay between an SSL client and an 
unencrypted server.

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

mkdir -p $RPM_BUILD_ROOT%install_prefix
mkdir -p $RPM_BUILD_ROOT%logrotate_dir
mkdir -p $RPM_BUILD_ROOT%logdir; chown %user $RPM_BUILD_ROOT%logdir

install -o root -g root -m 755 ssl_bridge.pl $RPM_BUILD_ROOT%install_prefix
install -o root -g root -m 444 logrotate $RPM_BUILD_ROOT%logrotate_dir/ssl_bridge

%point_scripts_to_correct_perl

%files
%install_prefix/ssl_bridge.pl
%logrotate_dir/ssl_bridge
%dir %logdir


%clean
%abstract_clean_script
