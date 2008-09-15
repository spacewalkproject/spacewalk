# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/IPC-ShareLite-0.08

# Package specific stuff
Name:         IPC-ShareLite
Version:      0.8.0
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl IPC wrapper
Source:	      IPC-ShareLite-%PACKAGE_VERSION.tar.gz
Requires:     perl 
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

Provides simple atomic access to SYSV IPC memory

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
