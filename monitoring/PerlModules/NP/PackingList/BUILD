# Macros

%define cvs_package PerlModules/NP/PackingList

# Package specific stuff
Name:         NOCpulse-PackingList
Version:      1.4.0
Release:      1
Packager:     Karen Jacqmin-Adams <karen@nocpulse.com>
Summary:      PackingList for meta-rpm
Source:	      NOCpulse-PackingList-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl >= 5.00500
Provides:     NOCpulse::PackingList 
Group:        unsorted
Copyright:    NOCpulse (c) 2001
Vendor:       NOCpulse
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an API to the MAINFEST and PACKINGLIST files for the NOCpulse release process.

%prep
%entirely_abstract_build_step

%build

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%find_perl_installsitelib
mkdir -p $RPM_BUILD_ROOT$installsitelib/NOCpulse
install -o root -g root -m 444 PackingList.pm $RPM_BUILD_ROOT$installsitelib/NOCpulse/PackingList.pm
%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist

%clean
%abstract_clean_script
