# Macros
%define cvs_package    SatConfig/general

%define etc            /etc
%define sysv_dir       %etc/rc.d/np.d
%define hb_res_dir     /etc/ha.d/resource.d
%define registry_dir   %sysv_dir/registry
%define apache_registry_dir   %sysv_dir/apachereg
%define installed_dir  %sysv_dir/installed
%define sbin           /sbin

# Package specific stuff
Name:         SatConfig-general
Version:      1.216.0
Release:      1
Packager:     Karen Jacqmin-Adams <kja@redhat.com>
Summary:      Satellite Configuration System - general setup, used by many packages
Source:	      SatConfig-general-%PACKAGE_VERSION.tar.gz
BuildArch:    noarch
Group:        unsorted
Copyright:    Red Hat, Inc. (c) 2000-2003
Vendor:       Red Hat, Inc.
Buildroot:    %{_tmppath}/%name
Prereq:       perl SatConfig-cluster NPusers np-config perl(NOCpulse::CommandLineApplicationComponent) perl(NOCpulse::Gritch)

%description

SatConfig-general sets up directories and other items shared by many packages to make a satellite work.

%prep
%entirely_abstract_build_step


%build
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
cc -O -Wall -c libmii.c
gcc -Wall -Wstrict-prototypes -O mii-diag.c -DLIBMII libmii.c -o mii-diag


%install
cd $RPM_PACKAGE_NAME-$RPM_PACKAGE_VERSION
mkdir -p $RPM_BUILD_ROOT%sysv_dir
mkdir -p $RPM_BUILD_ROOT%hb_res_dir
mkdir -p $RPM_BUILD_ROOT%registry_dir
mkdir -p $RPM_BUILD_ROOT%apache_registry_dir
mkdir -p $RPM_BUILD_ROOT%installed_dir
mkdir -p $RPM_BUILD_ROOT%sbin
install -o root -g root -m 644 *.pm $RPM_BUILD_ROOT%sysv_dir
# Was part of worker-bee,ha etc 
#install -o root -g root -m 755 clustcfgsvcsd $RPM_BUILD_ROOT%sysv_dir
#install -o root -g root -m 755 cluster $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 hbResource $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 installSysVSteps $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 registerStep $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 step $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 sysvStep $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 validateConfiguration $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 755 pip $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 444 SysV.ini $RPM_BUILD_ROOT%sysv_dir
install -o root -g root -m 550 mii-diag $RPM_BUILD_ROOT%sbin
ln -s /etc/rc.d/np.d/hbResource $RPM_BUILD_ROOT%hb_res_dir/ClusterLeader

%point_scripts_to_correct_perl


%files
%attr(755,root,root) %dir %sysv_dir
%attr(755,root,root) %dir %registry_dir
%attr(755,root,root) %dir %apache_registry_dir
%attr(755,root,root) %dir %installed_dir
%attr(644,root,root) %sysv_dir/*.pm
#%attr(755,root,root) %sysv_dir/clustcfgsvcsd
#%attr(755,root,root) %sysv_dir/cluster
%attr(755,root,root) %sysv_dir/hbResource
%attr(755,root,root) %sysv_dir/installSysVSteps
%attr(755,root,root) %sysv_dir/registerStep
%attr(755,root,root) %sysv_dir/step
%attr(755,root,root) %sysv_dir/sysvStep
%attr(755,root,root) %sysv_dir/validateConfiguration
%attr(755,root,root) %sysv_dir/pip
%attr(444,root,root) %sysv_dir/SysV.ini
%hb_res_dir/*
%sbin/*


%clean
%abstract_clean_script
