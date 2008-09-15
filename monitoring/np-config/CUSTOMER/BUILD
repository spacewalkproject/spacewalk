# Macros

%define cvs_package np-config

%define np_bin       /opt/home/nocpulse/bin
%define env_specific env-specific
%define security_level    CUSTOMER


# Package specific stuff
Name:         np-config
Version:      2.110.3
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      NOCpulse global configuration file
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Provides:     np-config
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package
Prereq:       NPusers


%description

np-config contains the nocpulse configuration file and access libraries 
for it in perl and python


%prep
%entirely_abstract_build_step

%build
echo "Nothing to build"

%install

%find_perl_installsitelib
perl_lib=$installsitelib/NOCpulse

mkdir -p $RPM_BUILD_ROOT$perl_lib
mkdir -p $RPM_BUILD_ROOT$perl_lib/Config/test
mkdir -p $RPM_BUILD_ROOT%np_bin
mkdir -p $RPM_BUILD_ROOT%np_bin

cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

cp perl-API/NOCpulse/Config.pm          $RPM_BUILD_ROOT$perl_lib
cp perl-API/NOCpulse/NOCpulseini.pm     $RPM_BUILD_ROOT$perl_lib
cp perl-API/NOCpulse/test/TestConfig.pm $RPM_BUILD_ROOT$perl_lib/Config/test
cp npConfigValue $RPM_BUILD_ROOT%np_bin
chmod 755 $RPM_BUILD_ROOT%np_bin/npConfigValue

%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist



%post
/bin/touch /etc/NOCpulse.ini

%clean
%abstract_clean_script 
