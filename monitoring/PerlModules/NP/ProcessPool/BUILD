# Macros
%define cvs_package PerlModules/NP/ProcessPool

# Package specific stuff
Name:         perl-NOCpulse-ProcessPool
Version:      0.10.1
Release:      1
Summary:      Perl implementation of a process pool
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl 
Provides:     NOCpulse::ProcessPool NOCpulse::Process
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides an API for using a pool of processes to execute jobs.

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
