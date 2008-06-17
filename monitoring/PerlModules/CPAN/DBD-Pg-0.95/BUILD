# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/DBD-Pg-0.95


# Package specific stuff
Name:         DBD-Pg
Version:      1.1.0
Release:      2
Packager:     Dave Parker <dparker@nocpulse.com>
Summary:      Perl DBD-Pg library (postgresql)
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%cvs_package
Prefix:	      %{_our_prefix}

%description

Provides DBD-Pg library



%prep
%entirely_abstract_build_step
 
%build
export POSTGRES_INCLUDE="/usr/include/pgsql/"
export POSTGRES_LIB="/usr/lib/pgsql/"
%makefile_build 
 
%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
