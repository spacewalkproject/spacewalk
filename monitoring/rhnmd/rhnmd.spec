%global np_name nocpulse
%global identity %{_var}/lib/%{np_name}/.ssh/nocpulse-identity
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}
%if 0%{!?_initddir:1}
%global _initddir %{_sysconfdir}/rc.d/init.d
%endif

Summary:        Spacewalk Monitoring Daemon
Name:           rhnmd
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version:        5.3.18
Release:        1%{?dist}
License:        GPLv2
BuildArch:      noarch
Group:          System Environment/Daemons
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       openssh
%if 0%{?suse_version}
# make chkconfig work during build
BuildRequires:  sysconfig
%else
Requires:       openssh-server
%if 0%{?fedora}
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(post): systemd-sysv
Requires(preun): systemd-sysv
Requires(post): systemd-units
Requires(preun): systemd-units
BuildRequires: systemd-units
%else
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
Requires(postun): initscripts
%endif
%endif
%if 0%{?suse_version} >= 1210
BuildRequires: systemd
%{?systemd_requires}
%endif
BuildRequires:  pam-devel
Obsoletes:      rhnmd.i386 < 5.3.0-5
Obsoletes:      rhnmd.x86_64 < 5.3.0-5
Provides:       rhnmd.i386 = %{version}
Provides:       rhnmd.x86_64 = %{version}

Requires(post): /usr/sbin/semanage, %{sbinpath}/restorecon
Requires(preun): /usr/sbin/semanage

%description
rhnmd enables secure ssh-based communication between the monitoring
scout and the monitored host. 

%prep
%setup -q

%build
#nothing to do

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_usr}/sbin
mkdir -p $RPM_BUILD_ROOT%{_usr}/lib
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/%{np_name}
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/.ssh
mkdir -p $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/sbin
mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/pam.d
mkdir -p $RPM_BUILD_ROOT%{_libdir}
ln -sf sshd $RPM_BUILD_ROOT%{_usr}/sbin/rhnmd

%if 0%{?suse_version}
%if 0%{?suse_version} >= 1210
mkdir -p $RPM_BUILD_ROOT/%{_unitdir}
install -m 0644 rhnmd.service $RPM_BUILD_ROOT/%{_unitdir}/
%else
mkdir -p $RPM_BUILD_ROOT%{_initddir}
install -pm 0755 rhnmd.init.SUSE $RPM_BUILD_ROOT%{_initddir}/rhnmd
%endif
%else
%if 0%{?fedora}
mkdir -p $RPM_BUILD_ROOT/%{_unitdir}
install -m 0644 rhnmd.service $RPM_BUILD_ROOT/%{_unitdir}/
%else
mkdir -p $RPM_BUILD_ROOT%{_initddir}
install -pm 0755 rhnmd-init $RPM_BUILD_ROOT%{_initddir}/rhnmd
%endif
%endif
install -pm 0755 rhnmd_create_key.sh $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/sbin/
install -pm 0644 rhnmd_config $RPM_BUILD_ROOT%{_sysconfdir}/%{np_name}/rhnmd_config
install -pm 0600 authorized_keys $RPM_BUILD_ROOT%{_var}/lib/%{np_name}/.ssh/authorized_keys
install -pm 0644 rhnmd-pam_config $RPM_BUILD_ROOT%{_sysconfdir}/pam.d/rhnmd

%pre
if [ $1 -eq 1 ] ; then
  getent group %{np_name} >/dev/null || groupadd -r %{np_name}
%if !0%{?suse_version}
  getent passwd %{np_name} >/dev/null || \
  useradd -r -g %{np_name} -d %{_var}/lib/%{np_name} -c "NOCpulse user" %{np_name}
  /usr/bin/passwd -l %{np_name} >/dev/null
%else
  # SUSE sshd do not allow to login into locked accounts
  getent passwd %{np_name} >/dev/null || \
  useradd -r -g %{np_name} -d %{_var}/lib/%{np_name} -c "NOCpulse user" %{np_name} -s /bin/bash
%endif
  exit 0
fi
# Old NOCpulse packages has home in /home/nocpulse.
# We need to migrate them to new place.
if getent passwd %{np_name} >/dev/null && [ -d /home/nocpulse ]; then
  /usr/sbin/usermod -d %{_var}/lib/%{np_name} -m nocpulse
  rm -rf %{_var}/lib/nocpulse/bin
  rm -rf %{_var}/lib/nocpulse/var
fi
%if 0%{?suse_version} >= 1210
%service_add_pre rhnmd.service
%endif

