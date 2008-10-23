%define sysv_dir       %{_sysconfdir}/rc.d/np.d
%define hb_res_dir     %{_sysconfdir}/ha.d/resource.d
%define registry_dir   %sysv_dir/registry
%define apache_registry_dir   %sysv_dir/apachereg
%define installed_dir  %sysv_dir/installed
Name:         SatConfig-general
Version:      1.215.42
Release:      1%{?dist}
Summary:      Satellite Configuration System - general setup, used by many packages
# This src.rpm is cannonical upstream
# You can obtain it using this set of commands
# git clone git://git.fedorahosted.org/git/spacewalk.git/
# cd monitoring/SatConfig/general
# make srpm
URL:          https://fedorahosted.org/spacewalk
Source:	      %{name}-%{version}.tar.gz
Group:        Development/Libraries
License:      GPLv2
BuildArch:    noarch
Buildroot:    %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:     perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       nocpulse-common

%description
SatConfig-general sets up directories and other items shared by many packages 
to make a monitoring work.

%prep
%setup -q

%build
#nothing to do here

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%sysv_dir
mkdir -p $RPM_BUILD_ROOT%hb_res_dir
mkdir -p $RPM_BUILD_ROOT%registry_dir
mkdir -p $RPM_BUILD_ROOT%apache_registry_dir
mkdir -p $RPM_BUILD_ROOT%installed_dir
install -m 644 *.pm $RPM_BUILD_ROOT%sysv_dir
install -m 755 hbResource $RPM_BUILD_ROOT%sysv_dir
install -m 755 installSysVSteps $RPM_BUILD_ROOT%sysv_dir
install -m 755 registerStep $RPM_BUILD_ROOT%sysv_dir
install -m 755 step $RPM_BUILD_ROOT%sysv_dir
install -m 755 sysvStep $RPM_BUILD_ROOT%sysv_dir
install -m 755 validateConfiguration $RPM_BUILD_ROOT%sysv_dir
install -m 755 pip $RPM_BUILD_ROOT%sysv_dir
install -m 444 SysV.ini $RPM_BUILD_ROOT%sysv_dir
ln -s ../../rc.d/np.d/hbResource $RPM_BUILD_ROOT%hb_res_dir/ClusterLeader

%files
%defattr(-,root,root,-)
%dir %sysv_dir
%dir %registry_dir
%dir %apache_registry_dir
%dir %installed_dir
%sysv_dir/*.pm
%sysv_dir/hbResource
%sysv_dir/installSysVSteps
%sysv_dir/registerStep
%sysv_dir/step
%sysv_dir/sysvStep
%sysv_dir/validateConfiguration
%sysv_dir/pip
%sysv_dir/SysV.ini
%hb_res_dir/*
%doc 1-STARTUP_SEQUENCE 2-COMMANDS_OVERVIEW 3-CONFIGURATION 4-DEVELOPMENT 5-STEPS_LEGEND

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Tue Oct 21 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.42-1
- 467868 - load propper module during install

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.41-1
- 467441 - fix namespace

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.40-1
- spec cleanup for Fedora

