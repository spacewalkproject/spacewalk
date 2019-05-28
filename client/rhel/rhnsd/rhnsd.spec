# Macros that aren't defined in debbuild
%if %{_vendor} == "debbuild"
%global _unitdir /lib/systemd/system
%global _initrddir /etc/init.d
%global is_deb 1
%global _buildshell /bin/bash
%endif

Summary: Spacewalk query daemon
Name: rhnsd
Version: 5.0.44
Release: 1%{?dist}
%if %{_vendor} == "debbuild"
Group:      utils
Packager:   Spacewalk Project <spacewalk-devel@redhat.com>
%endif
License: GPLv2
Source0: %{name}-%{version}.tar.gz
URL:     https://github.com/spacewalkproject/spacewalk

%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?mageia} || 0%{?ubuntu} >= 1504 || 0%{?debian} >= 8 || 0%{?rhel} >= 7
BuildArch: noarch
%endif

%if %{_vendor} != "debbuild"

%if 0%{?suse_version} >= 1210 || 0%{?fedora} || 0%{?mageia} || 0%{?rhel} >= 7
%{?mageia:BuildRequires: systemd-devel}
%{?suse_version:BuildRequires: systemd-rpm-macros}
BuildRequires: systemd
%{?systemd_requires}
%endif
%if 0%{?suse_version}
Requires(post): aaa_base
Requires(preun): aaa_base
BuildRequires: sysconfig
%else
%if 0%{?fedora} || 0%{?rhel} >= 7
Requires(post): chkconfig
Requires(preun): chkconfig
Requires(post): systemd-sysv
Requires(preun): systemd-sysv
%else
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
Requires(postun): initscripts
%endif
%endif
%endif

%if %{_vendor} == "debbuild"
BuildRequires: init-system-helpers
%if 0%{?debian} >= 8 || 0%{?ubuntu} >= 1504
BuildRequires: systemd
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
%endif
%endif

BuildRequires: gettext
Requires: rhn-check >= 0.0.8
BuildRequires: gcc

%description
The Red Hat Update Agent that automatically queries the Red Hat
Network servers and determines which packages need to be updated on
your machine, and runs any actions.

%prep
%setup -q

%build
make -f Makefile.rhnsd %{?_smp_mflags} CFLAGS="-pie -fPIE -Wl,-z,relro,-z,now %{optflags}" %{?is_deb:PLATFORM=deb}

%install
make -f Makefile.rhnsd install VERSION=%{version}-%{release} PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir} INIT_DIR=$RPM_BUILD_ROOT/%{_initrddir} %{?is_deb:PLATFORM=deb} CONFIG_DIR=$RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/rhn

%if %{_vendor} != "debbuild"
%if 0%{?suse_version} && 0%{?suse_version} < 1210
install -m 0755 rhnsd.init.SUSE $RPM_BUILD_ROOT/%{_initrddir}/rhnsd
%endif
%endif
%if %{_vendor} == "debbuild"
install -m 0755 rhnsd.init.Debian $RPM_BUILD_ROOT/%{_initrddir}/rhnsd
%endif
%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?mageia} || 0%{?ubuntu} >= 1504 || 0%{?debian} >= 8 || 0%{?rhel} >= 7
rm $RPM_BUILD_ROOT/%{_initrddir}/rhnsd
mkdir -p $RPM_BUILD_ROOT/%{_unitdir}
install -m 0644 rhnsd.service $RPM_BUILD_ROOT/%{_unitdir}/
install -m 0644 rhnsd.timer $RPM_BUILD_ROOT/%{_unitdir}/
%else
# find_lang not available on debbuild; we'll work around this below
%if %{_vendor} != "debbuild"
%find_lang %{name}
%endif
%endif

# These will not work with debbuild
%if %{_vendor} != "debbuild"
%{!?systemd_post: %global systemd_post() if [ $1 -eq 1 ] ; then /usr/bin/systemctl enable %%{?*} >/dev/null 2>&1 || : ; fi; }
%{!?systemd_preun: %global systemd_preun() if [ $1 -eq 0 ] ; then /usr/bin/systemctl --no-reload disable %%{?*} > /dev/null 2>&1 || : ; /usr/bin/systemctl stop %%{?*} > /dev/null 2>&1 || : ; fi; }
%{!?systemd_postun_with_restart: %global systemd_postun_with_restart() /usr/bin/systemctl daemon-reload >/dev/null 2>&1 || : ; if [ $1 -ge 1 ] ; then /usr/bin/systemctl try-restart %%{?*} >/dev/null 2>&1 || : ; fi; }
%endif

