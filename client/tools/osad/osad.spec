%define rhnroot /usr/share/rhn
%define rhnconf /etc/sysconfig/rhn
%define client_caps_dir /etc/sysconfig/rhn/clientCaps.d
%{!?pythongen:%define pythongen %(%{__python} -c "import sys ; print sys.version[:3]")}

Name: osad
Summary: OSAD agent
Group:   System Environment/Daemons
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 5.9.30
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: python-devel
Requires: python
Requires: rhnlib >= 1.8-3
Requires: jabberpy
%if 0%{?rhel} <= 5
Requires: python-hashlib
%endif
# This should have been required by rhnlib
Requires: PyXML
%if "%{pythongen}" == "1.5"
Requires: python-iconv
%endif
Conflicts: osa-dispatcher < %{version}-%{release}
Conflicts: osa-dispatcher > %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description 
OSAD agent receive commands over jabber protocol from Spacewalk Server and 
commands are instantly executed.

This package effectively replace rhn_check command which check in Spacewalk
Server only in some period.

%package -n osa-dispatcher
Summary: OSA dispatcher
Group:    System Environment/Daemons
Requires: spacewalk-backend-server
Requires: jabberpy
Conflicts: %{name} < %{version}-%{release}
Conflicts: %{name} > %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig
# This is for /sbin/service
Requires(preun): initscripts

%description -n osa-dispatcher
OSA dispatcher get message from Spacewalk server that some command is need
to execute on client. The message is transported via jabber protocol to OSAD
agent.

%if 0%{?rhel} && 0%{?rhel} <= 4
%define include_selinux_package 0
%else
%define include_selinux_package 1
%endif

%if %{include_selinux_package}
%package -n osa-dispatcher-selinux
%define selinux_variants mls strict targeted
%define selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%define POLICYCOREUTILSVER 1.33.12-1

%define moduletype apps
%define modulename osa-dispatcher

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
Requires(post): /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/selinuxenabled, /usr/sbin/semanage
Requires(postun): /usr/sbin/semodule, /sbin/restorecon, /usr/sbin/semanage, spacewalk-selinux
Requires: osa-dispatcher

%description -n osa-dispatcher-selinux
SELinux policy module supporting osa-dispatcher.

%endif

%prep
%setup -q

%build
make -f Makefile.osad all

%if %{include_selinux_package}
%{__perl} -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' osa-dispatcher-selinux/%{modulename}.te
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
make -f Makefile.osad install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot}

%if %{include_selinux_package}
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

# Install osa-dispatcher-selinux-enable which will be called in %post
install -d %{buildroot}%{_sbindir}
install -p -m 755 osa-dispatcher-selinux/osa-dispatcher-selinux-enable %{buildroot}%{_sbindir}/osa-dispatcher-selinux-enable
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ -f %{_sysconfdir}/init.d/osad ]; then
    /sbin/chkconfig --add osad
fi

%preun
if [ $1 = 0 ]; then
    /sbin/service osad stop > /dev/null 2>&1
    /sbin/chkconfig --del osad
fi

%post -n osa-dispatcher
if [ -f %{_sysconfdir}/init.d/osa-dispatcher ]; then
    /sbin/chkconfig --add osa-dispatcher
fi

%preun -n osa-dispatcher
if [ $1 = 0 ]; then
    /sbin/service osa-dispatcher stop > /dev/null 2>&1
    /sbin/chkconfig --del osa-dispatcher
fi

%if %{include_selinux_package}
%post -n osa-dispatcher-selinux
if /usr/sbin/selinuxenabled ; then
   %{_sbindir}/osa-dispatcher-selinux-enable
fi

%posttrans -n osa-dispatcher-selinux
#this may be safely remove when BZ 505066 is fixed
if /usr/sbin/selinuxenabled ; then
  rpm -ql osa-dispatcher | xargs -n 1 /sbin/restorecon -rvvi {}
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

