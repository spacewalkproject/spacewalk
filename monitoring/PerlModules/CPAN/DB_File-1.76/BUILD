# Macros

%define cvs_package    PerlModules/CPAN/DB_File-1.76

# Package specific stuff
Name:         DB_File
Version:      1.77.0
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      DB File
Source:	      DB_File-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        Development/Libraries
URL:          http://search.cpan.org/dist/DB_File/
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%name

%description

DB File

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