%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?mageia} || 0%{?ubuntu} >= 1504 || 0%{?debian} >= 8 || 0%{?rhel} >= 7
rm -f $RPM_BUILD_ROOT/%{_sysconfdir}/sysconfig/rhn/rhnsd
rm -f $RPM_BUILD_ROOT/%{_sbindir}/rhnsd
rm -rf $RPM_BUILD_ROOT/%{_datadir}/locale
%endif


%if 0%{?suse_version} >= 1210
%pre
%service_add_pre rhnsd.timer
%endif

%post
%if %{_vendor} != "debbuild"
%if 0%{?suse_version} >= 1210
%service_add_post rhnsd.timer
%else
if [ -f /etc/init.d/rhnsd ]; then
    /sbin/chkconfig --add rhnsd
fi
if [ -f %{_unitdir}/rhnsd.service ]; then
    %systemd_post rhnsd.timer
    if [ "$1" = "2" ]; then
        # upgrade from old init.d
        if [ -L /etc/rc2.d/S97rhnsd ]; then
            /usr/bin/systemctl enable rhnsd.timer >/dev/null 2>&1
        fi
        rm -f /etc/rc?.d/[SK]??rhnsd
    fi
fi
%endif
%endif
%if %{_vendor} == "debbuild"
if [ -f %{_initrddir}/rhnsd ] && ( [ "$1" == "configure" ] || [ "$1" == "abort-upgrade" ] ); then
        update-rc.d rhnsd defaults >/dev/null 2>&1 || :
fi
if [ -f %{_unitdir}/rhnsd.service ] && [ "$1" == "configure" ]; then
    systemctl preset rhnsd.timer >/dev/null 2>&1 || :
fi
%endif

%preun
%if %{_vendor} != "debbuild"
%if 0%{?suse_version} >= 1210
%service_del_preun rhnsd.timer
%else
if [ $1 = 0 ] ; then
    %if 0%{?fedora} || 0%{?mageia} || 0%{?rhel} >= 7
        %systemd_preun rhnsd.timer
    %else
    service rhnsd stop >/dev/null 2>&1
    %endif
    if [ -f /etc/init.d/rhnsd ]; then
        /sbin/chkconfig --del rhnsd
    fi
fi
%endif
%endif

%if %{_vendor} == "debbuild"
if [ -f %{_initrddir}/rhnsd ] || [ -e "/etc/init/rhnsd.conf" ]; then
    update-rc.d -f rhnsd remove || exit $?
fi
if [ -f %{_unitdir}/rhnsd.service ] && ( [ "$1" == "remove" ] || [ "$1" == "purge" ] ); then
    systemctl --no-reload disable rhnsd.timer >/dev/null 2>&1 || :
    systemctl stop rhnsd.timer >/dev/null 2>&1 || :
fi
%endif

%postun
%if %{_vendor} != "debbuild"
%if 0%{?suse_version} >= 1210
%service_del_postun rhnsd.timer
%else
if [ "$1" -ge "1" ]; then
    %if 0%{?fedora} || 0%{?mageia} || 0%{?rhel} >= 7
    %systemd_postun_with_restart rhnsd.timer
    %else
    service rhnsd condrestart >/dev/null 2>&1 || :
    %endif
fi
%endif
%endif

%if %{_vendor} == "debbuild"
if [ -f {_initrddir}/rhnsd ] && [ "$1" == "purge" ]; then
    update-rc.d rhnsd remove >/dev/null
fi
if [ -f %{_unitdir}/rhnsd.service ]; then
    systemctl daemon-reload >/dev/null 2>&1 || :
fi
%endif

%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?mageia} || 0%{?ubuntu} >= 1504 || 0%{?debian} >= 8 || 0%{?rhel} >= 7
%files
%{_unitdir}/rhnsd.service
%{_unitdir}/rhnsd.timer
%{_presetdir}/10-rhnsd.preset
%else
%files -f %{name}.lang
%dir %{_sysconfdir}/sysconfig/rhn
%config(noreplace) %{_sysconfdir}/sysconfig/rhn/rhnsd
%{_sbindir}/rhnsd
%{_initrddir}/rhnsd
%endif
%{_mandir}/man8/rhnsd.8*
%doc LICENSE
%if %{_vendor} == "debbuild"
%{_datadir}/locale/
%endif

