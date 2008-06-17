# Macros

%define cvs_package PerlModules/NP/ReleaseDB


# Package specific stuff
Name:         NOCpulse-ReleaseDB
Version:      1.15.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl debug output package
Source:	      NOCpulse-ReleaseDB-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl >= 5.00500 NOCpulse-Probe np-config NOCpulse-Debug
Provides:     NOCpulse::ReleaseDB
Group:        unsorted
Copyright:    NOCpulse (c) 2000
Vendor:       NOCpulse
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an API for generating varying levels of debugging output
on various output streams.

%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%find_perl_installsitelib
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse



install -o root -g root -m 444 ReleaseDB.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/ReleaseDB.pm
install -o root -g root -m 444 test/TestRelease.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/test
%make_file_list
%point_scripts_to_correct_perl

%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script

