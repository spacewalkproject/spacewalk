# Macros

%define cvs_package PerlModules/NP/TroubleTicket

# Package specific stuff
Name:         NOCpulse-TroubleTicket
Version:      1.18.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Perl debug output package
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl 
Provides:     NOCpulse::TroubleTicket
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package


%description

API for opening a Command Center trouble ticket when a problem is detected.


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
