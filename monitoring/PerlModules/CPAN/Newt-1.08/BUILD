# Macros

#control upversion
%define external_package 1

%define cvs_package    PerlModules/CPAN/Newt-1.08

# Package specific stuff
Name:         Newt
Version:      1.11.0
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl interface to the Newt text mode screen library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides interface to the Newt text mode screen library


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
