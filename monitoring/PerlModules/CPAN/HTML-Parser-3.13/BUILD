# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/HTML-Parser-3.13
%define name        HTML-Parser

# Package specific stuff
Name:         HTML-Parser
Version:      3.16.0
Release:      1.1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl HTML parsing routines.
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Provides:     HTML::Parser
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prefix:	      %{_our_prefix}

%description

Provides HTML parsing functionality for Perl scripts.


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
