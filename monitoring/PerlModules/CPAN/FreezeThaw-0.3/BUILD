# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/FreezeThaw-0.3


# Package specific stuff
Name:         perl-FreezeThaw
Version:      1.1.0
Release:      1.1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl persistency primitives
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_temppath}/%cvs_package
Prefix:	      %{_our_prefix}

%description

Provides primitives for perl object persistency


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
