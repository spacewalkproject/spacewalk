# Macros

%define cvs_package PerlModules/CPAN/URI-1.09


# Package specific stuff
Name:         URI
Version:	1.13.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl URI-handling library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     URI
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides URI-handling capabilities for Perl scripts.


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
