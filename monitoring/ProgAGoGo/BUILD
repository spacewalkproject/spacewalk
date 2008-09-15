# Macros

%define cvs_package    ProgAGoGo
%define install_prefix /home/nocpulse
%define bin_dir        %install_prefix/bin
%define buildroot      /tmp/%cvs_package

# Package specific stuff
Name:         %cvs_package
Version:      1.11.0
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Program exec'er/respawner
Source:	      %cvs_package-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     gogo.pl
Requires:     perl
Group:        unsorted
Copyright:    Red Hat, Inc (c) 2000-2003
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

ProgAGoGo is a daemon monitor.  It spawns a daemon and makes sure it
stays alive, respawning it with notification if it dies.

%prep
%entirely_abstract_build_step 

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%bin_dir
cp gogo.pl $RPM_BUILD_ROOT/%bin_dir

%point_scripts_to_correct_perl

%files
%attr(755,nocpulse,nocpulse) %bin_dir/gogo.pl


%clean
%abstract_clean_script
