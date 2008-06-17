# Macros
%define cvs_package    PerlModules/NP/Object

# Package specific stuff
Name:         perl-NOCpulse-Object
Version:      1.26.4
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse Object abstraction for Perl
Source:       %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl(Config::IniFiles) perl(FreezeThaw) perl(NOCpulse::Debug)
Provides:     perl(NOCpulse::AbstractObjectRepository) perl(NOCpulse::DBMObjectRepository) perl(NOCpulse::INIObjectRepository) perl(NOCpulse::MultiFileObjectRepository) perl(NOCpulse::Namespace) perl(NOCpulse::Object) perl(NOCpulse::SharedBlockingNamespace)
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

Provides an API for generating varying levels of debugging output
on various output streams.


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
