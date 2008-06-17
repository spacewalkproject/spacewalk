# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/MIME-tools-5.410

# Package specific stuff
Name:         perl-MIME-tools
Version:	5.413.0
Release:      1.1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl Multipurpose Internet Mail Extension (MIME) library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     MIME-tools
Group:        unsorted
URL:          http://www.zeegee.com
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides Multipurpose Internet Mail Extension (MIME) capabilities to Perl
scripts.


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
