# Macros
%define cvs_package    PerlModules/NP/PlugFrame

# Package specific stuff
Name:         NOCpulse-PlugFrame
Version:      4.42.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse Plugin framework for Perl
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
Requires:     NOCpulse-Object NOCpulse-CLAC np-config MessageQueue
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

NOCpulse-PlugFrame provides a framework for writing NOCpulse-compliant
satellite probes in Perl

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
