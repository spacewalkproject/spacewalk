# Macros

%define cvs_package PerlModules/CPAN/DB_File-Lock-0.04

# Package specific stuff
Name:         DB_File-Lock
Version:      0.5.0
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      DB File Locking
Source:	      DB_File-Lock-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        Development/Libraries
URL:          http://search.cpan.org/dist/DB_File-Lock
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%name

%description

This module provides a wrapper for the DB_File module, adding locking.
When you need locking, simply use this module in place of DB_File and
add an extra argument onto the tie command specifying if the file should
be locked for reading or writing.

%prep
%entirely_abstract_build_step

%build
%makefile_build

%install
rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%cpan_doc_install
%makefile_install
%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist

%clean
%abstract_clean_script

