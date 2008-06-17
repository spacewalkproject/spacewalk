# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/HTML-Tagset-3.03

# Package specific stuff
Name:         HTML-Tagset
Version:      3.3.0
Release:      3
Packager:     Heather Adkins <hadkins@nocpulse.com>
Summary:      Data tables useful in dealing with HTML.
Source:	      HTML-Tagset-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     HTML::Tagset
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

Data tables useful in dealing with HTML


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
