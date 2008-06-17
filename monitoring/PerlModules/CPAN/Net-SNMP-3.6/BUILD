# Macros

%define cvs_package PerlModules/CPAN/Net-SNMP-3.6


# Package specific stuff
Name:         perl-Net-SNMP
Version:      5.0.1
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl SNMP version 3.6
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides primitives for perl SNMP version 3.6

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
