# Macros
%define cvs_package PerlModules/NP/NP_RPM

# Package specific stuff
Name:         NOCpulse-RPM
Version:      1.1.0
Release:      1
Packager:     Karen Jacqmin-Adams <karen@nocpulse.com>
Summary:      Perl wrapper for RPM
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl
Provides:     NOCpulse::RPM 
Group:        unsorted
Copyright:    (c) 2001-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      /usr
Buildroot:    /tmp/%cvs_package

%description

Provides an API to the RPM command.


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

