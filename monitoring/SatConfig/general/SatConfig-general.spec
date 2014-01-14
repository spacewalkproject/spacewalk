%define sysv_dir       %{_sysconfdir}/rc.d/np.d
%define hb_res_dir     %{_sysconfdir}/ha.d/resource.d
%define installed_dir  %sysv_dir/installed
Name:         SatConfig-general
Version:      1.216.31
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
BuildRequires: /usr/bin/pod2man

%description
SatConfig-general sets up directories and other items shared by many packages 
to make a monitoring work.

%prep
%setup -q

%build
%if  0%{?rhel} && 0%{?rhel} < 6
%define pod2man pod2man
%else
%define pod2man pod2man --utf8
%endif
%{pod2man} --section=8 NOCpulse-ini NOCpulse-ini.8

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
* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 1.216.31-1
- Updating the copyright years info

* Wed Jan 08 2014 Michael Mraka <michael.mraka@redhat.com> 1.216.30-1
- fixed man page encoding

* Mon Feb 18 2013 Miroslav Suchý <msuchy@redhat.com> 1.216.29-1
- Buildrequire pod2man
- %%defattr is not needed since rpm 4.4

* Fri Mar 02 2012 Jan Pazdziora 1.216.28-1
- Update the copyright year info.

* Tue Feb 07 2012 Miroslav Suchý 1.216.27-1
- do not print warning during exit
- change table alias to real name

* Wed Feb 01 2012 Jan Pazdziora 1.216.26-1
- Now we use RHN::DBI, the database handle is brand new, let's disconnect as
  well.

* Fri Sep 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.216.25-1
- fixed start order of Monitoring services

* Thu Aug 11 2011 Jan Pazdziora 1.216.24-1
- Since autocommit is off in RHN::DB, add explicit commit to ensure our config
  changes are written to the database (david.nutter@bioss.ac.uk)

* Tue Jul 19 2011 Jan Pazdziora 1.216.23-1
- Updating the copyright years.

* Fri Mar 18 2011 Michael Mraka <michael.mraka@redhat.com> 1.216.22-1
- fixed db connection in NOCpulse-ini (PG)
- reuse RHN:DB for db connection in monitoring (PG)

* Tue Feb 22 2011 Jan Pazdziora 1.216.21-1
- Fixing typo (missing single-quote).

* Fri Feb 18 2011 Jan Pazdziora 1.216.20-1
- Localize the filehandle globs; also use three-parameter opens.

* Tue Nov 02 2010 Jan Pazdziora 1.216.19-1
- Update copyright years in the rest of the repo.

