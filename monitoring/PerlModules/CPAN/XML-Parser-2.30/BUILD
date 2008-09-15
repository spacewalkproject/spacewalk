# Macros

%define cvs_package    PerlModules/CPAN/XML-Parser-2.30


# Package specific stuff
Name:         XML-Parser
Version:      2.36.0
Release:      1
Packager:     Dave Faraldo <dfaraldo@nocpulse.com>
Summary:      Perl XML parsing library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Provides:     XML-Parser XML::Parser
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides XML parsing capabilities for Perl scripts.


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
