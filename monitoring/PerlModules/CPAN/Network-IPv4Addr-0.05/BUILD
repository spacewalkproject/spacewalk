# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/Network-IPv4Addr-0.05

# Package specific stuff
Name:         perl-Network-IPv4Addr
Version:      0.6.0
Release:      1.3
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl IPV4 addr calculations
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Network::IPv4Addr provides functions for parsing IPv4
addresses both in traditional address/netmask format and
in the new CIDR format.  There are also methods for
calculating the network and broadcast address and also to
see check if a given address is in a specific network.

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
