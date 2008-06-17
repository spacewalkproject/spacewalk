# Macros

#control upversion
%define external_package 1

%define cvs_package    PerlModules/CPAN/Storable-1.0.14


# Package specific stuff
Name:         Storable
Version:      1.1.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl data serialization library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides data serialization capabilities for Perl scripts.


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
