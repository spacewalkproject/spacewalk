# Macros

%define cvs_package PerlModules/CPAN/XML-Generator-0.93

# Package specific stuff
Name:         perl-XML-Generator
Version:      1.2.2
Release:      1
Packager:     Dave Parker <dparker@redhat.com>
Summary:      Perl XML generator
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        unsorted
Copyright:    GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Perl extension for generating xml documents

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
