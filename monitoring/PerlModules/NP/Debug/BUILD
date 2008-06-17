# Macros
%define cvs_package PerlModules/NP/Debug

# Package specific stuff
Name:         perl-NOCpulse-Debug
Version:      1.23.4
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Perl debug output package
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl, np-config, perl(Class::MethodMaker)
Provides:     NOCpulse::Debug NOCpulse::Debuggable
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

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


%clean
%abstract_clean_script
