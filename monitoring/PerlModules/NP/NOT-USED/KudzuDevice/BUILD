# Macros
%define cvs_package    PerlModules/NP/KudzuDevice
 
# Package specific stuff
Name:         KudzuDevice
Version:      1.4.0
Release:      1
Packager:     Dave Parker <dparker@redhat.com>
Summary:      Provides read-only interface to Kudzu's hwconf file
Source:       %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Prereq:       perl-rhnmon
Buildroot:    %{_tmppath}/%cvs_package
 
 
%description

Provides read-only interface to Kudzu's hwconf file

%prep
%entirely_abstract_build_step
 
%build
%makefile_build 
 
%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
