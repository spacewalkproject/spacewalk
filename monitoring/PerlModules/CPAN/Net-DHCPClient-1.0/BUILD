# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/Net-DHCPClient-1.0


# Package specific stuff
Name:		Net-DHCPClient
Version:	1.0.0
Release:	3
Packager:	Dave Parker <dparker@nocpulse.com>
Summary:	Perl DHCP client lib
Source:		Net-DHCPClient-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Prereq: 	perl Net-RawIP
Group:		unsorted
License:        GPL or Artistic
Vendor:         Red Hat, Inc.
Prefix:       %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides DHCP client functions


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
