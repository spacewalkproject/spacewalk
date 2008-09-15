# Macros

%define cvs_package PerlModules/CPAN/Mail-Alias-1.12

#control upversion
%define external_package 1


# Package specific stuff
Name:         perl-Mail-Alias
Version:      1.14.0
Release:      1.1
Packager:     Kerry P. Boomsliter <kerry@nocpulse.com>
Summary:      Perl module to manipulate mail alias files of various formats
Source:	      %name-%version.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     Mail-Alias
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_temppath}/%cvs_package

%description

Perl module to manipulate mail alias files of various formats

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
