# Macros

%define cvs_package PerlModules/CPAN/Crypt-SSLeay-0.51

# Package specific stuff
Name:         perl-Crypt-SSLeay
Version:      0.51.0
Release:      1
Packager:     Dave Parker <dparker@redhat.com>
Summary:      Perl interface to the Secure Socket Layer (SSL) library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl, openssl
Provides:     Crypt::SSLeay
Group:        Development/Libraries
URL:          http://search.cpan.org/dist/Crypt-SSLeay/
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%name
Prefix:	      %{_our_prefix}

%description

Provides a Perl interface to the Secure Socket Layer (SSL) library.

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

