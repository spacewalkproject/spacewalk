# Macros
%define cvs_package    PerlModules/NP/SetID
 
# Package specific stuff
Name:         perl-NOCpulse-SetID
Version:      1.5.2
Release:      1
Packager:     Dave Parker <dparker@redhat.com>
Summary:      Provides api for correctly changing user identity
Source:       %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl(Class::MethodMaker)
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package
 
 
%description

Provides api for correctly changing user identity

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
