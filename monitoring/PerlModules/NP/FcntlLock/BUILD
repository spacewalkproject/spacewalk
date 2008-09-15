# Macros
%define cvs_package    PerlModules/NP/FcntlLock

# Package specific stuff
Name:         FcntlLock
Version:      1.0.1
Release:      1
Packager:     Dave Faraldo <dfaraldo@redhat.com>
Summary:      Simple interface to fcntl(2) file locking
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
Group:        unsorted
Copyright:    (c) 2004 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

%{name} is a Perl extension module to provide a simple interface
to fcntl(2) file locking for entire files.

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

