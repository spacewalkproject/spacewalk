# Macros

#control upversion
%define external_package 1

%define cvs_package PerlModules/CPAN/MailTools-1.15

# Package specific stuff
Name:         perl-MailTools
Version:	1.18.0
Release:      1.1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl mail-handling library
Source:	      MailTools-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     MailTools
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides MailTools-handling capabilities for Perl scripts.

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
