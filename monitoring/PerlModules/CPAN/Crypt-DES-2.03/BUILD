# Macros

%define cvs_package PerlModules/CPAN/Crypt-DES-2.03

# Package specific stuff
Name:         perl-Crypt-DES
Version:      2.5.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      an XS-based DES implimentation for Perl.
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Requires: %(perl -MConfig -le 'if (defined $Config{useithreads}) { print "perl(:WITH_ITHREADS)" } else { print "perl(:WITHOUT_ITHREADS)" }')
Requires: %(perl -MConfig -le 'if (defined $Config{usethreads}) { print "perl(:WITH_THREADS)" } else { print "perl(:WITHOUT_THREADS)" }')
Requires: %(perl -MConfig -le 'if (defined $Config{uselargefiles}) { print "perl(:WITH_LARGEFILES)" } else { print "perl(:WITHOUT_LARGEFILES)" }')
Group:        Development/Libraries
URL:          http://search.cpan.org/dist/Crypt-DES/
Copyright:    Modifications, including cross-platform fixups, and single-algorithm distribution packaging are Copyright (C) 2000 W3Works, LLC.  All Rights Reserved.  Mail questions and comments to Dave Paris <amused@pobox.com>. Original distribution license (below) applies.  Other parts of the library are covered by the following licence: Copyright (C) 1995, 1996 Systemics Ltd (http://www.systemics.com/) All rights reserved.
Vendor:       Red Hat, Inc.
BuildRoot:    %{_tmppath}/%name
Prefix:	      /usr

%description

The module implements the Crypt::CBC interface, which has the following methods
blocksize =item keysize =item encrypt =item decrypt


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
