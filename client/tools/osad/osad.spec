%global rhnroot /usr/share/rhn
%global rhnconf /etc/sysconfig/rhn
%global client_caps_dir /etc/sysconfig/rhn/clientCaps.d
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

%if 0%{?suse_version}
%global apache_group www
%global include_selinux_package 0
%else
%global apache_group apache
%global include_selinux_package 1
%endif

Name: osad
Summary: Open Source Architecture Daemon
Group:   System Environment/Daemons
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 5.11.33
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: python-devel
Requires: python
Requires: rhnlib >= 1.8-3
Requires: jabberpy
%if 0%{?rhel} && 0%{?rhel} < 6
Requires: rhn-client-tools >= 0.4.20-66
%else
%if 0%{?el6}
Requires: rhn-client-tools >= 1.0.0-44
%else
Requires: rhn-client-tools >= 1.3.7
%endif
%endif
%if 0%{?rhel} && 0%{?rhel} <= 5
Requires: python-hashlib
%endif
%if 0%{?suse_version} >= 1140
Requires: python-xml
%endif
Conflicts: osa-dispatcher < %{version}-%{release}
Conflicts: osa-dispatcher > %{version}-%{release}
%if 0%{?suse_version} >= 1210
BuildRequires: systemd
%{?systemd_requires}
%endif
%if 0%{?suse_version}
# provides chkconfig on SUSE
Requires(post): aaa_base
Requires(preun): aaa_base
# to make chkconfig test work during build
BuildRequires: sysconfig syslog
%else
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
%endif
%endif

%description
OSAD agent receives commands over jabber protocol from Spacewalk Server and
commands are instantly executed.

This package effectively replaces the behavior of rhnsd/rhn_check that
only poll the Spacewalk Server from time to time.

%package -n osa-dispatcher
Summary: OSA dispatcher
Group:    System Environment/Daemons
Requires: spacewalk-backend-server >= 1.2.32
Requires: jabberpy
Requires: lsof
Conflicts: %{name} < %{version}-%{release}
Conflicts: %{name} > %{version}-%{release}
%if 0%{?suse_version} >= 1210
%{?systemd_requires}
%endif
%if 0%{?suse_version}
# provides chkconfig on SUSE
Requires(post): aaa_base
Requires(preun): aaa_base
%else
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts
%endif

%description -n osa-dispatcher
OSA dispatcher is supposed to run on the Spacewalk server. It gets information
from the Spacewalk server that some command needs to be execute on the client;
that message is transported via jabber protocol to OSAD agent on the clients.

%if 0%{?include_selinux_package}
%package -n osa-dispatcher-selinux
%global selinux_variants mls strict targeted
%global selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%global POLICYCOREUTILSVER 1.33.12-1

%global moduletype apps
%global modulename osa-dispatcher

Summary: SELinux policy module supporting osa-dispatcher
Group: System Environment/Base
BuildRequires: checkpolicy, selinux-policy-devel, hardlink
BuildRequires: policycoreutils >= %{POLICYCOREUTILSVER}
Requires: spacewalk-selinux

%if "%{selinux_policyver}" != ""
Requires: selinux-policy >= %{selinux_policyver}
%endif
%if 0%{?rhel} == 5
Requires:        selinux-policy >= 2.4.6-114
%endif
Requires(post): /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/selinuxenabled, /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule, %{sbinpath}/restorecon, /usr/sbin/semanage, spacewalk-selinux
Requires: osa-dispatcher

%description -n osa-dispatcher-selinux
SELinux policy module supporting osa-dispatcher.
%endif

%prep
%setup -q
%if 0%{?suse_version}
cp prog.init.SUSE prog.init
%endif

%build
make -f Makefile.osad all

%if 0%{?include_selinux_package}
%{__perl} -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' osa-dispatcher-selinux/%{modulename}.te
%if 0%{?fedora} >= 17
cat osa-dispatcher-selinux/%{modulename}.te.fedora17 >> osa-dispatcher-selinux/%{modulename}.te
%endif
for selinuxvariant in %{selinux_variants}
do
    make -C osa-dispatcher-selinux NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv osa-dispatcher-selinux/%{modulename}.pp osa-dispatcher-selinux/%{modulename}.pp.${selinuxvariant}
    make -C osa-dispatcher-selinux NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done
%endif

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT%{rhnroot}
make -f Makefile.osad install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} INITDIR=%{_initrddir}
mkdir -p %{buildroot}%{_var}/log/rhn
touch %{buildroot}%{_var}/log/osad
touch %{buildroot}%{_var}/log/rhn/osa-dispatcher.log

