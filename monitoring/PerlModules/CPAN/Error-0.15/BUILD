# Macros

#control upversion
%define external_package 1

%define name        Error
%define cvs_package PerlModules/CPAN/Error-0.15


# Package specific stuff
Name:		Error
Version:	1.2.0
Release:	1
Packager:	Rod McChesney <rmcchesney@nocpulse.com>
Summary:	Try/catch/throw for Perl
Source:		%name-%PACKAGE_VERSION.tar.gz
BuildArch:	noarch
Requires:	perl
Group:		unsorted
License:	GPL or Artistic
Vendor:		Red Hat, Inc.
Prefix:		%{_our_prefix}
BuildRoot:	%{_tmppath}/%cvs_package

%description

Provides Perl try/catch/throw semantics by wrapping die.

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
