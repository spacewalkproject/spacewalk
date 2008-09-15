# Macros

%define cvs_package PerlModules/CPAN/Crypt-Blowfish-2.09

# Package specific stuff
Name:         Crypt-Blowfish
Version:      2.11.1
Release:      1
Packager:     Nick Hansen <nhansen@redhat.com>
Summary:      Perl Blowfish encryption
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Requires:     perl
Requires: %(perl -MConfig -le 'if (defined $Config{useithreads}) { print "perl(:WITH_ITHREADS)" } else { print "perl(:WITHOUT_ITHREADS)" }')
Requires: %(perl -MConfig -le 'if (defined $Config{usethreads}) { print "perl(:WITH_THREADS)" } else { print "perl(:WITHOUT_THREADS)" }')
Requires: %(perl -MConfig -le 'if (defined $Config{uselargefiles}) { print "perl(:WITH_LARGEFILES)" } else { print "perl(:WITHOUT_LARGEFILES)" }')
Group:        Development/Libraries
Vendor:       Red Hat, Inc.
Copyright:   This perl extension includes software developed by, and copyright of, A.M. Kuchling.  Other parts of the library are covered by the following licence: Copyright (C) 1995, 1996 Systemics Ltd (http://www.systemics.com/) Modifications and Current Implimentation Copyright (C) 2000 W3Works, LLC.  All rights reserved.

BuildRoot:    %{_tmppath}/%name
Prefix:	      %{_our_prefix}


%description

This is Crypt::Blowfish version 2.09, an XS-based implementation of the
Blowfish cryptography algorithm designed by Bruce Schneier.  It's designed
to take full advantage of Crypt::CBC when desired.  Blowfish keys may be
up to 448 bits (56 bytes) long.  This module builds on nearly every platform
that Perl itself does (see Notes for exceptions).


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