%if 0%{?fedora} || 0%{?rhel} > 6
sed -i 's/#LOGROTATE-3.8#//' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/osa-dispatcher
%endif

%if 0%{?fedora} || 0%{?suse_version} >= 1210
rm $RPM_BUILD_ROOT/%{_initrddir}/osad
rm $RPM_BUILD_ROOT/%{_initrddir}/osa-dispatcher
mkdir -p $RPM_BUILD_ROOT/%{_unitdir}
install -m 0644 osad.service $RPM_BUILD_ROOT/%{_unitdir}/
install -m 0644 osa-dispatcher.service $RPM_BUILD_ROOT/%{_unitdir}/
%endif

%if 0%{?include_selinux_package}
for selinuxvariant in %{selinux_variants}
  do
    install -d %{buildroot}%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 osa-dispatcher-selinux/%{modulename}.pp.${selinuxvariant} \
           %{buildroot}%{_datadir}/selinux/${selinuxvariant}/%{modulename}.pp
  done

# Install SELinux interfaces
install -d %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}
install -p -m 644 osa-dispatcher-selinux/%{modulename}.if \
  %{buildroot}%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if

# Hardlink identical policy module packages together
/usr/sbin/hardlink -cv %{buildroot}%{_datadir}/selinux

# Install osa-dispatcher-selinux-enable which will be called in %%post
install -d %{buildroot}%{_sbindir}
install -p -m 755 osa-dispatcher-selinux/osa-dispatcher-selinux-enable %{buildroot}%{_sbindir}/osa-dispatcher-selinux-enable
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%if 0%{?suse_version} >= 1210

%pre
%service_add_pre osad.service

%postun
%service_del_postun osad.service

%endif

%{!?systemd_post: %global systemd_post() if [ $1 -eq 1 ] ; then /usr/bin/systemctl enable %%{?*} >/dev/null 2>&1 || : ; fi; }
%{!?systemd_preun: %global systemd_preun() if [ $1 -eq 0 ] ; then /usr/bin/systemctl --no-reload disable %%{?*} > /dev/null 2>&1 || : ; /usr/bin/systemctl stop %%{?*} >/dev/null 2>&1 || : ; fi; }
%{!?systemd_postun_with_restart: %global systemd_postun_with_restart() /usr/bin/systemctl daemon-reload >/dev/null 2>&1 || : ; if [ $1 -ge 1 ] ; then /usr/bin/systemctl try-restart %%{?*} >/dev/null 2>&1 || : ; fi; }


%post
%if 0%{?suse_version} >= 1210
%service_add_post osad.service
%else
if [ -f %{_sysconfdir}/init.d/osad ]; then
    /sbin/chkconfig --add osad
fi
if [ -f %{_unitdir}/osad.service ]; then
    %systemd_post osad.service
    if [ "$1" = "2" ]; then
        # upgrade from old init.d
        if [ -L /etc/rc2.d/S97osad ]; then
            /usr/bin/systemctl enable osad.service >/dev/null 2>&1
        fi
        rm -f /etc/rc?.d/[SK]??osad
    fi
fi

# Fix the /var/log/osad permission BZ 836984
if [ -f %{_var}/log/osad ]; then
    /bin/chmod 600 %{_var}/log/osad
fi
%endif

%preun
%if 0%{?suse_version} >= 1210
%service_del_preun osad.service
%else
if [ $1 = 0 ]; then
    %if 0%{?fedora}
    %systemd_preun osad.service
    %else
    /sbin/service osad stop > /dev/null 2>&1
    /sbin/chkconfig --del osad
    %endif
fi
%endif

%postun
%if 0%{?fedora}
%systemd_postun_with_restart osad.service
%endif

%if 0%{?suse_version} >= 1210

%pre -n osa-dispatcher
%service_add_pre osa-dispatcher.service

%postun -n osa-dispatcher
%service_del_postun osa-dispatcher.service

%endif

%post -n osa-dispatcher
%if 0%{?suse_version} >= 1210
%service_add_post osa-dispatcher.service
%else
if [ -f %{_sysconfdir}/init.d/osa-dispatcher ]; then
    /sbin/chkconfig --add osa-dispatcher
fi
%endif

%preun -n osa-dispatcher
%if 0%{?suse_version} >= 1210
%service_del_preun osa-dispatcher.service
%else
if [ $1 = 0 ]; then
    /sbin/service osa-dispatcher stop > /dev/null 2>&1
    /sbin/chkconfig --del osa-dispatcher
