# Macros

%define cvs_package    SatConfig/bootstrap-server
%define registry       /etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         SatConfig-bootstrap-server
Version:      1.9.1
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Provides scout info for boostrap
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Requires:     perl perl(NOCpulse::OracleDB)
Group:        unsorted
Copyright:    (c) 2000-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package


%description

Dole out ID's and descriptions to bootstrapping scouts.

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib
nplib=$installsitelib/NOCpulse

# CGI bin
mkdir -p $RPM_BUILD_ROOT%registry
mkdir -p $RPM_BUILD_ROOT/$nplib/SatConfig
mkdir -p $RPM_BUILD_ROOT/$nplib/SatConfig/test
install -o root -g root -m 444 Bootstrap.pm $RPM_BUILD_ROOT$nplib/SatConfig
install -o root -g root -m 444 TestBootstrap.pm $RPM_BUILD_ROOT$nplib/SatConfig/test
install -o root -g root -m 644 Apache.SatConfig-bootstrap-server $RPM_BUILD_ROOT%registry

%point_scripts_to_correct_perl
%make_file_list

%files -f %{name}-%{version}-%{release}-filelist


%clean
%abstract_clean_script
