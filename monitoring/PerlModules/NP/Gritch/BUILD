# Macros
%define cvs_package    PerlModules/NP/Gritch

# Package specific stuff
Name:         perl-NOCpulse-Gritch
Version:      1.16.1
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Perl throttled email notification for satellites
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl np-config
Provides:     NOCpulse::Gritch
Group:        unsorted
Copyright:    (c) 2002-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:	      %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Provides throttled email notification for satellites.

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

