# Macros
%define cvs_package    PerlModules/NP/Time-System

# Package specific stuff
Name:         Time-System
Version:      1.6.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@redhat.com>
Summary:      gettimeofday() and settimeofday() system calls
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl np-config
Provides:     Time::System
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Time::System provides access to the gettimeofday() and settimeofday()
system calls.  In scalar context, B<gettimeofday()> returns seconds
and microseconds as a single floating-point number; in array context,
it returns them separately.  Similarly, B<settimeofday()> may be
called with a single floating-point number, or with seconds and
microseconds passed as separate arguments.


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

