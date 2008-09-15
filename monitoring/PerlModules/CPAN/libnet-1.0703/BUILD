# Macros

%define cvs_package PerlModules/CPAN/libnet-1.0703


# Package specific stuff
Name:         libnet
Version:	1.2.0
Release:      1
Packager:     Ramesh Sen <rsen@nocpulse.com>
Summary:      Perl network tools
Source:	      %name-%PACKAGE_VERSION.tar.gz
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides various network functionality (e.g., FTP)

%prep
%entirely_abstract_build_step
 
%build
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
CFLAGS="$RPM_OPT_FLAGS" %perl Makefile.PL verbose PREFIX=$RPM_BUILD_ROOT%{prefix} < /dev/null
make OPTIMIZE="$RPM_OPT_FLAGS"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
