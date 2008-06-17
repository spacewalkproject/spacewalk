# Macros

%define cvs_package PerlModules/CPAN/DateManip-5.35

# Package specific stuff
Name:         Date-Manip
Version:      5.37.0
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      Perl date string manipulation library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Group:        Development/Libraries
URL:          http://search.cpan.org/dist/DateManip/
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%name
Prefix:	      %{_our_prefix}

%description

Provides date string parsing for Perl

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

