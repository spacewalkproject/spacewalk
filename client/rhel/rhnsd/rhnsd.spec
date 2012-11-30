Summary: Red Hat Network query daemon
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
Name: rhnsd
Version: 5.0.8
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires: gettext

Requires: rhn-check >= 0.0.8
%if 0%{?suse_version} >= 1210
BuildRequires: systemd
%{?systemd_requires}
%endif
%if 0%{?suse_version}
Requires(post): aaa_base
Requires(preun): aaa_base
BuildRequires: sysconfig
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
Requires(postun): initscripts
%endif
%endif

%description
The Red Hat Update Agent that automatically queries the Red Hat
Network servers and determines which packages need to be updated on
your machine, and runs any actions.

%prep
%setup -q

%build
make -f Makefile.rhnsd %{?_smp_mflags} CFLAGS="%{optflags}"

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.rhnsd install VERSION=%{version}-%{release} PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir} INIT_DIR=$RPM_BUILD_ROOT/%{_initrddir}

%if 0%{?suse_version} && 0%{?suse_version} < 1210
install -m 0755 rhnsd.init.SUSE $RPM_BUILD_ROOT/%{_initrddir}/rhnsd
%endif
%if 0%{?fedora} || 0%{?suse_version} >= 1210
rm $RPM_BUILD_ROOT/%{_initrddir}/rhnsd
mkdir -p $RPM_BUILD_ROOT/%{_unitdir}
install -m 0644 rhnsd.service $RPM_BUILD_ROOT/%{_unitdir}/
%endif

%find_lang %{name}

%if 0%{?suse_version} >= 1210
%pre
%service_add_pre rhnsd.service
%endif

%post
%if 0%{?suse_version} >= 1210
%service_add_post rhnsd.service
%else
if [ -f /etc/init.d/rhnsd ]; then
    /sbin/chkconfig --add rhnsd
fi
%endif

%preun
%if 0%{?suse_version} >= 1210
%service_del_preun rhnsd.service
%else
if [ $1 = 0 ] ; then
    %if 0%{?fedora}
    /bin/systemctl stop rhnsd.service >/dev/null 2>&1
    %else
    service rhnsd stop >/dev/null 2>&1
    %endif
    if [ -f /etc/init.d/rhnsd ]; then
        /sbin/chkconfig --del rhnsd
    fi
fi
%endif

%postun
%if 0%{?suse_version} >= 1210
%service_del_postun rhnsd.service
%else
if [ "$1" -ge "1" ]; then
    %if 0%{?fedora}
    /bin/systemctl condrestart rhnsd.service >/dev/null 2>&1 || :
    %else
    service rhnsd condrestart >/dev/null 2>&1 || :
    %endif
fi
%endif

%clean
rm -fr $RPM_BUILD_ROOT


%files -f %{name}.lang
%dir %{_sysconfdir}/sysconfig/rhn
%config(noreplace) %{_sysconfdir}/sysconfig/rhn/rhnsd
%{_sbindir}/rhnsd
%if 0%{?fedora} || 0%{?suse_version} >= 1210
%{_unitdir}/rhnsd.service
%else
%{_initrddir}/rhnsd
%endif
%{_mandir}/man8/rhnsd.8*
%doc LICENSE

%changelog
* Fri Nov 30 2012 Jan Pazdziora 5.0.8-1
- Revert "876328 - updating rhel client tools translations"

* Mon Nov 19 2012 Jan Pazdziora 5.0.7-1
- Only run chkconfig if we are in the SysV world.
- rhnsd needs to be marked as forking.
- When talking to systemctl, we need to say .service.

* Fri Nov 16 2012 Jan Pazdziora 5.0.6-1
- 876328 - updating rhel client tools translations

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 5.0.5-1
- use systemd on openSUSE >= 12.1
- do not start rhnsd in runlevel 2 which has no network
- no use of /var/lock/subsys/ anymore

* Tue Oct 30 2012 Jan Pazdziora 5.0.4-1
- Update .po and .pot files for rhnsd.
- New translations from Transifex for rhnsd.
- Download translations from Transifex for rhnsd.

* Mon Jul 30 2012 Michael Mraka <michael.mraka@redhat.com> 5.0.3-1
- there's no elsif macro

* Wed Jul 25 2012 Michael Mraka <michael.mraka@redhat.com> 5.0.2-1
- make sure _unitdir is defined

* Wed Jul 25 2012 Michael Mraka <michael.mraka@redhat.com> 5.0.1-1
- implement rhnsd.service for systemd

* Tue Feb 28 2012 Jan Pazdziora 4.9.15-1
- Update .po and .pot files for rhnsd.
- Download translations from Transifex for rhnsd.

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 4.9.14-1
- updated translations

* Fri Jul 29 2011 Tomas Lestach <tlestach@redhat.com> 4.9.13-1
- 679054 - fix random interval part (tlestach@redhat.com)

* Tue Jul 19 2011 Jan Pazdziora 4.9.12-1
- Merging Transifex changes for rhnsd.
- New translations from Transifex for rhnsd.
- Download translations from Transifex for rhnsd.

* Tue Jul 19 2011 Jan Pazdziora 4.9.11-1
- update .po and .pot files for rhnsd

* Fri Apr 15 2011 Jan Pazdziora 4.9.10-1
- changes to build rhnsd on SUSE (mc@suse.de)

