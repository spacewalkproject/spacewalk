# Macros

%define cvs_package PerlModules/CPAN/db-3.3.11

%define install_prefix /usr/local/BerkeleyDB.3.3
%define buildroot      /usr/src/redhat/BUILD/%cvs_package
%define fileslist      /tmp/files.db


# Package specific stuff
Name:         db
Version:      3.4.0
Release:      0
Packager:     Heather Adkins <hadkins@nocpulse.com>
Summary:      SleepCat DB
Source:	      db-%PACKAGE_VERSION.tar.gz
BuildArch:    i386
Group:        unsorted
Copyright:    Copyright (c) 1990-2001 Sleepycat Software.  All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %install_prefix
BuildRoot:    %buildroot

%description

Provides primitives for BerkeleyDB access.

%prep
%entirely_abstract_build_step
%build
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION/build_unix

../dist/configure --prefix=%buildroot%install_prefix
make clean
make


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION/build_unix
make install
cd %buildroot
find -type f  -printf '/%%P\n' > %fileslist

%files -f %fileslist


%clean
rm -rf $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cd $RPM_BUILD_DIR
rm -rf %cvs_package
rm -rf %buildroot
rm %fileslist


%post