rpm -ql osa-dispatcher | xargs -n 1 /sbin/restorecon -rvvi {}
/sbin/restorecon -vvi /var/log/rhn/osa-dispatcher.log

%endif

%files
%defattr(-,root,root)
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
%attr(755,root,root) %{_initrddir}/osad
%doc LICENSE
%doc PYTHON-LICENSES.txt

%files -n osa-dispatcher
%defattr(-,root,root)
%dir %{rhnroot}/osad
%attr(755,root,root) %{_sbindir}/osa-dispatcher
%{rhnroot}/osad/__init__.py*
%{rhnroot}/osad/jabber_lib.py*
%{rhnroot}/osad/osa_dispatcher.py*
%{rhnroot}/osad/dispatcher_client.py*
%{rhnroot}/osad/rhn_log.py*
%config(noreplace) %{_sysconfdir}/logrotate.d/osa-dispatcher
%config %{_sysconfdir}/rhn/default/rhn_osa-dispatcher.conf
%attr(755,root,root) %{_initrddir}/osa-dispatcher
%doc LICENSE
%doc PYTHON-LICENSES.txt

%if %{include_selinux_package}
%files -n osa-dispatcher-selinux
%defattr(-,root,root,0755)
%doc osa-dispatcher-selinux/%{modulename}.fc
%doc osa-dispatcher-selinux/%{modulename}.if
%doc osa-dispatcher-selinux/%{modulename}.te
%{_datadir}/selinux/*/%{modulename}.pp
%{_datadir}/selinux/devel/include/%{moduletype}/%{modulename}.if
%doc LICENSE
%doc PYTHON-LICENSES.txt
%attr(0755,root,root) %{_sbindir}/osa-dispatcher-selinux-enable
%endif

# $Id$
%changelog
* Mon Feb 22 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.30-1
- fixed missing Requires: python-hashlib

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.29-1
- updated copyrights

* Mon Feb 01 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.28-1
- use rhnLockfile.py from rhnlib

* Fri Jan 29 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.27-1
- fixed the sha module is deprecated

* Fri Jan 29 2010 Jan Pazdziora 5.9.26-1
- 559230 - address errors during package removal.
- Do not hide any error messages produced by semanage port -a.

* Wed Jan 27 2010 Miroslav Suchy <msuchy@redhat.com> 5.9.25-1
- replaced popen2 with subprocess in client (michael.mraka@redhat.com)

* Mon Jan 18 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.24-1
- fixed syntax error in init.d scripts

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.23-1
- implement condrestart for osad init script 
- make reload alias for restart
- add osad-auth.conf as normal file with placeholder content

* Tue Oct 27 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.22-1
- Make debugging osa* network/jabber issues easier (joshua.roys@gtri.gatech.edu)

* Tue Aug 04 2009 Jan Pazdziora 5.9.21-1
- 514320 - open the pid file with append

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 5.9.20-1
- 512732 - on Fedora 12, it will be just and corenet_udp_bind_generic_node and
  corenet_udp_bind_all_nodes. (jpazdziora@redhat.com)

* Mon Jul 27 2009 Jan Pazdziora 5.9.19-1
- 512732 - on Fedora 11, corenet_udp_bind_lo_node is no longer available
- Build osa-dispatcher-selinux again

* Thu Jul 23 2009 Devan Goodwin <dgoodwin@redhat.com> 5.9.18-1
- Remove Requires python-optik. (dgoodwin@redhat.com)

* Wed Jul 22 2009 Devan Goodwin <dgoodwin@redhat.com> 5.9.17-1
- Disable osad selinux for Fedora 11. (dgoodwin@redhat.com)

* Mon Jul 20 2009 Devan Goodwin <dgoodwin@redhat.com> 5.9.16-1
- Add osad BuildRequires for python-devel. (dgoodwin@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 5.9.15-1
- 508064 - fix osad installation errors on client (mzazrivec@redhat.com)

* Thu Jun 18 2009 Jan Pazdziora 5.9.14-1
- 505606 - Require at least selinux-policy 2.4.6-114

* Mon Jun 15 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.13-1
- 498611 - run restorecon in %%posttrans
- 498611 - run "semodule -i" in %%post and restorecon in %%posttrans

* Wed Apr 29 2009 Jan Pazdziora 5.9.11-1
- move the %%post SELinux activation to
  /usr/sbin/osa-dispatcher-selinux-enable

* Fri Mar 27 2009 jesus m. rodriguez <jesusr@redhat.com> 5.9.10-1
- added PYTHON-LICENSES.txt file

* Mon Mar 16 2009 Jan Pazdziora 5.9.9-1
- remove /usr/sbin/semanage: Port tcp/1290 already defined error
- allow osa-dispatcher to use NIS

* Wed Mar 11 2009 jesus m. rodriguez <jesusr@redhat.com> 5.9.8-1
- 479825 - fix osa-dispatcher to start after oracle(-xe) and stop before them.

* Thu Feb 12 2009 Jan Pazdziora 5.9.6-1
- do not build osa-dispatcher-selinux on RHEL 4 and earlier.
- osa-dispatcher-selinux: setsebool is not used, so no need to Require it

* Mon Feb  9 2009 Jan Pazdziora 5.9.5-1
- addressed additional AVC denials of osa-dispatcher

* Wed Feb  4 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.4-1
- 468060 - correctly return status of daemon
- fix some macros
- edit descriptions
- add LICENSE

* Wed Jan 14 2009 Jan Pazdziora 5.9.2-1
- separate package osa-dispatcher-selinux merged in as a subpackage

* Wed Jan 14 2009 Jan Pazdziora
- changes to osa-dispatcher-selinux to allow service osa-dispatcher start
  on RHEL 5.2 to run without any AVC denials except one caused by lookup
  of /root/.rpmmacros

* Mon Jan 12 2009 Jan Pazdziora
- the initial release of osa-dispatcher-selinux
- based on spacewalk-selinux
- which was inspired by Rob Myers' oracle-selinux

* Tue Dec 16 2008 Michael Mraka <michael.mraka@redhat.com> 5.9.1-1
- resolves #474548 - bumped version

* Tue Oct 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.2-1
- resolves #467717 - fixed sysvinit scripts

* Wed Sep 24 2008 Milan Zazrivec 0.3.1-1
- bumped version for spacewalk 0.3

* Tue Sep  2 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.2-1
- fix osa-dispatcher to depend on new server package

* Thu Jun 12 2008 Pradeep Kilambi <pkilambi@redhat.com>  - 5.2.0-1
- new build

* Tue Jan  25 2008 Jan Pazdziora - 5.1.0-7
- Resolves #429578, OSAD suspending

* Tue Jan  8 2008 Jan Pazdziora - 5.1.0-6
- Resolves #367031, OSAD daemon hard looping
- Resolves #426201, Osad connects to Satellite at times instead of Proxy

* Thu Oct 18 2007 James Slagle <jslagle@redhat.com> - 5.1.0-4
- Resolves #185476

* Tue Oct 08 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-3
- new build

* Tue Sep 25 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-2
- get rid of safe-rhn-check and use rhn_check

* Tue Sep 25 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-1
- bumping version for consistency

* Thu Apr 12 2007 Pradeep Kilambi <pkilambi@redhat.com> - 0.9.2-1
- adding dist tags

* Thu Oct 05 2006 James Bowes <jbowes@redhat.com> - 0.9.1-2
- Get python version dynamically.

* Wed Sep 20 2006 James Bowes <jbowes@redhat.com> - 0.9.1-1
- Set logrotate to limit the log file to 100M.

* Wed Jun 30 2004 Mihai Ibanescu <misa@redhat.com>
- First build
