# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/Device-SerialPort-0.10


# Package specific stuff
Name:         Device-SerialPort
Version:      1.1.0
Release:      1
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl serial port interface
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        unsorted
URL:          http://sendpage.cpoint.net/device-serialport/
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prefix:	      %{_our_prefix}


%description

Provides access to serial devices in perl


%prep
%entirely_abstract_build_step
 
%build
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
CFLAGS="$RPM_OPT_FLAGS" %perl Makefile.PL /dev/ttyS0 verbose PREFIX=$RPM_BUILD_ROOT%{prefix}
make OPTIMIZE="$RPM_OPT_FLAGS" 

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