* Fri Feb 18 2011 Jan Pazdziora 4.9.9-1
- l10n: Updates to Estonian (et) translation (mareklaane@fedoraproject.org)

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 4.9.8-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- update .po and .pot files for rhnsd (tlestach@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 4.9.7-1
- Update copyright years in the rest of the repo.
- update .po and .pot files for rhnsd

* Thu Aug 12 2010 Milan Zazrivec <mzazrivec@redhat.com> 4.9.6-1
- update .po and .pot files for rhnsd (msuchy@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 4.9.4-1
- l10n: Updates to Czech (cs) translation (msuchy@fedoraproject.org)
- cleanup - removing translation file, which does not match any language code
  (msuchy@redhat.com)
- update po files for rhnsd (msuchy@redhat.com)
- generate new pot file for rhnsd (msuchy@redhat.com)
- l10n: Updates to Polish (pl) translation (raven@fedoraproject.org)

* Fri Mar 19 2010 Jan Pazdziora 4.9.3-1
- Check return value of regcomp, fix a memory leak (Joshua Roys)

* Wed Feb 10 2010 Miroslav Suchý <msuchy@redhat.com> 4.9.2-1
- Pass version define to the compiler (Jan Pazdziora)
- 533895 - if init script is run user return code 4
- 533891 - if reloading fails return code 7
- 533891 - implement force-reload
- 533867 - init script, wrong parameter should return 2

* Tue Feb 09 2010 Jan Pazdziora 4.9.1-1
- 563173 - change the logging and config processing logic

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 4.8.3-1
- updated copyrights

* Mon Jan 25 2010 Tomas Lestach <tlestach@redhat.com> 4.8.2-1
- fixing systemid parsing (joshua.roys@gtri.gatech.edu)

* Thu Jan 21 2010 Miroslav Suchý <msuchy@redhat.com> 4.8.1-1
- bumping up version, to be ahead of rhel5 versions

* Tue Dec  1 2009 Miroslav Suchý <msuchy@redhat.com> 4.5.16-1
- 502234 - fixing issue where the rhnsd init script would fail to reload the configuration, a forward port of a patch from rhel 4 (jsherril@redhat.com)
- 541682 - make env. for rhn_check consistent with osad (mzazrivec@redhat.com)

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 4.5.15-1
- hardcode MANPATH

* Fri Sep 25 2009 Tomas Lestach <tlestach@redhat.com> 4.5.14-1
- removed hardcoded systemid path (tlestach@redhat.com)

* Tue Sep 22 2009 Miroslav Suchý <msuchy@redhat.com> 4.5.13-1
- use macros
- pass CFLAGS on correct position
- add LICENSE file
- change header info to actual license

* Mon Sep 21 2009 Miroslav Suchý <msuchy@redhat.com> 4.5.12-1
- implement try-restart as alias for condrestart
- add LSB header
- change url, source0 and requires according to packaging guidelines

* Tue Jul 21 2009 John Matthews <jmatthew@redhat.com> 4.5.11-1
- #503719 - fix for postun scriptlet error (pkilambi@redhat.com)

* Tue Jul  7 2009 Pradeep Kilambi <pkilambi@redhat.com>
- Resolves: #503719 - fix for postun scriptlet error

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 4.5.10-1
- 243699: fixing the error code when unknown command is used with rhnsd init
  (pkilambi@redhat.com)
- updateing translations for rhnsd (pkilambi@redhat.com)

* Wed Jun  3 2009 Pradeep Kilambi <pkilambi@redhat.com> 4.7.0-3
- Resolves:  #243699 -fixing error code for unknown command to rhnsd init script

* Mon May 11 2009 Pradeep Kilambi <pkilambi@redhat.com> 4.7.0-2
- Updated translations.
- Resolves:  #243699
  
* Tue Jan 27 2009 Miroslav Suchý <msuchy@redhat.com> 4.5.9-1
- rebuild

* Wed Jan 21 2009 Pradeep Kilambi <pkilambi@redhat.com> 4.5.8-1
- Remove usage of version and sources files.
 
* Mon Dec 11 2006 James Bowes <jbowes@redhat.com> - 4.5.7-1
- Updated translations.
- Related: #216837

* Fri Dec 01 2006 James Bowes <jbowes@redhat.com> - 4.5.6-1
- Updated translations.

* Thu Nov 30 2006 James Bowes <jbowes@redhat.com> - 4.5.5-1
- New and updated translations.

* Tue Nov 28 2006 James Bowes <jbowes@redhat.com> - 4.5.4-1
- New and updated translations.

* Tue Nov 14 2006 James Bowes <jbowes@redhat.com> - 4.5.3-1
- Updated manual page.
- Require gettext.

* Mon Oct 30 2006 James Bowes <jbowes@redhat.com> - 4.5.2-1
- New and updated translations.

* Thu Sep 14 2006 James Bowes <jbowes@redhat.com> - 4.5.1-1
- Fix for bz 163483: rhnsd spawns children with SIGPIPE set to SIG_IGN

* Fri Jul 21 2006 James Bowes <jbowes@redhat.com> - 4.5.0-3
- Require rhn-check, not rhn_check.

* Wed Jul 19 2006 James Bowes <jbowes@redhat.com> - 4.5.0-2
- spec file cleanups.

* Fri Jul 07 2006 James Bowes <jbowes@redhat.com> - 4.5.0-1
- Release for RHEL5 matching with up2date.

* Thu May 18 2006 James Bowes <jbowes@redhat.com> - 0.0.2-1
- Refer to the proper commands in the man page.

* Tue Apr 11 2006 James Bowes <jbowes@redhat.com> - 0.0.1-1
- initial split from main up2date package.
