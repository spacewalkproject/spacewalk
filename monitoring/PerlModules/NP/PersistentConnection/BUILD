# Macros
%define cvs_package PerlModules/NP/PersistentConnection

# Package specific stuff
Name:         perl-NOCpulse-PersistentConnection
Version:      1.5.1
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Persistent HTTP connection over SSL
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl NOCpulse::Debug
Group:        unsorted
Copyright:    (c) 2001-2003 Red Hat, Inc.  All rights reserved.
Vendor:       Red Hat, Inc.
Prefix:       %{_our_prefix}
Buildroot:    %{_tmppath}/%cvs_package

%description

Persistent HTTP connection over SSL


%prep
%entirely_abstract_build_step

%build
%makefile_build


%install
rm -rf $RPM_BUILD_ROOT
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
%makefile_install
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist
%defattr(-,root,root,-)


%clean
%abstract_clean_script
