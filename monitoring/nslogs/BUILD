# Macros

%define cvs_package SatConfig/nslogs

%define cfg_dir /etc/logrotate.d

# Package specific stuff
Name:         nslogs
Version:      2.2.1
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Rotate satellite logs
Source:	      nslogs-%PACKAGE_VERSION.tar.gz
Requires:     logrotate
BuildArch:    noarch
Group:        unsorted
Copyright:    NOCpulse (c) 2000
Vendor:       NOCpulse
Buildroot:    %{_tmppath}/%name

%description

Adds a file to /etc/logrotate.d that defines logrotate behavior for
all satellite log files


%prep
%entirely_abstract_build_step
%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT/%cfg_dir
cp satellite $RPM_BUILD_ROOT/%cfg_dir

%files
%attr(644,root,root) %cfg_dir/satellite


%clean
%abstract_clean_script