%changelog
* Fri Nov 23 2018 Michael Mraka <michael.mraka@redhat.com> 5.0.44-1
- Regenerating .po and .pot files for rhnsd
- Updating .po translations from Zanata

* Fri Nov 23 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.43-1
- 1091025 - langauges are not needed on systemd

* Fri Nov 23 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.42-1
- 1091025 - make package noarch on systemd systems
- 1091025 - fix building

* Fri Nov 23 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.41-1
- 1091025 - replace rhnsd with systemd.timer

* Thu Aug 02 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.40-1
- 1610286 - don't start as sysv service on systemd systems

* Tue Jul 31 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.39-1
- client, usix: Rework how client packaging is done for Debian/Ubuntu
- client/rhel/rhnsd: Add Debian init script

* Wed May 30 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.38-1
- client/rhel: Enable DNF plugin for Mageia 6+ and openSUSE Leap 15.0+

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.37-1
- Regenerating .po and .pot files for rhnsd.
- Updating .po translations from Zanata

* Mon Feb 19 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.36-1
- add BuildRequires gcc

* Mon Feb 05 2018 Tomas Kasparek <tkasparek@redhat.com> 5.0.35-1
- remove systemd-units
- remove obsoleted things from spec file

* Thu Nov 16 2017 Tomas Kasparek <tkasparek@redhat.com> 5.0.34-1
- removed settings for old RH build system

* Thu Oct 05 2017 Tomas Kasparek <tkasparek@redhat.com> 5.0.33-1
- fix rhnsd triggered upgrade of rhnsd on systemd systems
- 1494389 - Revert "[1260527] RHEL7 reboot loop"
- 1494389 - Revert "1260527 RHEL7 rhnsd reload doesn't work"

* Tue Sep 19 2017 Tomas Kasparek <tkasparek@redhat.com> 5.0.32-1
- 1489989 - umask(0) does not reset to default umask

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.0.31-1
- purged changelog entries for Spacewalk 2.0 and older

* Tue Aug 15 2017 Gennadii Altukhov <grinrag@gmail.com> 5.0.30-1
- 1480306 - change permissions for rhnsd.pid

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 5.0.29-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 5.0.28-1
- Regenerating .po and .pot files for rhnsd

* Tue Jul 11 2017 Jan Dobes 5.0.27-1
- 1383668 - close and reopen syslog when redirecting child output
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Thu Dec 01 2016 Jiri Dostal <jdostal@redhat.com> 5.0.26-1
- 1260527 RHEL7 rhnsd reload doesn't work

* Fri Nov 11 2016 Jiri Dostal <jdostal@redhat.com> 5.0.25-1
- [1260527] RHEL7 reboot loop

* Wed Nov 09 2016 Gennadii Altukhov <galt@redhat.com> 5.0.24-1
- Revert Project-Id-Version for translations

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 5.0.23-1
- Regenerating .po and .pot files for rhnsd.
- Updating .po translations from Zanata

* Thu Oct 27 2016 Jan Dobes 5.0.22-1
- 1306994 - better check if file is opened

* Tue May 24 2016 Tomas Kasparek <tkasparek@redhat.com> 5.0.21-1
- Regenerating .po and .pot files for rhnsd.
- Updating .po translations from Zanata

* Mon Apr 04 2016 Jan Dobes 5.0.20-1
- 1306994 - use /dev/null as stdin

* Thu Feb 18 2016 Jan Dobes 5.0.19-1
- do not keep this file in git
- delete file with input files after template is created
- pulling *.po translations from Zanata
- fixing current *.po translations

* Wed Sep 23 2015 Jan Dobes 5.0.18-1
- Pulling updated *.po translations from Zanata.

* Tue Jun 23 2015 Jan Dobes 5.0.17-1
- 1138939 - up2date and systemid files are managed by rhnsd itself, no need to
  break init script if they do not exist

* Thu May 21 2015 Matej Kollar <mkollar@redhat.com> 5.0.16-1
- 1092518 - PIE+RELRO for rhnsd

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 5.0.15-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 5.0.14-1
- cleaning up old svn Ids

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.0.13-1
- removed old CVS/SVN version ids

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.0.12-1
- rebranding few more strings in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.0.11-1
- branding clean-up of rhel client stuff

