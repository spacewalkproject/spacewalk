# Macros

%define cvs_package    SatConfig/installer
%define install_prefix /home/nocpulse/bin
%define temp_dir       /home/nocpulse/var/tmp
%define config_dir     /home/nocpulse/var/trapReceiver
%define cron_dir       /etc/cron.d

# Package specific stuff
Name:         SatConfig-installer
Version:      3.23.4
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Satellite Configuration System - command line installer
Source:	      SatConfig-installer-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     scheduleEvents
Requires:     perl np-config perl(MIME::Tools) perl-libwww-perl NPusers
Group:        unsorted
Copyright:    Red Hat, Inc.  (c) 2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

SatConfig-installer is the command line mechanism by which Netsaint configuration files are installed and used by Netsaint on satellite boxes.  The program must be run on the satellite.  

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%install_prefix
mkdir -p $RPM_BUILD_ROOT%temp_dir
mkdir -p $RPM_BUILD_ROOT%cron_dir
mkdir -p $RPM_BUILD_ROOT%config_dir

cp scheduleEvents $RPM_BUILD_ROOT%install_prefix
cp validateCurrentStateFiles.pl $RPM_BUILD_ROOT%install_prefix

# Add a cron job for scouts
cat <<EOF >$RPM_BUILD_ROOT%cron_dir/NPkernel
# Config pull for scouts -- a no-op on regular satellites
MAILTO=""
0,30 * * * * nocpulse %install_prefix/scheduleEvents --longlegs
EOF

%point_scripts_to_correct_perl 


%files
%attr(755,nocpulse,nocpulse) %dir %config_dir
%attr(755,nocpulse,nocpulse) %dir %temp_dir
%attr(755,nocpulse,nocpulse) %install_prefix/scheduleEvents
%attr(755,nocpulse,nocpulse) %install_prefix/validateCurrentStateFiles.pl
%attr(755,nocpulse,nocpulse) %cron_dir/NPkernel


%clean
%abstract_clean_script
