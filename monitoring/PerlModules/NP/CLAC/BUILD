# Macros
%define cvs_package    PerlModules/NP/CLAC

# Package specific stuff
Name:         perl-NOCpulse-CLAC
Version:      1.9.4
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse Command Line Application framework for Perl
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
Requires:     perl(NOCpulse::Object)
Provides:     perl(NOCpulse::CommandLineApplicationComponent) perl(NOCpulse::CommandLineSwitch) perl(NOCpulse::CommandShell) perl(NOCpulse::PersistentObject) perl(NOCpulse::LocalCommandShell)
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

%{name} provides a framework for writing command line oriented 
applications

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

