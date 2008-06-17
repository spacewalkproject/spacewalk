# Macros

%define cvs_package SatConfig/spread
%define bin_dir /usr/local/bin

# Package specific stuff
Name:         SatConfig-spread
Version:	1.1.0
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Spread configuration for satellites
Source:	      SatConfig-spread-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package

%description

Defines how satellite spread configurations should look


%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

mkdir -p $RPM_BUILD_ROOT%bin_dir
install -o root -g root -m 750 getSpreadConfig $RPM_BUILD_ROOT%bin_dir

%point_scripts_to_correct_perl
%make_file_list 


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
