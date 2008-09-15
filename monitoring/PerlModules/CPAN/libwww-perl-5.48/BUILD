# Macros

%define cvs_package PerlModules/CPAN/libwww-perl-5.48


# Package specific stuff
Name:         libwww-perl
Version:	5.55.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Perl WWW client library
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl perl(URI) perl(HTML::Parser) perl(MIME::Base64) perl(Net::FTP)
Provides:     libwww-perl
Group:        unsorted
License:      GPL or Artistic
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
BuildRoot:    %{_tmppath}/%cvs_package

%description

Provides WWW client functionality for Perl scripts.

%prep
%entirely_abstract_build_step
 
%build
%makefile_build 
 
%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%alt_makefile_install
%point_scripts_to_correct_perl
%make_file_list
 
%files -f %{name}-%{version}-%{release}-filelist
 
%clean
%abstract_clean_script
