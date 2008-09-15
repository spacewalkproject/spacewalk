# Macros
%define cvs_package    PerlModules/NP/Getresuid

# Package specific stuff
Name:         Getresuid
Version:      1.0.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@redhat.com>
Summary:      Get real, effective, and saved UID/GID
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

%{name} is a Perl extension module to provide the getresuid() and
getresgid() system calls.

%prep
%entirely_abstract_build_step


%build
%makefile_build


%install
rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%makefile_install
%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script

