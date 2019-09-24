%define move_yum_conf_back 1
%define auto_sitelib 1
%define yum_updatesd 0
%define disable_check 1
%define yum_cron_systemd 1
%define yum_makecache_systemd 1

%if 0%{?rhel}
# If we are building for RHEL ...

%if 0%{?rhel} <= 6
# rhel-6 doesn't have the systemd stuff...
%define yum_cron_systemd 0
%endif

%if 0%{?rhel} <= 7
# rhel-7 doesn't use systemd timers...
%define yum_makecache_systemd 0
%endif

# END OF: If we are building for RHEL ...
%endif


%if 0%{?fedora}
# If we are building for Fedora ...

# we don't have this as of RHEL-7.0.
BuildRequires: bash-completion

%if 0%{?fedora} <= 18
# yum in Fedora <= 18 doesn't use systemd unit files...
%define yum_cron_systemd 0
%endif

%if 0%{?fedora} <= 19
# Don't use .timer's before 20, maybe 19?
%define yum_makecache_systemd 0
%endif

# END OF: If we are building for Fedora ...
%endif


%if %{auto_sitelib}

%{!?python_sitelib: %define python_sitelib %(python2 -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

%else
%define python_sitelib /usr/lib/python?.?/site-packages
%endif

# We always used /usr/lib here, even on 64bit ... so it's a bit meh.
%define yum_pluginslib   /usr/lib/yum-plugins
%define yum_pluginsshare /usr/share/yum-plugins

# disable broken /usr/lib/rpm/brp-python-bytecompile
%define __os_install_post %{nil}
%define compdir %(pkg-config --variable=completionsdir bash-completion)
%if "%{compdir}" == ""
%define compdir "/etc/bash_completion.d"
%endif

Summary: RPM package installer/updater/manager
Name: yum
Version: 3.4.3
Release: 521.1%{?dist}
License: GPLv2+
Source0: http://yum.baseurl.org/download/3.4/%{name}-%{version}.tar.gz
Source1: yum.conf.fedora
Source2: yum-updatesd.conf.fedora
Patch1: yum-distro-configs.patch
Patch5: geode-arch.patch
Patch6: yum-HEAD.patch
Patch7: yum-ppc64-preferred.patch
Patch20: yum-manpage-files.patch
Patch21: yum-completion-helper.patch
Patch22: yum-deprecated.patch
Patch23: python2-gpg-port.patch

Conflicts: yum > 4.0
URL: http://yum.baseurl.org/
BuildArchitectures: noarch
BuildRequires: python2-devel
BuildRequires: gettext
BuildRequires: intltool
%if %{yum_makecache_systemd}
BuildRequires: systemd-units
%endif
# This is really CheckRequires ...
BuildRequires: python2-nose
BuildRequires: python2 >= 2.4
BuildRequires: python2-rpm, rpm >= 0:4.4.2
BuildRequires: python2-iniparse
BuildRequires: python2-urlgrabber >= 3.9.0-8
BuildRequires: yum-metadata-parser >= 1.1.0
BuildRequires: python2-gpg = 1.12.0
# End of CheckRequires
Conflicts: pirut < 1.1.4
Requires: python2 >= 2.4
Requires: python2-rpm, rpm >= 0:4.4.2
Requires: python2-iniparse
Requires: python2-urlgrabber >= 3.9.0-8
Requires: yum-metadata-parser >= 1.1.0
Requires: python2-gpg = 1.12.0
# rawhide is >= 0.5.3-7.fc18 ... as this is added.
Requires: pyliblzma
# Not really a suggests anymore, due to metadata using it.
Requires: python2-pyxattr
# Suggests, needed for yum fs diff
Requires: diffutils
Requires: cpio

Conflicts: rpm >= 5-0
# Zif is a re-implementation of yum in C, however:
#
# 1. There is no co-operation/etc. with us.
# 2. It touches our private data directly.
#
# ...both of which mean that even if there were _zero_ bugs in zif, we'd
# never be able to change anything after the first user started using it. And
# of course:
#
# 3. Users will never be able to tell that it isn't weird yum bugs, when they
# hit them (and we'll probably never be able to debug them, without becoming
# zif experts).
#
# ...so we have two sane choices: i) Conflict with it. 2) Stop developing yum.
#
#  Upstream says that #2 will no longer be true after this release.
Conflicts: zif <= 0.1.3-3.fc15

Obsoletes: yum-skip-broken <= 1.1.18
Provides: yum-skip-broken = 1.1.18.yum
Obsoletes: yum-basearchonly <= 1.1.9
Obsoletes: yum-plugin-basearchonly <= 1.1.9
Provides: yum-basearchonly = 1.1.9.yum
Provides: yum-plugin-basearchonly = 1.1.9.yum
Obsoletes: yum-allow-downgrade < 1.1.20-0
Obsoletes: yum-plugin-allow-downgrade < 1.1.22-0
Provides: yum-allow-downgrade = 1.1.20-0.yum
Provides: yum-plugin-allow-downgrade = 1.1.22-0.yum
Obsoletes: yum-plugin-protect-packages < 1.1.27-0
Provides: yum-protect-packages = 1.1.27-0.yum
Provides: yum-plugin-protect-packages = 1.1.27-0.yum
Obsoletes: yum-plugin-download-order <= 0.2-2
Obsoletes: yum-plugin-downloadonly <= 1.1.31-7.fc18
Provides: yum-plugin-downloadonly = 3.4.3-44.yum
Obsoletes: yum-presto < 3.4.3-66.yum
Provides: yum-presto = 3.4.3-66.yum
Obsoletes: yum-plugin-security < 1.1.32
Provides: yum-plugin-security = 3.4.3-84.yum


%description
Yum is a utility that can check for and automatically download and
install updated RPM packages. Dependencies are obtained and downloaded 
automatically, prompting the user for permission as necessary.

%package updatesd
Summary: Update notification daemon
Requires: yum = %{version}-%{release}
Requires: python2-dbus
Requires: pygobject2
Requires(preun): /sbin/chkconfig
Requires(post): /sbin/chkconfig
Requires(preun): /sbin/service
Requires(post): /sbin/service
Requires(postun): /sbin/chkconfig
Requires(postun): /sbin/service


%description updatesd
yum-updatesd provides a daemon which checks for available updates and 
can notify you when they are available via email, syslog or dbus. 

%package cron
Summary: RPM package installer/updater/manager cron service
Requires: yum >= 3.4.3-84 cronie crontabs findutils
Requires: yum-cron-BE = %{version}-%{release}
# We'd probably like a suggests for yum-cron-daily here.
%if %{yum_cron_systemd}
BuildRequires: systemd-units
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
%else
Requires(post): /sbin/chkconfig
Requires(post): /sbin/service
Requires(preun): /sbin/chkconfig
Requires(preun): /sbin/service
Requires(postun): /sbin/service
%endif

%description cron
These are the files needed to run any of the yum-cron update services.

%package cron-daily
Summary: Files needed to run yum updates as a daily cron job
Provides: yum-cron-BE = %{version}-%{release}
Requires: yum-cron > 3.4.3-131

%description cron-daily
This is the configuration file for the daily yum-cron update service, which
lives %{_sysconfdir}/yum/yum-cron.conf.
Install this package if you want auto yum updates nightly via cron (or something
else, via. changing the configuration).
By default this just downloads updates and does not apply them.

%package cron-hourly
Summary: Files needed to run yum updates as an hourly cron job
Provides: yum-cron-BE = %{version}-%{release}
Requires: yum-cron > 3.4.3-131

%description cron-hourly
This is the configuration file for the daily yum-cron update service, which
lives %{_sysconfdir}/yum/yum-cron-hourly.conf.
Install this package if you want automatic yum metadata updates hourly via
cron (or something else, via. changing the configuration).

%package cron-security
Summary: Files needed to run security yum updates as once a day
Provides: yum-cron-BE = %{version}-%{release}
Requires: yum-cron > 3.4.3-131

%description cron-security
This is the configuration file for the security yum-cron update service, which
lives here: %{_sysconfdir}/yum/yum-cron-security.conf
Install this package if you want automatic yum security updates once a day
via. cron (or something else, via. changing the configuration -- this will be
confusing if it's not security updates anymore though).
By default this will download and _apply_ the security updates, unlike
yum-cron-daily which will just download all updates by default.
This runs after yum-cron-daily, if that is installed.


%prep
%setup -q
%patch5 -p1
%patch6 -p1
%patch7 -p1
%patch20 -p1
%patch21 -p1
%patch22 -p1
%patch23 -p1
%patch1 -p1

%build
make PYTHON=python2

%if !%{disable_check}
%check
make PYTHON=python2 check
%endif


%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%if %{yum_cron_systemd}
INIT=systemd
%else
INIT=sysv
%endif

make PYTHON=python2 DESTDIR=$RPM_BUILD_ROOT UNITDIR=%{_unitdir} INIT=$INIT install

install -m 644 %{SOURCE1} $RPM_BUILD_ROOT/%{_sysconfdir}/yum.conf
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/yum/pluginconf.d $RPM_BUILD_ROOT/%{yum_pluginslib}
mkdir -p $RPM_BUILD_ROOT/%{yum_pluginsshare}

%if %{move_yum_conf_back}
# for now, move repodir/yum.conf back
mv $RPM_BUILD_ROOT/%{_sysconfdir}/yum/repos.d $RPM_BUILD_ROOT/%{_sysconfdir}/yum.repos.d
rm -f $RPM_BUILD_ROOT/%{_sysconfdir}/yum/yum.conf
%endif

%if %{yum_updatesd}
echo Keeping local yum-updatesd
%else

# yum-updatesd has moved to the separate source version
rm -f $RPM_BUILD_ROOT/%{_sysconfdir}/yum/yum-updatesd.conf 
rm -f $RPM_BUILD_ROOT/%{_sysconfdir}/rc.d/init.d/yum-updatesd
rm -f $RPM_BUILD_ROOT/%{_sysconfdir}/dbus-1/system.d/yum-updatesd.conf
rm -f $RPM_BUILD_ROOT/%{_sbindir}/yum-updatesd
rm -f $RPM_BUILD_ROOT/%{_mandir}/man*/yum-updatesd*
rm -f $RPM_BUILD_ROOT/%{_datadir}/yum-cli/yumupd.py*

%endif

# Ghost files:
mkdir -p $RPM_BUILD_ROOT/var/lib/yum/history
mkdir -p $RPM_BUILD_ROOT/var/lib/yum/plugins
mkdir -p $RPM_BUILD_ROOT/var/lib/yum/yumdb
touch $RPM_BUILD_ROOT/var/lib/yum/uuid

# rpmlint bogus stuff...
chmod +x $RPM_BUILD_ROOT/%{_datadir}/yum-cli/*.py
chmod +x $RPM_BUILD_ROOT/%{python2_sitelib}/yum/*.py
chmod +x $RPM_BUILD_ROOT/%{python2_sitelib}/rpmUtils/*.py

%find_lang %name

%if %{yum_cron_systemd}
# Remove the yum-cron sysV stuff to make rpmbuild happy..
rm -f $RPM_BUILD_ROOT/%{_sysconfdir}/rc.d/init.d/yum-cron
%else
# Remove the yum-cron systemd stuff to make rpmbuild happy..
rm -f $RPM_BUILD_ROOT/%{_unitdir}/yum-cron.service
%endif

%if %{yum_makecache_systemd}
cp -a etc/yum-makecache.service $RPM_BUILD_ROOT/%{_unitdir}
cp -a etc/yum-makecache.timer   $RPM_BUILD_ROOT/%{_unitdir}
%endif


%if %{yum_updatesd}
%post updatesd
/sbin/chkconfig --add yum-updatesd
/sbin/service yum-updatesd condrestart >/dev/null 2>&1
exit 0

%preun updatesd
if [ $1 = 0 ]; then
 /sbin/chkconfig --del yum-updatesd
 /sbin/service yum-updatesd stop >/dev/null 2>&1
fi
exit 0
%endif

%post cron

%if %{yum_cron_systemd}
#systemd_post yum-cron.service
#  Do this manually because it's a fake service for a cronjob, and cronjobs
# are default on atm. This may change in the future.
if [ $1 = 1 ]; then
 systemctl enable yum-cron >/dev/null 2>&1
else
#  Note that systemctl preset is being run here ... but _only_ on initial
# install. So try this...

if [ -f /var/lock/subsys/yum-cron -a -f /etc/rc.d/init.d/yum-cron ]; then
 systemctl enable yum-cron >/dev/null 2>&1
fi
fi

# Also note:
#  systemctl list-unit-files | fgrep yum-cron
%else
# SYSV init post cron
# Make sure chkconfig knows about the service
/sbin/chkconfig --add yum-cron
# if an upgrade:
if [ "$1" -ge "1" ]; then
# if there's a /etc/rc.d/init.d/yum file left, assume that there was an
# older instance of yum-cron which used this naming convention.  Clean 
# it up, do a conditional restart
 if [ -f /etc/init.d/yum ]; then 
# was it on?
  /sbin/chkconfig yum
  RETVAL=$?
  if [ $RETVAL = 0 ]; then
# if it was, stop it, then turn on new yum-cron
   /sbin/service yum stop 1> /dev/null 2>&1
   /sbin/service yum-cron start 1> /dev/null 2>&1
   /sbin/chkconfig yum-cron on
  fi
# remove it from the service list
  /sbin/chkconfig --del yum
 fi
fi 
exit 0
%endif

%preun cron
%if %{yum_cron_systemd}
%systemd_preun yum-cron.service
%else
# SYSV init preun cron
# if this will be a complete removeal of yum-cron rather than an upgrade,
# remove the service from chkconfig control
if [ $1 = 0 ]; then
 /sbin/chkconfig --del yum-cron
 /sbin/service yum-cron stop 1> /dev/null 2>&1
fi
exit 0
%endif

%postun cron
%if %{yum_cron_systemd}
%systemd_postun_with_restart yum-cron.service
%else
# SYSV init postun cron

# If there's a yum-cron package left after uninstalling one, do a
# conditional restart of the service
if [ "$1" -ge "1" ]; then
 /sbin/service yum-cron condrestart 1> /dev/null 2>&1
fi
exit 0
%endif

%if %{yum_makecache_systemd}
%post
%systemd_post yum-makecache.timer

%preun
%systemd_preun yum-makecache.timer

%postun
%systemd_postun_with_restart yum-makecache.timer
%endif

%files -f %{name}.lang
%{!?_licensedir:%global license %%doc}
%license COPYING
%doc README AUTHORS TODO ChangeLog PLUGINS
%if %{move_yum_conf_back}
%config(noreplace) %{_sysconfdir}/yum.conf
%dir %{_sysconfdir}/yum.repos.d
%else
%config(noreplace) %{_sysconfdir}/yum/yum.conf
%dir %{_sysconfdir}/yum/repos.d
%endif
%config(noreplace) %{_sysconfdir}/yum/version-groups.conf
%dir %{_sysconfdir}/yum
%dir %{_sysconfdir}/yum/protected.d
%dir %{_sysconfdir}/yum/fssnap.d
%dir %{_sysconfdir}/yum/vars
%config(noreplace) %{_sysconfdir}/logrotate.d/%{name}
%(dirname %{compdir})
%dir %{_datadir}/yum-cli
%{_datadir}/yum-cli/*
%exclude %{_datadir}/yum-cli/completion-helper.py?
%if %{yum_updatesd}
%exclude %{_datadir}/yum-cli/yumupd.py*
%endif
%{_bindir}/yum-deprecated
%{python2_sitelib}/yum
%{python2_sitelib}/rpmUtils
%dir /var/cache/yum
%dir /var/lib/yum
%ghost /var/lib/yum/uuid
%ghost /var/lib/yum/history
%ghost /var/lib/yum/plugins
%ghost /var/lib/yum/yumdb
%{_mandir}/man*/yum.conf.5
%{_mandir}/man*/yum-deprecated.8
%{_mandir}/man*/yum-shell*
# plugin stuff
%dir %{_sysconfdir}/yum/pluginconf.d 
%dir %{yum_pluginslib}
%dir %{yum_pluginsshare}
%if %{yum_makecache_systemd}
%{_unitdir}/yum-makecache.service
%{_unitdir}/yum-makecache.timer
%endif

%files cron
%{!?_licensedir:%global license %%doc}
%license COPYING
%{_sysconfdir}/cron.daily/0yum-daily.cron
%{_sysconfdir}/cron.hourly/0yum-hourly.cron
%config(noreplace) %{_sysconfdir}/yum/yum-cron.conf
%config(noreplace) %{_sysconfdir}/yum/yum-cron-hourly.conf
%if %{yum_cron_systemd}
%{_unitdir}/yum-cron.service
%else
%{_sysconfdir}/rc.d/init.d/yum-cron
%endif
%{_sbindir}/yum-cron
%{_mandir}/man*/yum-cron.*

%files cron-daily
%{_sysconfdir}/cron.daily/0yum-daily.cron
%config(noreplace) %{_sysconfdir}/yum/yum-cron.conf

%files cron-hourly
%{_sysconfdir}/cron.hourly/0yum-hourly.cron
%config(noreplace) %{_sysconfdir}/yum/yum-cron-hourly.conf

%files cron-security
%{_sysconfdir}/cron.daily/0yum-security.cron
%config(noreplace) %{_sysconfdir}/yum/yum-cron-security.conf

%if %{yum_updatesd}
%files updatesd
%config(noreplace) %{_sysconfdir}/yum/yum-updatesd.conf
%config %{_sysconfdir}/rc.d/init.d/yum-updatesd
%config %{_sysconfdir}/dbus-1/system.d/yum-updatesd.conf
%{_datadir}/yum-cli/yumupd.py*
%{_sbindir}/yum-updatesd
%{_mandir}/man*/yum-updatesd*
%endif

%changelog
* Tue Sep 24 2019 Michael Mraka <michael.mraka@redhat.com> 3.4.3-521.1
- yum rebuild for spacewalkproject.org

* Mon Feb 11 2019 Kevin Fenzi <kevin@scrye.com> - 3.4.3-521
- Fix FTBFS by explicitly using python2. Fixes bug #1606775

* Sun Feb 03 2019 Fedora Release Engineering <releng@fedoraproject.org> - 3.4.3-520
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Sat Jul 14 2018 Fedora Release Engineering <releng@fedoraproject.org> - 3.4.3-519
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Wed May 16 2018 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-518
- Remove dnf-yum dependency for making DNF-3 release possible.

* Wed Feb 14 2018 Iryna Shcherbina <ishcherb@redhat.com> - 3.4.3-517
- Update Python 2 dependency declarations to new packaging standards
  (See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3)

* Fri Feb 09 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 3.4.3-516
- Escape macros in %%changelog

* Thu Aug 17 2017 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-515
-  Really skip all gpg-agent files.

* Thu Aug 17 2017 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-514
- Port to python2-gpg.

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.4.3-513
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Sat Feb 11 2017 Fedora Release Engineering <releng@fedoraproject.org> - 3.4.3-512
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Tue Sep 13 2016 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-511
- Stop requiring python-sqlite.

* Tue Jul 19 2016 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.4.3-510
- https://fedoraproject.org/wiki/Changes/Automatic_Provides_for_Python_RPM_Packages

* Fri Feb 05 2016 Fedora Release Engineering <releng@fedoraproject.org> - 3.4.3-509
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Sun Aug  9 2015 James Antill <james at fedoraproject.org> - 3.4.3-508
- Add weak deps. support.
- Add cashe support for fs diff.

* Fri Jun 19 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.4.3-507
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Wed Apr  8 2015 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-506
- Drop dnf-plugins-extras-migrate requirement.

* Tue Mar 31 2015 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-505
- update to latest HEAD
- Make sure epoch is a string while checking for running kernel. BZ#1200159
- Fix rounding issue in required disk space message.
- Rename yum executable to yum-deprecated.

* Thu Mar 12 2015 James Antill <james at fedoraproject.org> - 3.4.3-157
- Hacky fix for recursion problem with cashe. BZ#1199315

* Wed Mar  4 2015 James Antill <james at fedoraproject.org> - 3.4.3-156
- update to latest HEAD
- Have "yum check" ignore self conflicts.
- Add simple testcase for installing older intermediate kernel. BZ 1063181.
- Don't look for upgrades for install only packages. BZ 1063181.
- check if repos list is empty after excluding disabled repos. BZ 1109473.
- Allow caching local repos. BZ 1125387.
- Expect KB as well as MB in disk requirements message from rpm. BZ 1051931.
- Multiple lvm fixes. BZ 1047793, BZ 1145485.
- Change the sqlite synchronous mode for the history file, to NORMAL.
- Add CAShe config. and objects, use it for MD and packages.
- Add query_install_excludes conf./docs and use it for list/info/search/prov

* Tue Sep 16 2014 James Antill <james at fedoraproject.org> - 3.4.3-155
- update to latest HEAD
- Workaround history searching for [abc] character lists failures. BZ 1096147.
- yumRepos.py - preserve queryparams in urls
- Don't traceback in exRepoError() when repo info is not available. BZ 1114183.
- Make check-update respect --quiet option. BZ 1133979.

* Wed Sep  3 2014 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-154
- update to latest HEAD
- Add armv6hl.
- Fix removing installed obsoleted package. BZ 1135715.

* Wed Aug  6 2014 Tom Callaway <spot@fedoraproject.org> - 3.4.3-153
- fix license handling

* Wed Jun 18 2014 James Antill <james at fedoraproject.org> - 3.4.3-152
- update to latest HEAD
- Workaround the TypeError in _filter_deps(). BZ 1108625

* Mon Jun 16 2014 James Antill <james at fedoraproject.org> - 3.4.3-151
- update to latest HEAD
- Read FS yumvars before yum.conf setup, and reread if installroot changed.
- Call systemd Inhibit, to inhibit shutdowns during transactions. BZ 1109930.
- Have check provides check directly against the rpm index, and then quit.
- Read env vars in readStartupConfig() to make them work in yum.conf. BZ 1102575
- Add rules for naming files in /etc/yum/vars to yum.conf man page.

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.4.3-149
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Wed May 21 2014 James Antill <james at fedoraproject.org> - 3.4.3-148
- update to latest HEAD
- Check /usr for writability before running a transaction.
- Add repo= arguments to almost all RepoError raises, so we don't print unknown.
- Add/fix upgrade-minimal typos from man page.
- Replace vars in include lines in .repo files. BZ 977380.
- Make --setopt handle spaces properly. BZ 1094373
- Fix traceback when the history dir is empty. BZ 875610

* Tue Apr 15 2014 James Antill <james at fedoraproject.org> - 3.4.3-146
- update to latest HEAD
- Fix for weird anaconda C NULL exception traceback. BZ 1058297.
- Add bash completion for fs.
- Fix summary for yum fs command. BZ 1086461.

* Tue Apr  8 2014 James Antill <james at fedoraproject.org> - 3.4.3-145
- update to latest HEAD
- Fix for weird anaconda C NULL exception traceback. BZ 1058297.
- Fix apkgs setup for removing packages. BZ 1019960.
- Fix typo, so we can find the suggests/etc. tables.
- Change 'size' option to 'maxsize' in yum.logrotate. BZ 1005879.
- Mask st_mode to fix verifying permissions for ghost files. BZ 1045415.
- normpath() file URIs. BZ 1009499.

* Tue Mar 25 2014 James Antill <james at fedoraproject.org> - 3.4.3-144
- update to latest HEAD
- Fix dumping xml for suggests/etc.

* Mon Mar 24 2014 James Antill <james at fedoraproject.org> - 3.4.3-143
- update to latest HEAD
- Fix storing objects directly in the yumdb.
- Don't store uuid as var_uuid, or we create it all the time.

* Mon Mar 24 2014 James Antill <james at fedoraproject.org> - 3.4.3-142
- update to latest HEAD
- No error for refilter cleanup, rm dirs. and eat all errors. BZ 1062959.
- Use get_uuid_obj() instead of get_uuid(), to help out ostree.
- Make utils.get_process_info() respect executable names with spaces.
- Fix traceback when history files don't exist and user is not root.

* Mon Mar 10 2014 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-141
- update to latest HEAD
- Fix repo-pkgs check-update not showing any updates.
- Fix ValueError when /var/lib/yum/groups/installed is empty. BZ 971307
- Fix 'yum updateinfo list all new-packages' traceback. BZ 1072945
- Make yum quit when an invalid option is provided with --setopt.

* Sun Feb 23 2014 James Antill <james at fedoraproject.org> - 3.4.3-140
- update to latest HEAD
- Fix yum.conf file saving for filters.

* Fri Feb 21 2014 James Antill <james at fedoraproject.org> - 3.4.3-139
- update to latest HEAD
- Copy packages in/out of an installroot, for no downloads creating containers.
- A few cleanups for the fs sub-command UI.
- Add spec requires for fs sub-command.

* Tue Feb 18 2014 James Antill <james at fedoraproject.org> - 3.4.3-138
- update to latest HEAD
- Workaround for weird mash issue, probably.

* Mon Feb 17 2014 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-137
- update to latest HEAD
- Fix debuginfo-install doLock() traceback. BZ 1062479
- Add 'autoremove' to yum --help output. BZ 1053348

* Fri Feb 14 2014 James Antill <james at fedoraproject.org> - 3.4.3-136
- update to latest HEAD
- Minor fixes/cleanups for yum fs diff.
- Fix update-minimal traceback and ignoring updates. BZ 1048584.

* Wed Feb 12 2014 James Antill <james at fedoraproject.org> - 3.4.3-135
- update to latest HEAD
- Add yum fs sub-command. filter/refilter/refilter-cleanup/du/status/diff.
- Fix a possible "yum history stats" tb. BZ 1059184.
- Use requirement instead of calling string_to_prco_tuple.
- ppc64le is its own arch treat it as such.

* Wed Jan 29 2014 James Antill <james at fedoraproject.org> - 3.4.3-134
- update to latest HEAD
- Add yum-cron to run_with_package_names.
- Don't create lockdir directories, as they are magic now. BZ 975864.
-  Make 'yum install @group' give an error when trying to install a
- non-existent group.
- One more s/ouput/output/ fix
- Cleanup spec for rhel-7 builds.

* Thu Jan 23 2014 James Antill <james at fedoraproject.org> - 3.4.3-133
- update to latest HEAD
- Test for lvm binary before using. BZ 1047793.
- Split cron-daily and cron-hourly into separate packages. Add cron-security.

* Wed Jan 22 2014 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-132
- yum-cron: EmailEmitter failure should not be fatal. BZ 1055042
- yum-cron: Add a retry loop around doLock().
- _set_repos_cache_req(): Handle missing cachedir. BZ 1044080
- repo-pkgs: Fix repoid parsing. BZ 1055132.
- Fix bash completion for 'autoremove'
- downloadonly: unlink .tmp files on ctrl-c. BZ 1045806
- repo-pkgs <repoid> info|list shouldn't require root UID.
- doPackageLists(repoid=<repoid>): filter 2nd ipkg lookup. BZ 1056489

* Thu Jan 16 2014 Ville Skyttä <ville.skytta@iki.fi> - 3.4.3-131
- Drop INSTALL from docs.

* Wed Jan 15 2014 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-130
- update to latest HEAD
- fix "yum --help" with translated "Usage: %%s\n". BZ 1033416
- completion: Fix file/dir completions for names containing spaces or tabs
- Fixed yum.8 manpage formatting. BZ 1050902
- yum-cron: fail on unsigned packages. BZ 1052440
- yum-cron: enable random_sleep by default.

* Tue Jan 7 2014 Valentina Mukhamedzhanova <vmukhame@redhat.com> - 3.4.3-129
- update to latest HEAD
- Skip unavailable repos. BZ 1046076
- docs: yum.conf.5: Fix typo.
- docs: Update --downloadonly section of man page.
- Change emitCheckFailed() to a warning. BZ 1048391

* Thu Dec 19 2013 James Antill <james at fedoraproject.org> - 3.4.3-128
- update to latest HEAD
- Fix for traceback with group info -v.

* Wed Dec 18 2013 James Antill <james at fedoraproject.org> - 3.4.3-127
- update to latest HEAD
- Fix for traceback with installed env. groups with owned groups in info.
- Again, thanks to Adam.

* Wed Dec 18 2013 James Antill <james at fedoraproject.org> - 3.4.3-126
- update to latest HEAD
- Fixes for typo in group remove/install mark messages tests.
- Again, thanks to Adam.

* Tue Dec 17 2013 James Antill <james at fedoraproject.org> - 3.4.3-125
- update to latest HEAD
- Again, lots of groups UI changes/fixes thanks to Adam.
- Add "groups mark blacklist" command to get out of the upgrade problem.
- Tell users how to mark install/remove groups without packages.
- Show install groups as well as upgrading groups in transaction output.
- Fix mark-convert-whitelist, and add mark-convert-blacklist (default).
- Fix typo with simple groups compile of environment with only options.
- Pass the ievgrp to groups for new installed envs., so they belong. BZ 1043231.
- Don't confuse "group info" output by giving data for optional when it's off.

* Tue Dec 17 2013 James Antill <james at fedoraproject.org> - 3.4.3-124
- update to latest HEAD
- Fix group update not trying to install all optional groups of evgrp.

* Mon Dec 16 2013 James Antill <james at fedoraproject.org> - 3.4.3-123
- update to latest HEAD
- Lots of "minor" group changes to hopefully fix a bunch of the bugs. Eg.
- 1043207, 1014202.

* Fri Dec 13 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-122
- update to latest HEAD
- use the same "Total" formatting as urlgrabber.progress
- fix the depsolve_loop_limit=0 case. BZ 1041395
- yum.bash: skip pkglist completion when len(prefix) < 1. BZ 1040033
- yum-cron: stderr/email: no output if no messages. BZ 1018068
- yum-cron: use YumOutput.listTransaction(). BZ 1040109

* Fri Dec  6 2013 James Antill <james at fedoraproject.org> - 3.4.3-121
- Fix cacheReq manipulation overwrite.
- Only look at enabled repos. for cacheReq cookie comparisons. BZ 1039028.
- Add check-update sub-command to repo-pkgs.
- Add command variation aliases to check-update.
- Fix needTs check with repo-pkgs list/info.

* Fri Dec  6 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-120
- Revert the use of float timestamps as it triggers repomd != metalink.

* Wed Dec  4 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-119
- docs only: group_command=objects is the distro default.
- Parse float timestamps as valid, for global timestamp.
- Add check_config_file_age, so we can turn that off for rhsm repos. BZ 103544
- Better doc. comment for re_primary_filename().

* Thu Nov 21 2013 James Antill <james at fedoraproject.org> - 3.4.3-118
- Update to latest HEAD.
- Don't use the provide for distroverpkg if it's the name of the pkg. BZ 1002977.
- Use the provides as-is when we do use it. BZ 1002977.
- Fix the man page formatting for ! explanation in repolist, so it can be read.
- Add deltarpm_metadata_percentage config. so people can configure MD download.

* Tue Nov 19 2013 James Antill <james at fedoraproject.org> - 3.4.3-117
- Update to latest HEAD.
- Fix autocheck_running_kernel config.

* Mon Nov 18 2013 James Antill <james at fedoraproject.org> - 3.4.3-116
- Update to latest HEAD.
- Add installed for groups pkg. lists on transaction output. BZ 1031374.
- Add autocheck_running_kernel config. so people can turn it off.
- Add upgrade_group_objects_upgrade config. so people can turn it off.
- Add distupgrade command as alias for distro-sync, to be compat. with zypper.

* Fri Nov 15 2013 James Antill <james at fedoraproject.org> - 3.4.3-115
- Update to latest HEAD.
- Use makecache systemd timer on f20, maybe use it on f19 too?
- installonlypkgs: remove unneeded provides, add "installonlypkg(kernel)"
- docs: Suggest "--" when using "-<pkg>" to exclude packages. BZ 1026598.
- applydeltarpm: turn fork() failure to MiscError. BZ 1028334.

* Sun Nov 10 2013 James Antill <james at fedoraproject.org> - 3.4.3-114
- Update to latest HEAD.
- Fixup always turning cron/makecache systemd stuff off.
- _readRawRepoFile: return only valid (ini, section_id). BZ 1018795.
- Same-mirror retry on refused connections. Helps BZ 853432.

* Thu Oct 31 2013 James Antill <james at fedoraproject.org> - 3.4.3-113
- Update to latest HEAD.
- Mostly backwards compat. change to how distroverpkg config. works. BZ 1002977.

* Wed Oct 30 2013 James Antill <james at fedoraproject.org> - 3.4.3-112
- Update to latest HEAD.
- Actually run the groups update config. when not in objects mode. BZ 1002439.
- Implement pkg.remote_url for YumLocalPackage. BZ 1016148.
- UpdateNotice.xml(): sanitize pkg['epoch']. BZ 1020540.
- yum-cron: support download/install with update_messages==False. BZ 1018068.
- Fix some bugs in setopt for repo config. entries. BZ 1023595.
- Add loop limit for depsolving. BZ 1017840.
- Add yum-makecache systemd service, force network updates on for better UI.

* Mon Oct  7 2013 James Antill <james at fedoraproject.org> - 3.4.3-111
- Update to latest HEAD.
- More reliable po.localpath file:// URL test. BZ 1004089
- Disable drpms for local repositories. BZ 1007097
- docs: fix formatting of "yum swap" examples. BZ 1009154
- Move disableplugin checks to before we load the conf/module
- Set repo_error.repo attr also when filelists DL fails
- Fix the "repo failed" message
- docs: update "yum check" extra args description. BZ 1014993
- unlink_f(): handle ENOENT, EPERM, EACCES, EROFS. BZ 1015647, BZ 975619

* Fri Sep  6 2013 James Antill <james at fedoraproject.org> - 3.4.3-110
- Update to latest HEAD.
- Add cache check to repolist, using "!". Document repoinfo.
- Add epoch to updateinfo xml output.
- Add missing translation hooks for ignored -c option message.
- Try to smooth out the edge cases for cacheReq not ever updating data.

* Wed Sep  4 2013 James Antill <james at fedoraproject.org> - 3.4.3-109
- Update to latest HEAD.
- update /etc/yum-cron-hourly.conf. BZ 1002623
- Tweak y-c-t and history redo msg. BZ 974576.
- docs: $arch does not map 1:1 to uname(2) arch. BZ 1003554
- checkMD: re-check when xattr matches but size==0. BZ 1002494

* Wed Aug 28 2013 James Antill <james at fedoraproject.org> - 3.4.3-108
- Update to latest HEAD.
- Use new comps. mock objects to re-integrate group removal. BZ 996866.
- Add "weak" comps. groups, for installed groups.
- Add msg. to help users deal with RepoError failures. BZ 867389.
- Give msgs about install/trans. obsoletes a higher priority. BZ 991080.
- waitForLock() raises YumBaseError. BZ 1001154.

* Sun Aug 25 2013 James Antill <james at fedoraproject.org> - 3.4.3-107
- Update to latest HEAD.
- Pass requirement to compare_proviers so we can use provides version compare.
- Show conf. file in yum-cron error message.
- Add mark convert messages.
- Fix logging level regression, -d9 works again.
- Override users umask for groups files, so users can read it. BZ 982361.
- Fix downgrade keeping .reason, note that remove+install doesn't. BZ 961938.
- Inherit reason from install package into txmbr. BZ BZ 961938.

* Tue Aug 13 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-106
- Update to latest HEAD.
- deltarpm: _wait(block=True) should not wait for all running jobs. BZ 991694
- make mdpolicy=group:small default, add group and pkgtags. BZ 989231

* Tue Aug  6 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-105
- Update to latest HEAD.
- yum-cron: smtp-compliant email_from default. BZ 982696
- Add a "--disableincludes" option to yum. BZ 911422
- yum-cron: override the default stdout codec.  BZ 992797
- docs: fix spelling. BZ 991702
- fix file:// repository && downloadonly. BZ 903294, BZ 993567

* Tue Jul 30 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-104
- Update to latest HEAD.
- yum-cron: use [base] section
- yum-cron: fix the download but don't appy updates case. BZ 983076
- group install/update: handle "No Groups Available" exception. BZ 983010
- misc.decompress(): handle OSError, too. BZ 989948

* Thu Jul 18 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-103
- Added debuglevel option to yum-cron.conf BZ 873428, 982088
- RepoMD: support loading/dumping of <delta>s.

* Thu Jul 18 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-102
- Preload from root cache when --cacheonly. BZ 830523, 903631

* Tue Jul 16 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-101
- Update to latest HEAD.
- Get correct rpmdb path from rpm configuration
- repoMDObject.dump_xml() "distro" tag fix
- Fix parsing of power7+ platform string. BZ 980275
- findRepos: handle re.compile() errors. BZ 984356
- updatesObsoletesList: add repoid arg. BZ 984297

* Tue Jul  9 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-100
- Update to latest HEAD.
- Pass arch of package to applydeltarpm. BZ 981314.
- Simple "import sys" fix. BZ 875228
- Clean up new files when reverting to old repomd.xml

* Mon Jun 24 2013 James Antill <james at fedoraproject.org> - 3.4.3-99
- Update to latest HEAD.
- Fix igroups not being reset in "ts reset" and anaconda. BZ 924162.
- Check for bad checksum types at runtime. BZ 902357.
- fix --cacheonly edge case. BZ 975619.

* Wed Jun 19 2013 James Antill <james at fedoraproject.org> - 3.4.3-98
- Update to latest HEAD.
- Add simple way to specify a group of pkgs. for version. BZ 913461.
- Change group install => group upgrade for installed groups. BZ 833087.
- Give more text when telling user about y-c-t, mention history. BZ 974576.
- Fix the tolerant yum.conf text.
- Skip installonly limit, if something has set check_future_rpmdbv. BZ 962757.

* Mon Jun 17 2013 James Antill <james at fedoraproject.org> - 3.4.3-97
- Update to latest HEAD.
- Minor updates to fssnapshot command.
- metalink: Don't assume maxconnections is always set. BZ 974826.
- DeltaPackage: provide returnIdSum(). BZ 974394.

* Fri Jun 14 2013 James Antill <james at fedoraproject.org> - 3.4.3-96
- Update to latest HEAD.
- Add real logging to updateinfo parsing.
- Merge fssnap command.
- Extend repos.findRepos() API so it can handle repolist input.
- Add a prelistenabledrepos plugin point.
- Auto. enable disabled repos. in repo-pkgs.
- Do cacheRequirement() tests before doCheck().

* Fri Jun 14 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-95
- DeltaPackage compat fix. BZ 974394

* Wed Jun 12 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-94
- Update to latest HEAD.
- downloadonly: prefetch also pkg checksums. BZ 973380
- Fix superfluous dots after "via" in man pages. BZ 972764
- support "proxy = libproxy" syntax to enable libproxy. BZ 857263
- checkEnabledRepo: run prereposetup if necessary. BZ 826096

* Mon Jun  3 2013 James Antill <james at fedoraproject.org> - 3.4.3-93
- update to latest HEAD.
- Workaround anaconda passing None as group name. BZ 959710.
- Fix second part of igrp as grp problems. BZ 955236.
- Add a fuzzy matcher for numbers in format_missing_requires. BZ 718245.
- Hide the "downloadonly" option when nothing to download.
- Add the "minrate" option. BZ 964298

* Tue May 21 2013 James Antill <james at fedoraproject.org> - 3.4.3-92
- update to latest HEAD.
- returnPackagesByDep() API fix (really old break).
- Try to make groups conversion better.
- progress.start: supply the default filename & url.  BZ 963023
- drpm retry: add RPM sizes to total size.  BZ 959786
- YumBaseError: safe str(e).  BZ 963698

* Mon May 13 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-91
- same-mirror retry also on timeout.  BZ 853432

* Wed May  8 2013 James Antill <james at fedoraproject.org> - 3.4.3-90
- Massive hack for Fedora/updateinfo stable vs. testing statuses. BZ 960642.
- Don't load updateinfo when we don't have to.
- Tell which repo. we are skipping the updateinfo notice from.
- Compat. code so we can treat groups/igroups the same. BZ 955236.
- Don't highlight the empty space, Eg. --showdups list.

* Thu May  2 2013 Bill Nottingham <notting@redhat.com> - 3.4.3-89
- Fix defaults-for-environment optional groups change. BZ 958531

* Tue Apr 30 2013 James Antill <james at fedoraproject.org> - 3.4.3-88
- update to latest HEAD.
- Allow default on Environment optional groups.
- Tweak load-ts output.

* Fri Apr 26 2013 James Antill <james at fedoraproject.org> - 3.4.3-87
- update to latest HEAD.
- Make --downloadonly skip userconfirm prompt.
- Turn metadata_expire off for yum-cron.
- Skip var_arch storage in yumdb.

* Tue Apr 23 2013 James Antill <james at fedoraproject.org> - 3.4.3-86
- update to latest HEAD.
- A fix for environments and not installed groups. BZ 928859.
- Add downloadonly option to download prompt.

* Fri Apr 19 2013 James Antill <james at fedoraproject.org> - 3.4.3-85
- update to latest HEAD.
- A couple of fixes for yum-cron using security.
- Add documentation for updateinfo merge.

* Thu Apr 18 2013 James Antill <james at fedoraproject.org> - 3.4.3-84
- update to latest HEAD.
- Move yum-security into core.
- A bunch of minor fixes for yum-cron.
- Update yum-cron to add security/minimal/etc. updates.
- Add socks support to proxy config.

* Tue Apr 16 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-83
- update to latest HEAD.
- Update yum-cron to make it worthwhile on Fedora.
- Fix the installed/depinstalled split.  BZ 952162
- rebuilding deltarpms: fix the callback==None case. BZ 952357
- Reuse mirrors when max_retries > len(mirrors).  BZ 765598

* Thu Apr  4 2013 James Antill <james at fedoraproject.org> - 3.4.3-82
- update to latest HEAD.
- Keep installedFileRequires in sync. BZ 920758.
- Add repo-pkgs upgrade-to.
- Document autoremove commands.

* Thu Mar 28 2013 James Antill <james at fedoraproject.org> - 3.4.3-81
- update to latest HEAD.
- Fix optional packages getting installed by default. BZ 923547.
- cacheReq() added to groups command.
- Finally fix the installed obsoletes problem.
- Sync specfiles.
- Turn checking on, and fix check-po script.

* Wed Mar 27 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-80
- package also %%{compdir}'s parent
- set correct dir when bytecompiling /usr/share/yum-cli
- add fast package name completion (disabled by default)

* Wed Mar 20 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-79
- add BuildRequires: bash-completion

* Wed Mar 20 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-78
- update to latest HEAD.
- add bash-completion aliases, use pkg-config.
- spelling fixes

* Tue Mar 19 2013 Zdenek Pavlas <zpavlas@redhat.com> - 3.4.3-77
- move bash-completion scripts to /usr/share/  BZ 922992

* Tue Mar 12 2013 James Antill <james at fedoraproject.org> - 3.4.3-76
- Change groups_command default to objects.
- update to latest HEAD.
- Add timestamp to transaction object for plugins etc.

* Mon Mar 11 2013 James Antill <james at fedoraproject.org> - 3.4.3-75
- update to latest HEAD.
- Fix deltarpm=0.
- Fix double unlink. BZ 919657.

* Fri Mar  8 2013 James Antill <james at fedoraproject.org> - 3.4.3-74
- update to latest HEAD.
- Fix obsoletes in "yum check".
- Drop drpm rebuild defaults back to 2 workers.

* Thu Mar  7 2013 James Antill <james at fedoraproject.org> - 3.4.3-73
- update to latest HEAD.
- Queue for drpm rebuilding.
- Sort drpms.

* Wed Mar  6 2013 James Antill <james at fedoraproject.org> - 3.4.3-72
- update to latest HEAD.
- Translation updates.
- Smarter selection of drpm candidates.
- "makecache fast".
- Minor updates.

* Fri Mar  1 2013 James Antill <james at fedoraproject.org> - 3.4.3-70
- update to latest HEAD.
- Reimport the size calculation fix.

* Thu Feb 28 2013 James Antill <james at fedoraproject.org> - 3.4.3-69
- drpm: Fix getDiscNum() sorting bug. BZ 916675.
- Move to just dumping upstream HEAD again.

* Thu Feb 28 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-67
- drpm: fixed the yum._up==None case.
- drpm: repo_gen_decompress() to handle all comp types.

* Wed Feb 27 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-66
- fixed getDiscNum bug
- fixed rpmsize calculation
- obsoleted yum-presto plugin

* Tue Feb 26 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-65
- start downloading drpms before rpms
- deactivate presto if deltarpm package is not installed
- rename "presto" option to "deltarpm".
- new DeltaPO class instead of in-place rpm=>drpm patching.

* Fri Feb 22 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-64
- use multiple applydeltarpm workers (4 by default)

* Thu Feb 21 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-63
- Added native drpm support.

* Tue Feb 19 2013 James Antill <james at fedoraproject.org> - 3.4.3-62
- update to latest HEAD.
- Add cache-reqs.
- Fixup specfile for Fedora <= 18 usage.

* Mon Feb 18 2013 James Antill <james at fedoraproject.org> - 3.4.3-60
- update to latest HEAD.
- Auto expire caches on repo errors.
- Use xattrs for cache checksum speedup.

* Fri Feb 15 2013 James Antill <james at fedoraproject.org> - 3.4.3-59
- update to latest HEAD.
- Add load-ts helper.
- Update downloadonly plugin version obs.

* Fri Feb  8 2013 James Antill <james at fedoraproject.org> - 3.4.3-58
- update to latest HEAD.
- Add pyxattr require for origin_urls for everyone.
- Fix yum-cron service file and scriptlets.
- Fix instant broken mirrors problem.

* Thu Jan 31 2013 James Antill <james at fedoraproject.org> - 3.4.3-57
- update to latest HEAD.
- Fix autoremove foo.
- Speedup/fix repo-pkgs <foo> update with obsoletes.

* Wed Jan 30 2013 James Antill <james at fedoraproject.org> - 3.4.3-56
- update to latest HEAD.
- Add yumvar dumping into yumdb.
- Add ui_repoid_vars configuration.
- Update translations.

* Tue Jan 22 2013 James Antill <james at fedoraproject.org> - 3.4.3-55
- update to latest HEAD.
- Add repo-pkgs update/list and tweak remove-or-sync.

* Mon Jan 21 2013 James Antill <james at fedoraproject.org> - 3.4.3-54
- update to latest HEAD.
- Add repo-pkgs docs. add erase/etc. aliases.
- Fix for 895854.

* Wed Jan 16 2013 James Antill <james at fedoraproject.org> - 3.4.3-53
- update to latest HEAD.
- Add repo-pkgs.
- Add swap.
- Add remove_leaf_only and repopkgremove_leaf_only.
- Add metadata_expire_filter.

* Tue Jan 15 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-52
- update to latest HEAD
- _lock(): yet another exception2msg fix.  BZ 895060
- use yum-cron.service.  BZ 893593
- YumRepo.populate(): always decompresses new database

* Wed Jan  9 2013 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-51
- update to latest HEAD
- Include langpacks when reading and writing comps. BZ 879030
- selectGroup(): Fix a typo. BZ 885139
- move the basename checking into _repos.doSetup(). BZ 885159
- bash completion: offer nvra for multi-install packages
- fixes extra '</pkglist>' tags on multi-collection errata. BZ 887407
- Include the update date in updateinfo xml. BZ 887935
- Complete provides/whatprovides with filenames. BZ 891561
- New locking code.  BZ 865601

* Thu Dec 06 2012 Zdeněk Pavlas <zpavlas@redhat.com> - 3.4.3-50
- update to latest HEAD.
- Check for possible inf. recursion and workaround in skip-broken. BZ 874065
- Don't error in history list, when we have no history. BZ 802462
- Avoid converting to unicode and back in dump_xml_*.  BZ 716235
- po.xml_dump_{primary,filelists,other}_metadata() cleanup

* Wed Nov 28 2012 Zdenek Pavlas  <zpavlas@redhat.com> - 3.4.3-49
- update to latest HEAD.
- Fix ugly paths in po.xml_dump_*(). BZ 835565.
- Fix yum-cron requires.

* Mon Nov 19 2012 Zdenek Pavlas  <zpavlas@redhat.com> - 3.4.3-48
- update to latest HEAD.
- add skip-broken option to yum-cron.
- get rid of bogus "Downloaded package .. but it was invalid."
- clean up misc.to_xml(), make it faster.  BZ 716235.
- checksum not available implies checksum does not match.  BZ 825272.
- avoid checksumming existing .sqlite.bz2 files.
- fix circular obsoletes in transaction members check. BZ 868840.

* Thu Oct 25 2012 Zdenek Pavlas  <zpavlas@redhat.com> - 3.4.3-47
- replaced yum-cron.sh with the new yum-cron.py (very alpha)

* Thu Oct 25 2012 Nils Philippsen <nils@redhat.com> - 3.4.3-46
- bump release to ensure upgrade path and satisfy PackageKit deps

* Wed Oct 17 2012 James Antill <james at fedoraproject.org> - 3.4.3-44
- update to latest HEAD.
- Add downloadonly into core, and enable background downloads.
- Lots of minor fixes.

* Fri Sep  7 2012 James Antill <james at fedoraproject.org> - 3.4.3-43
- update to latest HEAD.
- Use .ui_id explicitly for backcompat. on strings, *sigh*.

* Sat Sep  1 2012 James Antill <james at fedoraproject.org> - 3.4.3-42
- update to latest HEAD.
- Fix missing self. on last patch.

* Fri Aug 31 2012 James Antill <james at fedoraproject.org> - 3.4.3-41
- update to latest HEAD.
- Don't statvfs when we aren't going to copy, and using relative.

* Thu Aug 30 2012 James Antill <james at fedoraproject.org> - 3.4.3-40
- update to latest HEAD.
- Fix rel-eng problems when repo.repofile is None.
- Don't statvfs when we aren't going to copy.

* Tue Aug 28 2012 James Antill <james at fedoraproject.org> - 3.4.3-36
- update to latest HEAD.
- Fix environment groups write.
- Allow merging of updateinfo.
- Add releasever/arch to repoids on output, if used in urls.
- Merge mirror errors fix.

* Thu Aug 23 2012 Zdenek Pavlas <zpavlas at redhat.com> - 3.4.3-34
- Some users skip setupProgressCallbacks(). BZ 850913.

* Wed Aug 22 2012 Zdenek Pavlas <zpavlas at redhat.com> - 3.4.3-33
- update to latest HEAD.
- Set multi_progress_obj option
- Show full URLs and mirror errors when _getFile() fails.

* Thu Aug 16 2012 James Antill <james at fedoraproject.org> - 3.4.3-32
- update to latest HEAD.
- Some fixes for new environment groups.
- Fix "yum upgrade" download verification. BZ 848811.

* Fri Aug 10 2012 James Antill <james at fedoraproject.org> - 3.4.3-31
- update to latest HEAD.
- Big update, mostly for "environment groups".

* Sun Jul 22 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.4.3-30
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Wed Jun 20 2012 Zdenek Pavlas <zpavlas at redhat.com> - 3.4.3-29
- update to latest HEAD.
- quote uids to keep cachedir ascii-clean.  BZ 832195
- show_lock_owner: report errors if we fail.  BZ 745281

* Thu Jun 14 2012 Zdenek Pavlas <zpavlas at redhat.com> - 3.4.3-28
- update to latest HEAD.
- No async downloading when --cacheonly.  BZ 830523
- misc.decompress(): compare mtime without sub second precision. BZ 831918
- preload_from_sys to user dir with --cacheonly, BZ 830523

* Fri Jun  8 2012 James Antill <james at fedoraproject.org> - 3.4.3-27
- update to latest HEAD.
- Fix for ppc64p7 detection.

* Wed May 16 2012 Zdenek Pavlas <zpavlas at redhat.com> - 3.4.3-26
- update to latest master HEAD
- Fix using available packages as installed, due to strong_requires.
- Remove tracebacks on MD downloads. BZ 822009.

* Mon May 14 2012 Zdenek Pavlas <zpavlas at redhat.com> - 3.4.3-25
- update to latest HEAD.
- merged multi-downloader code
- rebased yum-ppc64-preferred.patch
- dropped arm-arch-detection.patch (moved to HEAD)
- renamed yum-update.cron to 0yum-update.cron

* Fri Apr 27 2012 James Antill <james at fedoraproject.org> - 3.4.3-24
- Add code for arm detection.

* Fri Mar 16 2012 James Antill <james at fedoraproject.org> - 3.4.3-23
- update to latest HEAD.
- Also fix "yum check" for strong requires. bug 795907.
- Fix for "Only update available" on downgrade. bug 803346.

* Fri Mar  9 2012 James Antill <james at fedoraproject.org> - 3.4.3-22
- update to latest HEAD.
- Fail on bad reinstall/downgrade arguments. bug 800285.
- Fix weird multiple obsoletion bug. BZ 800016
- Check for a compat. arch. as well, when hand testing for upgradability.
- Allow changing the exit code on non-fatal errors.

* Thu Mar  1 2012 James Antill <james at fedoraproject.org> - 3.4.3-21
- update to latest HEAD.
- Translation update.

* Wed Feb 29 2012 James Antill <james at fedoraproject.org> - 3.4.3-20
- update to latest HEAD.
- Lazy setup pkgSack, for localinstall/etc.
- add support for 64 bit arm hardware.
- Hack for "info install blah" to never look at repos.
- Fixup resolvedep command for mock users.

* Mon Feb 20 2012 James Antill <james at fedoraproject.org> - 3.4.3-19
- update to latest HEAD.
- Add a yum group convert command, so people can use groups as objects easily.
- Document the new group stuff.
- Generic provide markers for installonlypkgs (for kernel/vms).
- Minor updates/fixes merge some older branches.

* Fri Jan 20 2012 James Antill <james at fedoraproject.org> - 3.4.3-18
- update to latest HEAD
- Added group_command, but didn't change to groups as objects by default.
- Minor updates.

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.4.3-17
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Dec 13 2011 James Antill <james at fedoraproject.org> - 3.4.3-16
- update to latest HEAD
- Have users always use their own dirs.
- Minor updates.

* Fri Dec  2 2011 James Antill <james at fedoraproject.org> - 3.4.3-15
- update to latest HEAD
- Init "found" variable for distro-sync full. BZ 752407.
- Fix _conv_pkg_state when calling with history as checksum. BZ 757736.
- When a repo. fails in repolist, manually populate the ones after it.A
- Fix a corner case in exception2msg(). BZ 749239.
- Transifex sync.
- Hand fix the plural forms gettext stuff.

* Wed Nov 30 2011 Dennis Gilmore <dennis@ausil.us> - 3.4.3-13
- add patch from upstream for arm hardware floating point support

* Mon Oct 17 2011 James Antill <james at fedoraproject.org> - 3.4.3-12
- update to latest HEAD
- Basically just an update for transifex sync.

* Fri Oct 14 2011 James Antill <james at fedoraproject.org> - 3.4.3-11
- update to latest HEAD
- Some edge case depsolver bug fixes.
- Output the GPG fingerprint when showing the GPG key.
- Update bugtracker URL back to redhat.
- Allow reinstall and remove arguments to history redo command.
- Let resolvedep look for installed packages.

* Wed Sep 21 2011 James Antill <james at fedoraproject.org> - 3.4.3-10
- update to latest HEAD
- Fix for history sync, and saving on install.
- Lots of minor bug fixes.
- Speedups for upgrade_requirements_on_install=true.
- Fix generated data using bad caches.
- Changes for yum-cron.

* Tue Aug 23 2011 James Antill <james at fedoraproject.org> - 3.4.3-9
- update to latest HEAD
- Update translations.
- Minor UI tweaks for transaction output.
- Minor tweak for update_reqs_on_install.

* Mon Aug 22 2011 James Antill <james at fedoraproject.org> - 3.4.3-8
- update to latest HEAD
- Fix upgrade_requirements_on_install breaking upgrade typos.

* Fri Aug 19 2011 James Antill <james at fedoraproject.org> - 3.4.3-7
- update to latest HEAD
- Fix syncing of yum DB data in history.
- Add upgrade_requirements_on_install config. option.
- Don't look for releasever if it's set directly (anaconda).
- Expose ip_resolve urlgrabber option.

* Fri Aug  5 2011 James Antill <james at fedoraproject.org> - 3.4.3-6
- update to latest HEAD
- Add new yum DB data.
- Add hack to workaround broken python readline in yum shell.
- Make "yum -q history addon-info last saved_tx" valid input for load-ts.
- Add "history packages-info/stats/sync" sub-commnands.

* Fri Jul 29 2011 James Antill <james at fedoraproject.org> - 3.4.3-5
- update to latest HEAD
- Lots of really minor changes. Docs. and yum-cron mainly.
- Output yum_saved_tx file.

* Fri Jul 15 2011 James Antill <james at fedoraproject.org> - 3.4.3-4
- update to latest HEAD
- Weird old bugs fixed for new createrepo code.
- Add --assumeno and an easter egg! Also allow remove to use alwaysprompt.
- Fix \r appearing on serial console etc. BZ 720088.
- Fix umask on mkdir() as well as open. BZ 719467.
- Fix traceback when enabling/disabling repos. in GUI.

* Thu Jun 30 2011 James Antill <james at fedoraproject.org> - 3.4.3-3
- Fix the skip broken tuples => dict. bug. BZ 717973.

* Wed Jun 29 2011 James Antill <james at fedoraproject.org> - 3.4.3-2
- Add ppc64 arch. change for BZ 713791.

* Tue Jun 28 2011 James Antill <james at fedoraproject.org> - 3.4.3-1
- update to 3.4.3
- Real upstream workaround for rpm chroot and history insanity.
- Minor bugfixes.

* Wed Jun 22 2011 James Antill <james at fedoraproject.org> - 3.4.2-2
- Workaround rpm chroot insanity.

* Wed Jun 22 2011 James Antill <james at fedoraproject.org> - 3.4.2-1
- update to 3.4.2
- Lots of smallish bug fixes/tweaks.
- Lookup erase transaction members, by their name, if we can.
- Added pluralized translation messages.

* Tue Jun 14 2011 James Antill <james at fedoraproject.org> - 3.4.1-5
- update to latest HEAD
- Lots of smallish bug fixes.
- New groups command.

* Thu Jun  2 2011 James Antill <james at fedoraproject.org> - 3.4.1-4
- update to latest HEAD
- Fix RepoStorage problem for pulp.
- Add list of not found packages.
- Minor bug fixes.

* Tue May 24 2011 James Antill <james at fedoraproject.org> - 3.4.1-3
- update to latest HEAD
- Tweak "yum provides"
- Don't access the repos. for saved_tx, if doing a removal.
- Fix a couple of old minor bugs:
- Remove usage of INFO_* from yumcommands, as -q supresses that. BZ 689241.
- Don't show depsolve failure messages for non-depsolving problems. BZ 597336.

* Wed May  4 2011 James Antill <james at fedoraproject.org> - 3.4.1-2
- update to latest HEAD
- Fix consolidate_libc.
- Update translations.
- Add history rollback.

* Wed Apr 20 2011 James Antill <james at fedoraproject.org> - 3.4.1-1
- Fix umask override.
- Remove double baseurl display, BZ 697885.

* Fri Apr 15 2011 James Antill <james at fedoraproject.org> - 3.4.0-1
- update to 3.4.0.

* Fri Apr  8 2011 James Antill <james at fedoraproject.org> - 3.2.29-10
- update to latest HEAD 
- Likely last HEAD before 3.2.30.

* Fri Mar 25 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-9
- update to latest HEAD 

* Mon Feb 28 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-8
- take out the hack-patch from 2 weeks ago.

* Mon Feb 28 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-7
- latest head including all of Panu's rpmutils/callback patches

* Thu Feb 17 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-6
- add rpmutils-recursive-import.patch to work around recursive import problems

* Wed Feb 16 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-5
- lots of hopefully NOT exciting changes to rpmutils/rpmsack from head.

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 3.2.29-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Tue Jan 25 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-3
- latest from head - fixing a number of minor bugs

* Thu Jan 13 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-2
- grumble broken skip-broken test :(


* Thu Jan 13 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.29-1
- 3.2.29
- add yum-cron subpkg

* Thu Jan  6 2011 James Antill <james at fedoraproject.org> - 3.2.28-17
- Allow kernel installs with multilib protection ... oops!
- Don't conflict with fixed versions of Zif.
- Add locks for non-root.

* Tue Jan  4 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-16
- fix skip-broken conflict - thanks dgilmore for the catch

* Tue Jan  4 2011 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-15
- latest head
- conflicts zif

* Thu Nov 11 2010 James Antill <james at fedoraproject.org> - 3.2.28-14
- latest head
- Perf. fixes/improvements.

* Tue Nov  9 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-13
- once again with head

* Fri Nov  5 2010 James Antill <james at fedoraproject.org> - 3.2.28-12
- latest head
- Add load-ts command.
- Fix verifying symlinks.

* Wed Oct 20 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-11
- latest head
- depsolve enhancements on update/obsoletes
- show recent pkgs in history package-list instead of a specific pkg
- bz: 644432, 644265
- make sure urlgrabber is using the right config settings for fetching gpg keys


* Fri Oct 15 2010 James Antill <james at fedoraproject.org> - 3.2.28-10
- latest head 
- Fix major breakage from the "list updates" speedup :).
- Close curl/urlgrabber after downloading packages.
- Allow remove+update in "yum shell".
- Fix output of distro tags.

* Thu Oct  7 2010 James Antill <james at fedoraproject.org> - 3.2.28-9
- latest head 
- Add localpkg_gpgcheck option.
- Speedup "list updates"
- Doc fixes.

* Sat Sep 25 2010 James Antill <james at fedoraproject.org> - 3.2.28-8
- latest head 
- Speedup install/remove/etc a lot.
- Add merged history.
- Fix unique comps/pkgtags leftovers.

* Tue Sep 14 2010 James Antill <james at fedoraproject.org> - 3.2.28-7
- latest head 
- Fix PK/auto-close GPG import bug.
- Fix patch for installonly_limit and enable it again.
- Fix rpmlint warnings.
- Remove color=never config.

* Fri Sep 10 2010 Seth Vidal <skvidal at fedoraproject.org>
- latest head 

* Fri Aug 27 2010 Seth Vidal <skvidal at fedoraproject.org>
- obsoleted yum-plugin-download-order

* Thu Aug 12 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-3
- latest head
- fix gpg key import
- more unicode fixes
- output slightly more clear depsovling error msgs

* Mon Aug  9 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-2
- latest head
- unicide fixes
- sqlite history db conversion fixes


* Fri Jul 30 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.28-1
- 3.2.28


* Wed Jul 28 2010 Mamoru Tasaka <mtasaka@ioa.s.u-tokyo.ac.jp> - 3.2.27-21
- Again rebuild against python 2.7

* Mon Jul 26 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-20
- latest head
- minor fixes and doc updates
- hardlink yumdb files to conserve spacde
- cache yumdb results

* Thu Jul 22 2010 David Malcolm <dmalcolm@redhat.com> - 3.2.27-19
- Rebuilt for https://fedoraproject.org/wiki/Features/Python_2.7/MassRebuild

* Fri Jul 16 2010 James Antill <james@fedoraproject.org> - 3.2.27-18
- Latest head.
- Add history addon-info.
- Add new callbacks, verify and compare_providers.
- Fix rpm transaction fail API break, probably only for anaconda.
- Bug fixes.

* Fri Jun 25 2010 James Antill <james@fedoraproject.org> - 3.2.27-17
- Latest head.
- Allow reinstalls of kernel, etc.
- Tweaks to some user output.
- Allow Fedora GPG keys to be removed.
- Add history extra data API, and history plugin hooks.
- Bunch of minor bug fixes.

* Tue Jun 15 2010 James Antill <james@fedoraproject.org> - 3.2.27-16
- Latest head.
- Fix install being recorded as reinstall.
- Make localinstall not install obsoleted only by installed.
- Fix info -v, on available packages.
- Fix man page stuff.
- Deal with unicide on rpmdb problems.
- Allow ipkg.repo.name to work.
- Add ville's epoch None vs. 0 code, in compareEVR.

* Fri Jun 11 2010 James Antill <james@fedoraproject.org> - 3.2.27-15
- Latest head.
- Add filtering requires code for createrepo.
- Add installed_by/changed_by yumdb values.
- Tweak output for install/reinstall/downgrade callbacks.
- Add plugin hooks for pre/post verifytrans.
- Deal with local pkgs. which only obsolete.
- No chain removals on downgrade.
- Bunch of speedups for "list installed blah", and "remove blah".

* Wed Jun  2 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-14
- merge in latest yum head:
- change decompressors to support lzma, if python module is available
- finnish translation fixes
- pyint vs pylong fix for formatRequire() so we stop spitting back the wrong requires strings to mock on newish rpm
- add exit_on_lock option
- Deal with RHEL-5 loginuid damage
- Fix pkgs. that are excluded after being put in yb.up ... BZ#597853
- Opt. for rpmdb.returnPackages(patterns=...). Drops about 30%% from remove time.
- Fix "remove name-version", really minor API bug before last patch

* Wed May 26 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-13
- minor cleanups for yum-utils with --setopt
- translation updates

* Thu May 13 2010 James Antill <james@fedoraproject.org> - 3.2.27-12
- Latest head.
- History db version 2
- Some bug fixes
- More paranoid/leanient with rpmdb cache problems.

* Wed May  5 2010 James Antill <james@fedoraproject.org> - 3.2.27-11
- Fix from head for mock, mtime=>ctime due to caches and fixed installroot
- Fix for typo in new problems code, bug 589008

* Mon May  3 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-10
- latest head
- fixes yum chroot path duplication
- yum.log perms

* Thu Apr 29 2010 James Antill <james@fedoraproject.org> - 3.2.27-9
- Latest yum-3_2_X head.
- Added protect packages.
- Bug fixes from the yum bug day.
- Added removed size output.
- Added glob: to all list config. options.
- Fix fsvars.

* Thu Apr 22 2010 James Antill <james@fedoraproject.org> - 3.2.27-8
- Latest yum-3_2_X head.
- Add deselections.
- Add simple depsolve into compare_providers
- Speedup distro-sync blah.

* Fri Apr 16 2010 James Antill <james@fedoraproject.org> - 3.2.27-7
- Latest yum-3_2_X head.
- Add the "big update" speedup patch.
- Add nocontexts ts flag.
- Add provides and obsoleted to "yum check".
- Add new dump_xml stuff for createrepo/modifyrepo.
- Move /var/lib/yum/vars to /etc/yum/vars

* Mon Apr 12 2010 James Antill <james@fedoraproject.org> - 3.2.27-6
- Latest yum-3_2_X head.
- Fix the caching changes.

* Sat Apr 10 2010 James Antill <james@fedoraproject.org> - 3.2.27-5
- Latest yum-3_2_X head.
- Remove the broken assert in sqlitesack

* Thu Apr  8 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-4
- more latest headness

* Fri Mar 26 2010 James Antill <james@fedoraproject.org> - 3.2.27-3
- Latest yum-3_2_X head.

* Tue Mar 23 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-2
- broke searching in PK, this patch fixes it.

* Thu Mar 18 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.27-1
- 3.2.27 from upstream (more or less the same as 3.2.26-6 but with a new number

* Thu Mar 11 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.26-6
- should be the final HEAD update before 3.2.27

* Wed Feb 24 2010 James Antill <james@fedoraproject.org> - 3.2.26-5
- new HEAD, minor features and speed.

* Wed Feb 17 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.26-4
- new HEAD to fix the fix to the fix

* Tue Feb 16 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.26-3
- latest head - including fixes to searchPrcos

* Wed Feb 10 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.26-2
- grumble.

* Tue Feb  9 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.26-1
- final 3.2.26

* Mon Feb  8 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.25-14
- $uuid, pkgtags searching, latest HEAD patch - pre 3.2.26

* Thu Jan 28 2010 James Antill <james at fedoraproject.org> - 3.2.25-13
- A couple of bugfixes, most notably:
-  you can now install gpg keys again!
-  bad installed file requires don't get cached.

* Fri Jan 22 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.25-12
- someone forgot to push their changes

* Fri Jan 22 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.25-11
- more fixes, more fun

* Fri Jan 15 2010 James Antill <james at fedoraproject.org> - 3.2.25-10
- latest head
- Fixes for pungi, rpmdb caching and kernel-PAE-devel duplicates finding
- among others.

* Mon Jan  4 2010 Seth Vidal <skvidal at fedoraproject.org> - 3.2.25-8
- latest head
