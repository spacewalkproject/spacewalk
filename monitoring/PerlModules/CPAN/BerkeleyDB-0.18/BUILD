# Macros

%define cvs_package PerlModules/CPAN/BerkeleyDB-0.18

# Package specific stuff
Name:         BerkeleyDB
Version:      0.21.0
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      Data tables useful in dealing with HTML.
Source:	      BerkeleyDB-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Provides:     BerkeleyDB.pm
Group:        Development/Tools
URL:          http://search.cpan.org/dist/BerkeleyDB/
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%name

%description

Provides a Perl interface to BerkeleyDB

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