%post
# keygen is done in init script. Doing this in %post is bad for using this rpm in appliances.
%if !0%{?suse_version}
if [ ! -f %{identity} ]
then
    %{sbinpath}/runuser -s /bin/bash -c "/usr/bin/ssh-keygen -q -t dsa -N '' -f %{identity}" - %{np_name}
fi
%endif
%if 0%{?suse_version} >= 1210
%service_add_post rhnmd.service
%else
if [ -f /etc/init.d/rhnmd ]; then
    /sbin/chkconfig --add rhnmd
fi
/usr/sbin/semanage fcontext -a -t sshd_key_t '/var/lib/nocpulse/\.ssh/nocpulse-identity' || :
%if 0%{?rhel} && "%rhel" < "6"
/usr/sbin/semanage fcontext -a -t sshd_key_t '/var/lib/nocpulse/\.ssh/authorized_keys' || :
%else
/usr/sbin/semanage fcontext -a -t ssh_home_t '/var/lib/nocpulse/\.ssh/authorized_keys' || :
%endif
/sbin/restorecon -rvv /var/lib/nocpulse || :
%if 0%{?fedora} || 0%{?rhel} > 6
/usr/sbin/semanage port -l | grep -q '^ssh_port_t\b.*\btcp\b.*\b4545\b' || /usr/sbin/semanage port -a -t ssh_port_t -p tcp 4545 || :
%endif
%endif

%preun
%if 0%{?suse_version} >= 1210
%service_del_preun rhnmd.service
%else
if [ $1 = 0 ]; then
    %if 0%{?fedora}
    /bin/systemctl stop rhnmd.service >/dev/null 2>&1
    /usr/sbin/semanage port -d -t ssh_port_t -p tcp 4545 || :
    %else
    /sbin/service rhnmd stop > /dev/null 2>&1
    %endif
    if [ -f /etc/init.d/rhnmd ]; then
        /sbin/chkconfig --del rhnmd
    fi
fi
%endif

%if 0%{?suse_version} >= 1210
%postun
%service_del_preun rhnmd.service
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files
%dir %{_sysconfdir}/%{np_name}
%config(noreplace) %{_sysconfdir}/pam.d/rhnmd
%dir %attr(-, %{np_name},%{np_name}) %{_var}/lib/%{np_name}
%dir %attr(700, %{np_name},%{np_name}) %{_var}/lib/%{np_name}/.ssh
%dir %attr(-, %{np_name},%{np_name}) %{_var}/lib/%{np_name}/sbin
%config(noreplace) %attr(-, %{np_name},%{np_name}) %{_var}/lib/%{np_name}/.ssh/authorized_keys
%{_var}/lib/%{np_name}/sbin/*
%{_usr}/sbin/rhnmd
%config(noreplace) %{_sysconfdir}/%{np_name}/rhnmd_config
%if 0%{?fedora} || 0%{?suse_version} >= 1210
%{_unitdir}/rhnmd.service
%else
%{_initddir}/rhnmd
%endif
%doc LICENSE

%changelog
* Mon Jul 29 2013 Michael Mraka <michael.mraka@redhat.com> 5.3.18-1
- 893096 - bind rhnmd to port on new RHEL

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.3.17-1
- misc branding clean up

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 5.3.16-1
- 919468 - fixed path in file based Requires
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Fri Jan 04 2013 Jan Pazdziora 5.3.15-1
- We may need to define the port 4545 as ours to use.
- The daemon does success for us.

* Mon Dec 10 2012 Michael Mraka <michael.mraka@redhat.com> 5.3.14-1
- added missing pid file
- fixed service description

* Mon Dec 10 2012 Michael Mraka <michael.mraka@redhat.com> 5.3.13-1
- use rhnmd.service on Fedora

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 5.3.12-1
- create rhnmd.service for systemd
- no use of /var/lock/subsys/ anymore

* Tue Aug 28 2012 Tomas Kasparek <tkasparek@redhat.com> 5.3.11-1
- 852386 - Independent SElinux policy for rhel5
- %%defattr is not needed since rpm 4.4

* Fri Oct 07 2011 Jan Pazdziora 5.3.10-1
- 594647 - label rhnmd's files upon installation.

* Fri Apr 15 2011 Jan Pazdziora 5.3.9-1
- add nocpulse config dir to filelist (mc@suse.de)
- build rhnmd on SUSE (mc@suse.de)

* Thu Mar 10 2011 Miroslav Suchý <msuchy@redhat.com> 5.3.8-1
- 538057 - add corresponding "Provides:" for the arch-specific packages
- 538057 - versioned provides, substitute tabs with spaces

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 5.3.7-1
- 578738 - obsolete archs - we are noarch now

