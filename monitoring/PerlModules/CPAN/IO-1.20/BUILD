# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/IO-1.20

# Package specific stuff
Name:         IO
Version:      1.23.0
Release:      2
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl socket-handling library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Prereq:       perl-rhnmon
Provides:     IO::Dir IO::File IO::Handle IO::Pipe IO::Poll IO::Seekable IO::Select IO::Socket IO::Socket::INET IO::Socket::UNIX
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an Object interface to IO operations.


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
