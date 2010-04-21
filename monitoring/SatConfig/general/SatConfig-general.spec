%define sysv_dir       %{_sysconfdir}/rc.d/np.d
%define hb_res_dir     %{_sysconfdir}/ha.d/resource.d
%define installed_dir  %sysv_dir/installed
Name:         SatConfig-general
Version:      1.216.17
Release:      1%{?dist}
Summary:      Satellite Configuration System - general setup, used by many packages
URL:          https://fedorahosted.org/spacewalk
Source0:      https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
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
pod2man --section=8 NOCpulse-ini NOCpulse-ini.8

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%sysv_dir
mkdir -p $RPM_BUILD_ROOT%hb_res_dir
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
install -D -m 644 NOCpulse-ini.8 $RPM_BUILD_ROOT%{_mandir}/man8/NOCpulse-ini.8
install -D -p -m 755 NOCpulse-ini $RPM_BUILD_ROOT%{_sbindir}/NOCpulse-ini

%files
%defattr(-,root,root,-)
%dir %sysv_dir
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
%{_sbindir}/NOCpulse-ini
%doc 1-STARTUP_SEQUENCE 2-COMMANDS_OVERVIEW 3-CONFIGURATION 4-DEVELOPMENT 5-STEPS_LEGEND
%{_mandir}/man8/NOCpulse-ini.8.*

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
* Wed Apr 14 2010 Miroslav Suchý <msuchy@redhat.com> 1.216.17-1
- add NOCpulse-ini to %%files

* Thu Sep 17 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.16-1
- 476851 - removal of tables: rhn_db_environment, rhn_environment

* Tue Aug 25 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.15-1
- Network::IPv4Addr has been renamed to Net::IPv4Addr 

* Mon Aug 24 2009 Dennis Gilmore <dennis@ausil.us> 1.216.14-1
- use Net::IPv4Addr module

* Thu Jul 23 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.12-1
- 457011 - create NOCpulse-ini - tool to handle NOCpulse.ini

* Thu Jun 18 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.11-1
- 499564 - ignore already started/stopped service for InstallSoftwareConfig

* Fri Jun 05 2009 jesus m. rodriguez <jesusr@redhat.com> 1.216.10-1
- remove unused code (msuchy@redhat.com)
- fix formating (msuchy@redhat.com)

* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 1.216.9-1
- 499564 - start InstallSoftwareConfig only when it's due (mzazrivec@redhat.com)

* Tue Mar  3 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.8-1
- 487280 - start/stop Monitoring without the spam on console

* Thu Feb 12 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.7-1
- move logs from /var/tmp to /var/log/nocpulse

* Wed Feb 11 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.6-1
- remove dependency on perl-Apache-Admin-Config
- remove dead code (apachereg)

* Mon Feb  9 2009 Jan Pazdziora 1.216.4-1
- use Sys::Hostname::hostname instead of /bin/hostname

* Fri Jan 16 2009 Miroslav Suchý <msuchy@redhat.com> 1.216.3-1
- fix path to generate_config.log, notif-launcher.log,
  notif-escalator.log and notifier.log

* Sat Jan 10 2009 Milan Zazrivec 1.215.47-1
- move content from under /usr/share/nocpulse to /var/www

* Wed Jan  7 2009 Milan Zazrivec 1.215.46-1
- bz #474591 - move web data to /usr/share/nocpulse

* Mon Dec  1 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.44-1
- 472910 - fix paths to nofitication configs

* Wed Oct 29 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.43-1
- 468537 - renaming paths with /opt in SysV.ini 

* Tue Oct 21 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.42-1
- 467868 - load propper module during install

* Mon Oct 20 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.41-1
- 467441 - fix namespace

* Wed Sep 24 2008 Miroslav Suchý <msuchy@redhat.com> 1.215.40-1
- spec cleanup for Fedora