fi
%endif

%if 0%{?include_selinux_package}
%post -n osa-dispatcher-selinux
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/osa-dispatcher-selinux-enable
fi

%posttrans -n osa-dispatcher-selinux
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  rpm -ql osa-dispatcher | xargs -n 1 /sbin/restorecon -rvi {}
  /sbin/restorecon -vvi /var/log/rhn/osa-dispatcher.log
fi

%postun -n osa-dispatcher-selinux
# Clean up after package removal
if [ $1 -eq 0 ]; then

  /usr/sbin/semanage port -ln \
    | perl '-F/,?\s+/' -ane 'print map "$_\n", @F if shift @F eq "osa_dispatcher_upstream_notif_server_port_t" and shift @F eq "tcp"' \
    | while read port ; do \
      /usr/sbin/semanage port -d -t osa_dispatcher_upstream_notif_server_port_t -p tcp $port || :
    done
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semodule -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
fi

rpm -ql osa-dispatcher | xargs -n 1 /sbin/restorecon -rvi {}
/sbin/restorecon -vvi /var/log/rhn/osa-dispatcher.log
%endif

%files
%dir %{rhnroot}/osad
%attr(755,root,root) %{_sbindir}/osad
%{rhnroot}/osad/__init__.py*
%{rhnroot}/osad/_ConfigParser.py*
%{rhnroot}/osad/jabber_lib.py*
%{rhnroot}/osad/osad.py*
%{rhnroot}/osad/osad_client.py*
%{rhnroot}/osad/osad_config.py*
%{rhnroot}/osad/rhn_log.py*
%config(noreplace) %{_sysconfdir}/sysconfig/rhn/osad.conf
%config(noreplace) %attr(600,root,root) %{_sysconfdir}/sysconfig/rhn/osad-auth.conf
%config(noreplace) %{client_caps_dir}/*
%if 0%{?fedora} || 0%{?suse_version} >= 1210
%{_unitdir}/osad.service
%else
%attr(755,root,root) %{_initrddir}/osad
%endif
%doc LICENSE
%config(noreplace) %{_sysconfdir}/logrotate.d/osad
%ghost %attr(600,root,root) %{_var}/log/osad
%if 0%{?suse_version}
# provide directories not owned by any package during build
%dir %{rhnroot}
%dir %{_sysconfdir}/sysconfig/rhn
%dir %{_sysconfdir}/sysconfig/rhn/clientCaps.d
%endif

%files -n osa-dispatcher
%defattr(0644,root,root,0755)
%dir %{rhnroot}/osad
%attr(755,root,root) %{_sbindir}/osa-dispatcher
%{rhnroot}/osad/__init__.py*
%{rhnroot}/osad/jabber_lib.py*
%{rhnroot}/osad/osa_dispatcher.py*
%{rhnroot}/osad/dispatcher_client.py*
%{rhnroot}/osad/rhn_log.py*
%config(noreplace) %{_sysconfdir}/sysconfig/osa-dispatcher
%config(noreplace) %{_sysconfdir}/logrotate.d/osa-dispatcher
%{rhnroot}/config-defaults/rhn_osa-dispatcher.conf
%dir %{_sysconfdir}/rhn/tns_admin
%dir %{_sysconfdir}/rhn/tns_admin/osa-dispatcher
%config(noreplace) %{_sysconfdir}/rhn/tns_admin/osa-dispatcher/sqlnet.ora
%if 0%{?fedora} || 0%{?suse_version} >= 1210
%{_unitdir}/osa-dispatcher.service
%else
%attr(755,root,root) %{_initrddir}/osa-dispatcher
%endif
%attr(770,root,%{apache_group}) %dir %{_var}/log/rhn/oracle
%attr(770,root,root) %dir %{_var}/log/rhn/oracle/osa-dispatcher
%doc LICENSE
%ghost %attr(640,apache,root) %{_var}/log/rhn/osa-dispatcher.log
%if 0%{?suse_version}
%dir %{_sysconfdir}/rhn
%dir %{rhnroot}/config-defaults
%dir %{_var}/log/rhn
%endif

%if 0%{?include_selinux_package}
%files -n osa-dispatcher-selinux
%doc osa-dispatcher-selinux/%{modulename}.fc
%doc osa-dispatcher-selinux/%{modulename}.if
%doc osa-dispatcher-selinux/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%doc LICENSE
%attr(0755,root,root) %{_sbindir}/osa-dispatcher-selinux-enable
%endif

%changelog
* Thu Feb 06 2014 Jan Dobes 5.11.33-1
- 1056515 - adapting to different logrotate version in fedora and rhel

* Mon Nov 11 2013 Milan Zazrivec <mzazrivec@redhat.com> 5.11.32-1
- remove extraneous 'except'

* Fri Nov 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 5.11.31-1
- 917070 - catch jabberd connection errors

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.30-1
- cleaning up old svn Ids

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.29-1
- removed trailing whitespaces

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 5.11.28-1
- Branding clean-up of proxy stuff in client dir

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.27-1
- more branding cleanup

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 5.11.26-1
- rebranding RHN Proxy to Red Hat Proxy in client stuff
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Fri Apr 26 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.25-1
- new logrotate complains about permissions

* Thu Apr 25 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.24-1
- enable osad.service after installation

* Mon Apr 08 2013 Tomas Lestach <tlestach@redhat.com> 5.11.23-1
- setting default attributes for osa-dispatcher files

* Wed Mar 27 2013 Stephen Herr <sherr@redhat.com> 5.11.22-1
- 860937 - somehow I managed to get wrong the version required in rhel 5

* Wed Mar 27 2013 Stephen Herr <sherr@redhat.com> 5.11.21-1
- 860937 - correct requires on RHEL 5

* Tue Mar 26 2013 Stephen Herr <sherr@redhat.com> 5.11.20-1
- 860937 - update osad requires versions for rhel 5 and 6

* Fri Mar 22 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.19-1
- 919468 - fixed path in file based Requires
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 5.11.18-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.17-1
- moved waiting for jabberd to helper
- Updating copyright for 2012

* Wed Feb 06 2013 Michael Mraka <michael.mraka@redhat.com> 5.11.16-1
- start jabberd before osa-dispatcher

* Mon Jan 28 2013 Jan Pazdziora 5.11.15-1
- Reimplement anonymous block with update or insert.

* Mon Dec 10 2012 Jan Pazdziora 5.11.14-1
- 836984 - fixes the permissions on /var/log/osad log file

* Thu Nov 22 2012 Jan Pazdziora 5.11.13-1
- always commit the update

* Tue Nov 13 2012 Jan Pazdziora 5.11.12-1
- Fixing the definition of the pid file.

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 5.11.11-1
- osad: use systemd for openSUSE >= 12.1
- no use of /var/lock/subsys/ anymore

* Tue Oct 30 2012 Jan Pazdziora 5.11.10-1
- Update the copyright year.

* Mon Oct 22 2012 Jan Pazdziora 5.11.9-1
- Revert "Revert "Revert "get_server_capability() is defined twice in osad and
  rhncfg, merge and move to rhnlib and make it member of rpclib.Server"""

* Thu Oct 18 2012 Michael Mraka <michael.mraka@redhat.com> 5.11.8-1
- osad requires config.getServerlURL()

* Sat Oct 13 2012 Jan Pazdziora 5.11.7-1
- Start of osa-dispatcher on RHEL 5.

* Tue Sep 18 2012 Jan Pazdziora 5.11.6-1
- Remove osa-dispatcher.pid in StartPre as confined daemon is unable to.

* Wed Aug 29 2012 Jan Pazdziora 5.11.5-1
- We cannot use PIDFile as variable in ExecStart.
- Allow osa-dispatcher to read /etc/passwd, it seems to be needed by the
  generic python modules.

* Tue Jul 31 2012 Michael Mraka <michael.mraka@redhat.com> 5.11.4-1
- 844603 - removed PyXML dependency

* Mon Jul 30 2012 Michael Mraka <michael.mraka@redhat.com> 5.11.3-1
- there's no elsif macro

* Wed Jul 25 2012 Michael Mraka <michael.mraka@redhat.com> 5.11.2-1
- make sure _unitdir is defined

* Wed Jul 25 2012 Michael Mraka <michael.mraka@redhat.com> 5.11.1-1
- implement osa-dispatcher.service for systemd
- implement osad.service for systemd

* Tue Apr 10 2012 Milan Zazrivec <mzazrivec@redhat.com> 5.10.44-1
- 716064 - prevent 'notifying clients' starvation

* Mon Apr 09 2012 Stephen Herr <sherr@redhat.com> 5.10.43-1
- 810908 - Make osa-dispatcher use the hostname in the rhn.conf if present
  (sherr@redhat.com)

* Tue Apr 03 2012 Jan Pazdziora 5.10.42-1
- use %%global, not %%define (msuchy@redhat.com)
- osad.src:477: W: macro-in-%%changelog %%descriptions (msuchy@redhat.com)
- osad.src:154: W: macro-in-comment %%post (msuchy@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 5.10.41-1
- Update the copyright year info.

* Thu Mar 01 2012 Miroslav Suchý 5.10.40-1
- creating files for %%ghost should be done in %%install instead of %%build

* Wed Feb 29 2012 Miroslav Suchý 5.10.39-1
- log file may contain password, set chmod to 600
- by default log to /var/log/osad
- /etc/rhn/tns_admin/osa-dispatcher is directory, not config file
- fix typo in description
- mark log file osa-dispatcher.log as ghost owned
- add logrotate for /var/log/osad and own this file (as ghost)

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 5.10.38-1
- we are now just GPL

* Tue Feb 07 2012 Jan Pazdziora 5.10.35-1
- Make sure that in case only NETWORKING_IPV6 is set, we do not get bash 'unary
  operator expected' error (jhutar@redhat.com)

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.10.34-1
- update copyright info

* Wed Dec 21 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.33-1
- python 2.4 on RHEL5 don't know 'with' block

* Tue Dec 20 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.10.32-1
- Update db with new dispatcher password

* Tue Dec 20 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.31-1
- don't print double [OK] when restarting
- turn off DeprecationWarning for jabber module

* Fri Dec 16 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.30-1
- 756761 - reconnect if jabber server returns error during handshake

* Fri Dec 09 2011 Jan Pazdziora 5.10.29-1
- 691847, 664491 - adding tcp_keepalive_timeout and tcp_keepalive_count options
  to osad.conf.
- 691847, 664491 - read the keepalive settings from osad.conf and apply them to
  the osad socket.

* Fri Dec 02 2011 Jan Pazdziora 5.10.28-1
- Using password_in for parameter name to avoid confusion.

* Mon Nov 28 2011 Miroslav Suchý 5.10.27-1
- specify missing param password (mc@suse.de)

* Fri Nov 25 2011 Jan Pazdziora 5.10.26-1
- The update_client_message_sent method is not used, removing.

* Fri Nov 04 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.10.25-1
- 679335 - store osa-dispatcher jabber password in DB

* Fri Oct 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.10.24-1
- 679353 - automatically detect system re-registration

* Fri Sep 30 2011 Jan Pazdziora 5.10.23-1
- 689939 - match star in common name.

* Fri Sep 30 2011 Jan Pazdziora 5.10.22-1
- 621531 - move /etc/rhn/default to /usr/share/rhn/config-defaults (osa-
  dispatcher).

* Thu Aug 11 2011 Miroslav Suchý 5.10.21-1
- True and False constants are defined since python 2.4
- do not mask original error by raise in execption

* Thu Jul 21 2011 Jan Pazdziora 5.10.20-1
- Allow osa-dispatcher to read /sys/.../meminfo.

* Thu Jul 21 2011 Jan Pazdziora 5.10.19-1
- Revert "Fedora 15 uses oracledb_port_t instead of oracle_port_t."

* Mon Jul 18 2011 Jan Pazdziora 5.10.18-1
- Fedora 15 uses oracledb_port_t instead of oracle_port_t.

* Fri Jul 15 2011 Miroslav Suchý 5.10.17-1
- optparse is here since python 2.3 - remove optik (msuchy@redhat.com)

* Tue Jun 07 2011 Jan Pazdziora 5.10.16-1
- 705935 - introduce rhnSQL.commit() after the both SELECT statements that seem
  to be the main loop (a.rogge@solvention.de)

* Mon May 02 2011 Jan Pazdziora 5.10.15-1
- Bumping up version to get above the one we backported to Spacewalk 1.4.
- Revert "bump up epoch, and match version of osad with spacewalk version".
- bump up epoch, and match version of osad with spacewalk version
  (msuchy@redhat.com)

* Fri Apr 15 2011 Jan Pazdziora 5.10.12-1
- require python-hashlib only on rhel and rhel <= 5 (mc@suse.de)
- build osad on SUSE (mc@suse.de)
- provide config (mc@suse.de)

* Fri Apr 15 2011 Jan Pazdziora 5.10.11-1
- Address the spacewalk.common.rhnLog and .rhnConfig castling in osa-dispacher.

* Wed Apr 13 2011 Jan Pazdziora 5.10.10-1
- utilize config.getProxySetting() (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 5.10.9-1
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)
- update copyright years (msuchy@redhat.com)

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.8-1
- idn_unicode_to_pune() has to return string

* Wed Mar 30 2011 Miroslav Suchý 5.10.7-1
- utilize config.getServerlURL()
- 683200 - use pune encoding when connecting to jabber

* Wed Mar 30 2011 Jan Pazdziora 5.10.6-1
- no need to support rhel2 (msuchy@redhat.com)
- RHEL 4 is no longer a target version for osa-dispatcher, fixing .spec to
  always build osa-dispatcher-selinux.

* Tue Mar 08 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.5-1
- fixed osad last_message_time update (PG)
- fixed osad next_action_time update (PG)

* Thu Feb 24 2011 Jan Pazdziora 5.10.4-1
- 662593 - let osad initiate presence subscription (mzazrivec@redhat.com)

* Fri Feb 18 2011 Jan Pazdziora 5.10.3-1
- Revert "Revert "get_server_capability() is defined twice in osad and rhncfg,
  merge and move to rhnlib and make it member of rpclib.Server""
  (msuchy@redhat.com)

* Mon Feb 07 2011 Tomas Lestach <tlestach@redhat.com> 5.10.2-1
- do not check port 5222 on the client (tlestach@redhat.com)

* Thu Feb 03 2011 Tomas Lestach <tlestach@redhat.com> 5.10.1-1
- Bumping version to 5.10

* Thu Feb 03 2011 Tomas Lestach <tlestach@redhat.com> 5.9.53-1
- reverting osa-dispatcher selinux policy rules (tlestach@redhat.com)

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 5.9.52-1
- pospone osa-dispatcher start, until jabberd is ready (tlestach@redhat.com)

* Tue Feb 01 2011 Tomas Lestach <tlestach@redhat.com> 5.9.51-1
- Revert "get_server_capability() is defined twice in osad and rhncfg, merge
  and move to rhnlib and make it member of rpclib.Server" (tlestach@redhat.com)

* Fri Jan 28 2011 Miroslav Suchý <msuchy@redhat.com> 5.9.50-1
- get_server_capability() is defined twice in osad and rhncfg, merge and move
  to rhnlib and make it member of rpclib.Server

* Mon Jan 17 2011 Jan Pazdziora 5.9.49-1
- Silence InstantClient 11g-related AVCs in osa-dispatcher.
- Silence diagnostics which was causing AVC denials.

* Tue Dec 21 2010 Jan Pazdziora 5.9.48-1
- SQL changes for PostgreSQL support.

* Fri Dec 10 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.47-1
- 661998 - removed looping symlink
- fixed symlink creation

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.46-1
- removed unused imports

* Thu Nov 18 2010 Lukas Zapletal 5.9.45-1
- 630867 - Allow osa-dispatcher to connect to the PostgreSQL database with
  PostgreSQL backend.

* Tue Nov 02 2010 Jan Pazdziora 5.9.44-1
- Update copyright years in the rest of the repo.

* Fri Oct 29 2010 Jan Pazdziora 5.9.43-1
- removed unused class JabberCallback (michael.mraka@redhat.com)

* Thu Oct 21 2010 Miroslav Suchý <msuchy@redhat.com> 5.9.42-1
- 612581 - spacewalk-backend modules has been migrated to spacewalk namespace

* Tue Oct 12 2010 Lukas Zapletal 5.9.41-1
- Sysdate pgsql fix in osad

* Tue Oct 12 2010 Jan Pazdziora 5.9.40-1
- The osa-dispatcher SELinux module has the Oracle parts optional as well.

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.39-1
- replaced local copy of compile.py with standard compileall module

* Wed Aug 04 2010 Jan Pazdziora 5.9.38-1
- Allow osa-dispatcher to talk to PostgreSQL.

* Mon Jul 26 2010 Milan Zazrivec <mzazrivec@redhat.com> 5.9.37-1
- 618300 - default_db is no longer needed

* Tue Jul 20 2010 Milan Zazrivec <mzazrivec@redhat.com> 5.9.36-1
- make osa-dispatcher start after jabberd

* Mon Jun 21 2010 Jan Pazdziora 5.9.35-1
- Some spell checking in %%descriptions.
- OSAD stands for Open Source Architecture Daemon.

* Tue May 04 2010 Jan Pazdziora 5.9.34-1
- 575555 - address corecmd_exec_sbin deprecation warning.

* Tue May 04 2010 Jan Pazdziora 5.9.33-1
- 580047 - address AVCs about sqlnet.log when the database is down.

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.32-1
- do not start osad by default
- require python-haslib only in RHEL5

