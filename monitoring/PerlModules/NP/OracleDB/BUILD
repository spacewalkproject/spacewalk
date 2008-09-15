# Macros
%define cvs_package PerlModules/NP/OracleDB

# Package specific stuff
Name:         perl-NOCpulse-OracleDB
Version:      1.28.2
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Perl modules for NOCpulse Oracle database access
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     NOCpulse::CF_DB perl(NOCpulse::DBRecord) perl(NOCpulse::NPRecords)
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an API for accessing NOCpulse Oracle databases.

%prep
%entirely_abstract_build_step

%build
%makefile_build

%install
rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root,-)


%clean
%abstract_clean_script
