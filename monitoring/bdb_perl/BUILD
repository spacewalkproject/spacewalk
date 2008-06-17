# Macros

%define cvs_package bdb_perl
%define apache_home /opt/apache


# Package specific stuff
Name:         bdb_perl
Version:      2.9.3
Release:      1
Packager:     Dave Faraldo <dfaraldo@redhat.com>
Summary:      NOCpulse Perl BDB Module
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     %{name}
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package



%description

BDB Stuff


%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"


%install

rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION


%find_perl_installsitelib
perl_lib=$installsitelib/NOCpulse

mkdir -p $RPM_BUILD_ROOT$perl_lib

install -o root -g root -m 444 BDB.pm         $RPM_BUILD_ROOT$perl_lib
install -o root -g root -m 444 BDB2.pm        $RPM_BUILD_ROOT$perl_lib

mkdir -p $RPM_BUILD_ROOT%apache_home
install -o root -g root -m 544 test_bdb.pl    $RPM_BUILD_ROOT%apache_home

%make_file_list


%files -f %{name}-%{version}-%{release}-filelist


%abstract_clean_script
