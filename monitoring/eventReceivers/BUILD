# Macros

%define cvs_package eventReceivers
%define cgi_bin     /opt/apache/cgi-bin
%define registry    /etc/rc.d/np.d/apachereg

# Package specific stuff
Name:         %cvs_package
Version:      2.20.5
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Command Center Event Receivers
Source:	      %{name}-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    (c) 2001-2003 Red Hat, Inc. All rights reserved.
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%cvs_package


%description

Event Receivers

%prep
%entirely_abstract_build_step


%build
echo "Nothing to build"


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION

%find_perl_installsitelib
np_lib=$installsitelib/NOCpulse

mkdir -p $RPM_BUILD_ROOT$np_lib
mkdir -p $RPM_BUILD_ROOT%registry
cp -f EventHandler.pm $RPM_BUILD_ROOT$np_lib
cp -f HttpsMX.pm $RPM_BUILD_ROOT$np_lib
cp -f ApacheSSL.eventReceivers $RPM_BUILD_ROOT%registry
cp -f ApacheSSL.eventReceivers-proxies $RPM_BUILD_ROOT%registry


%point_scripts_to_correct_perl
%make_file_list


%files -f %{name}-%{version}-%{release}-filelist
%defattr(644,root,root)

%clean
%abstract_clean_script

