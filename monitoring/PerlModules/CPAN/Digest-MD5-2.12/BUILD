# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/Digest-MD5-2.12


# Package specific stuff
Name:         Digest-MD5
Version:      2.15.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl interface to the MD5 Algorithm
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Provides:     Digest::MD5
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prefix:	      %{_our_prefix}

%description

Provides a Perl interface to the MD5 Algorithm.




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
