# Macros

%define cvs_package SatConfig/logpusher

%define install_prefix /home/nocpulse/bin
%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         SatConfig-logpusher
Version:      1.2.0
Release:      1
Packager:     Adam Pingel <apingel@nocpulse.com>
Summary:      Current state pusher
Source:	      SatConfig-logpusher-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     logpusher
Requires:     perl, np-config, NPusers
Group:        unsorted
Copyright:    NOCpulse (c) 2000
Vendor:       NOCpulse
Prefix:	      %install_prefix
Buildroot:    %buildroot
Prereq:       NPusers

%description

SatConfig-logpusher provides the perl script that pushes the status.log file for current state

%prep
%entirely_abstract_build_step
%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p %buildroot%install_prefix
cp push_current_state.pl %buildroot%install_prefix

%files
%attr(755,nocpulse,nocpulse) %install_prefix/push_current_state.pl

%clean
rm -rf %buildroot
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cd $RPM_BUILD_DIR

%post

# as of 2.11, the current state push is run as a satellite
# probe.  As such, there is no need for cron entry.

rm -f /etc/cron.d/currentstatuspush
