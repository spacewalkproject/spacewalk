# Macros

%define cvs_package SatConfig/generator

%define db_dir /home/nocpulse/var
%define registry	/etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         SatConfig-generator
Version:      2.29.5
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Satellite Configuration System - Server
Source:	      %name-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     configgen.cgi,satconfig.cgi
Requires:     perl, np-config, SatConfig-dbsynch  perl(URI) perl(MIME::Base64) NPusers
Group:        unsorted
Copyright:    (c) 2001-2003 Red Hat, Inc.  All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers

%description

SatConfig-generator is the cgi mechanism by which Netsaint configuration files are generated and propagated.

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"

%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib 
install_prefix=$installsitelib/NOCpulse/SatConfig

mkdir -p          $RPM_BUILD_ROOT$install_prefix
mkdir -p          $RPM_BUILD_ROOT$install_prefix/test
mkdir -p          $RPM_BUILD_ROOT%db_dir
mkdir -p          $RPM_BUILD_ROOT%registry

install -o root -g root -m 444 ConfigDocument.pm $RPM_BUILD_ROOT$install_prefix
install -o root -g root -m 444 GenerateConfig.pm $RPM_BUILD_ROOT$install_prefix
install -o root -g root -m 444 TestGenerateConfig.pm $RPM_BUILD_ROOT$install_prefix/test
install -o root -g root -m 644 Apache.SatConfig-generator $RPM_BUILD_ROOT%registry

%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
