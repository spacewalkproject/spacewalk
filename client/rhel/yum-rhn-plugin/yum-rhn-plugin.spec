Summary: Spacewalk support for yum
Name: yum-rhn-plugin
Version: 2.1.6
Release: 1%{?dist}
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
%if %{?suse_version: %{suse_version} > 1110} %{!?suse_version:1}
BuildArch: noarch
%endif
BuildRequires: python
BuildRequires: intltool
BuildRequires: gettext

Requires: yum >= 3.2.19-15
Requires: rhn-client-tools >= 1.10.3-1
Requires: m2crypto >= 0.16-6
Requires: python-iniparse

# Not really, but for upgrades we need these
Requires: rhn-setup
Obsoletes: up2date < 5.0.0
Provides: up2date = 5.0.0

%description
This yum plugin provides support for yum to access a Spacewalk server for
software updates.

%prep
%setup -q

%build
make -f Makefile.yum-rhn-plugin

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.yum-rhn-plugin install VERSION=%{version}-%{release} PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir} 

%find_lang %{name}

%clean
rm -rf $RPM_BUILD_ROOT

%pre
# 682820 - re-enable yum-rhn-plugin after package upgrade if the system is already registered
export pluginconf='/etc/yum/pluginconf.d/rhnplugin.conf'
if [ $1 -gt 1 ] && [ -f /etc/sysconfig/rhn/systemid ] && [ -f "$pluginconf" ]; then
    if grep -q '^[[:space:]]*enabled[[:space:]]*=[[:space:]]*1[[:space:]]*$' \
       "$pluginconf"; then
        touch /var/tmp/enable-yum-rhn-plugin
    fi
fi

%post
# 682820 - re-enable yum-rhn-plugin after package upgrade if the system is already registered
export pluginconf='/etc/yum/pluginconf.d/rhnplugin.conf'
if [ $1 -gt 1 ] && [ -f "$pluginconf" ] && [ -f "/var/tmp/enable-yum-rhn-plugin" ]; then
    sed -i '/\[main]/,/^$/{/enabled/s/0/1/}' "$pluginconf"
    rm -f /var/tmp/enable-yum-rhn-plugin
fi

%files -f %{name}.lang
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/yum/pluginconf.d/rhnplugin.conf
%dir /var/lib/up2date
%{_mandir}/man*/*
%{_datadir}/yum-plugins/*
%{_datadir}/rhn/actions/*
%doc LICENSE

%changelog
* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.6-1
- Update .po and .pot files for yum-rhn-plugin.

* Thu Oct 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.5-1
- 1018929 - removed redundant exception

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- removed trailing whitespaces

* Mon Sep 09 2013 Stephen Herr <sherr@redhat.com> 2.1.3-1
- 1006037 - keep yum-rhn-plugins higher default timeout

* Tue Aug 13 2013 Stephen Herr <sherr@redhat.com> 2.1.2-1
- 996761 - package profile sync actions should not fail with empty transaction

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in client dir
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- Update .po and .pot files for yum-rhn-plugin.

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.4-1
- rebranding few more strings in client stuff

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.3-1
- rebranding RHN Proxy to Red Hat Proxy in client stuff
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.2-1
- branding clean-up of rhel client stuff

* Wed Apr 03 2013 Stephen Herr <sherr@redhat.com> 1.10.1-1
- 947639 - Make timeout of yum-rhn-plugin calls through rhn-client-tools
  configurable
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.4-1
- Update .po and .pot files for yum-rhn-plugin.
- New translations from Transifex for yum-rhn-plugin.
- Download translations from Transifex for yum-rhn-plugin.

* Mon Feb 04 2013 Jan Pazdziora 1.9.3-1
- 529923 - register package name in config_hook

* Fri Nov 30 2012 Jan Pazdziora 1.9.2-1
- Revert "876328 - updating rhel client tools translations"

* Fri Nov 16 2012 Jan Pazdziora 1.9.1-1
- 876328 - updating rhel client tools translations

* Tue Oct 30 2012 Jan Pazdziora 1.8.8-1
- Update the copyright year.
- Update .po and .pot files for yum-rhn-plugin.
- New translations from Transifex for yum-rhn-plugin.
- Download translations from Transifex for yum-rhn-plugin.

* Tue Oct 09 2012 Jan Pazdziora 1.8.7-1
- 863997 - set correct exit code for check-update in case of error

* Fri Sep 21 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.6-1
- force metadata update if they differ from version on server

* Tue Jul 24 2012 Jan Pazdziora 1.8.5-1
- 842396 - Fixed legacy typo

* Mon Jul 23 2012 Stephen Herr <sherr@redhat.com> 1.8.4-1
- 842396 - Updated yum info messages to play nice with Subscription Management

* Tue Jul 10 2012 Stephen Herr <sherr@redhat.com> 1.8.3-1
- 839052 - yum-rhn-plugin honors yum timeout value

* Thu Jun 21 2012 Jan Pazdziora 1.8.2-1
- fix files headers. our code is under gplv2 license
- %%defattr is not needed since rpm 4.4

* Wed May 02 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.8.1-1
- 817567 - fix reports for auto-errata application already installed

* Tue Feb 28 2012 Jan Pazdziora 1.7.2-1
- Update .po and .pot files for yum-rhn-plugin.
- Download translations from Transifex for yum-rhn-plugin.

* Tue Feb 14 2012 Miroslav Suchý 1.7.1-1
- 788903 - do not change "enable" outside of [main]
- Bumping package versions for 1.7.

* Wed Dec 21 2011 Miroslav Suchý 1.6.16-1
- 759786 - wrap SSL.SysCallError in yum error

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.15-1
- updated translations

* Fri Oct 21 2011 Jan Pazdziora 1.6.14-1
- When only package name is specified (like in Activation Key -> Packages),
  only search installed by package name.

* Tue Oct 18 2011 Miroslav Suchý 1.6.13-1
- move errata.py action to the yum-rhn-plugin package (iartarisi@suse.cz)

* Fri Oct 07 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.12-1
- pass error messages from yum plugin to rhn_check

* Tue Sep 13 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.11-1
- 735339 - truncate rhnplugin.repos when there are no rhn channels

* Mon Sep 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.10-1
- 734492, 734965, 735282 - check command line options only for yum

* Fri Aug 12 2011 Miroslav Suchý 1.6.9-1
- do not verify md5, size and mtime for /etc/yum/pluginconf.d/rhnplugin.conf

* Thu Aug 11 2011 Miroslav Suchý 1.6.8-1
- do not mask original error by raise in execption

* Fri Aug 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.7-1
- parse commandline on our own

* Thu Aug 04 2011 Miroslav Suchý 1.6.6-1
- 690616 - fail to rollback if target package is not available

* Thu Aug 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.5-1
- the latest yum-rhn-plugin and rhn-client-tools require each other

* Thu Aug 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.4-1
- 710065 - exception messages are in unicode

* Tue Aug 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.3-1
- fixed package exclusion
- 725496 - respect default plugin settings from [main]

* Tue Aug 02 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.2-1
- 701189 - make sure cachedir exists

* Mon Aug 01 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.1-1
- call conduit.getConf() only once
- 691283 - create persistdir in _repos_persistdir instead of PWD
- 684342 - beside repo.id, cache even repo.name
- disable network in cache only mode
- cache list of last seen channels so we can correctly clean them
- 627525 - disable network communication with certain commands/options
- reverted init_hook -> prereposetup_hook move
- Bumping package versions for 1.6.

* Tue Jul 19 2011 Jan Pazdziora 1.5.11-1
- Merging Transifex changes for yum-rhn-plugin.
- New translations from Transifex for yum-rhn-plugin.
- Download translations from Transifex for yum-rhn-plugin.

* Tue Jul 19 2011 Jan Pazdziora 1.5.10-1
- update .po and .pot files for yum-rhn-plugin

* Mon Jul 18 2011 Simon Lukasik <slukasik@redhat.com> 1.5.9-1
- 703169 - Search for cached repomd.xml in a correct path (slukasik@redhat.com)

* Tue Jul 12 2011 Jan Pazdziora 1.5.8-1
- Fixing sloppy coding.

* Tue Jun 28 2011 Miroslav Suchý 1.5.7-1
- 707241 - create progressbar even during groupinstall and do not delete
  rhnplugin.repos during groupinstall command (msuchy@redhat.com)

* Mon May 02 2011 Miroslav Suchý 1.5.6-1
- set proxy_dict only if we have some proxy
- proxy_dict is private attribute

* Fri Apr 29 2011 Miroslav Suchý 1.5.5-1
- code cleanup
- 691283 - create persistdir in _repos_persistdir instead of PWD
  (msuchy@redhat.com)

* Thu Apr 21 2011 Miroslav Suchý 1.5.4-1
- in rhel5 http_header is not present

* Wed Apr 20 2011 Miroslav Suchý 1.5.3-1
- rhel5 does not have _default_grabopts()

* Tue Apr 12 2011 Miroslav Suchý 1.5.2-1
- remove duplicate keyword (msuchy@redhat.com)

* Tue Apr 12 2011 Miroslav Suchý 1.5.1-1
- remove dead code
- use default headers from yum class YumRepository
- 690190 - yumdownloader set callbacks soon, save it to new repo
- Bumping package versions for 1.5

* Fri Apr 08 2011 Miroslav Suchý 1.4.15-1
- fix cs translation (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 1.4.14-1
- update copyright years (msuchy@redhat.com)
- download spacewalk.yum-rhn-plugin from Transifex (msuchy@redhat.com)

* Wed Apr 06 2011 Simon Lukasik <slukasik@redhat.com> 1.4.13-1
- Removing packages.verifyAll capability; it was never used.
  (slukasik@redhat.com)
- Moving unit test for touchTimeStamp() which was moved to yum-rhn-plugin
  (slukasik@redhat.com)

* Wed Apr 06 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.12-1
- there're no opts when called from rhn_check

* Mon Apr 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.11-1
- 688870 - resolve --enablerepo/--disablerepo for RHN repos

* Fri Apr 01 2011 Miroslav Suchý 1.4.10-1
- 690234 - do not re-create repo if it exist and is type of RhnRepo

* Fri Apr 01 2011 Miroslav Suchý 1.4.9-1
- name of attribute have to be in apostrophe

* Wed Mar 30 2011 Miroslav Suchý 1.4.8-1
- 683200 - ssl cert can not be unicode string
- fix variable typo
- older yum do not have _repos_persistdir

* Wed Mar 30 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.7-1
- 683200 - support IDN

* Thu Mar 24 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.6-1
- 688870 - also check whether cached repo is valid

* Wed Mar 23 2011 Jan Pazdziora 1.4.5-1
- remove every reference to "up2date --register" - even in comments
  (msuchy@redhat.com)
- 684342 - beside repo.id, cache even repo.name (msuchy@redhat.com)

* Thu Mar 10 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.4-1
- 683546 - optparse isn't friendly to translations in unicode
- 682820 - re-enable yum-rhn-plugin after package upgrade if the system is
  already registered
- forward port translations from RHEL6 to yum-rhn-plugin

* Fri Feb 18 2011 Jan Pazdziora 1.4.3-1
- handle installations of less recent package versions correctly
  (mzazrivec@redhat.com)

* Wed Feb 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.2-1
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)
- repopulate package sack after initial setup (mzazrivec@redhat.com)

* Mon Feb 14 2011 Jan Pazdziora 1.4.1-1
- 675780 - remove installed packages from transaction (mzazrivec@redhat.com)
- 671032 - specify RHN as "RHN Satellite or RHN Classic" (msuchy@redhat.com)
- 671032 - disable rhnplugin by default and enable it only after successful
  registration (msuchy@redhat.com)
- Bumping package versions for 1.4 (tlestach@redhat.com)

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 1.3.6-1
- this was accidentaly commited in previous commit - reverting
  (msuchy@redhat.com)
- 648403 - do not require up2date on rhel5 (msuchy@redhat.com)

* Mon Jan 31 2011 Tomas Lestach <tlestach@redhat.com> 1.3.5-1
- 672471 - do not send info to rhnParent about removing packages if plugin is
  enabled, but machine is not registred - i.e. getSystemId() returns None
  (msuchy@redhat.com)

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.4-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- update .po and .pot files for yum-rhn-plugin (tlestach@redhat.com)
- 666545 - don't report empty transactions as a successful action
  (mzazrivec@redhat.com)
- fix expression semantics (mzazrivec@redhat.com)

* Fri Jan 14 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.3-1
- switch off network communication in cache only mode
- cache list of rhn channels so we can correctly clean our stuff
- 627525 - moved communication with satellite server from init_hook to
- 656380 - do not disable SSL server name check for XMLRPC communication
- 652424 - code optimalization: use up2date_cfg as class atribute
- 652424 - do not enable Akamai if you set useNoSSLForPackages option
- 627525 - do not parse command line, leave it to yum itself

* Mon Jan 03 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.2-1
- 666876 - respect metadata_expire setting from yum config

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- removed unused imports

* Mon Nov 15 2010 Jan Pazdziora 1.2.7-1
- l10n: Updates to Italian (it) translation (tombo@fedoraproject.org)

* Wed Nov 10 2010 Jan Pazdziora 1.2.6-1
- call config.initUp2dateConfig() only once (msuchy@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 1.2.5-1
- Update copyright years in the rest of the repo.
- update .po and .pot files for yum-rhn-plugin

* Tue Oct 12 2010 Jan Pazdziora 1.2.4-1
- l10n: Updates to Persian (fa) translation (aysabzevar@fedoraproject.org)

* Wed Aug 25 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.3-1
- 626822 - packages for update should be cached

* Mon Aug 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.2-1
- 625778 - require newer yum-rhn-plugin

* Thu Aug 12 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.2.1-1
- update .po and .pot files for yum-rhn-plugin (msuchy@redhat.com)

* Tue Aug 10 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.6-1
- l10n: Italian version fully updated (fvalen@fedoraproject.org)

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.5-1
- enable caching for action packages.fullUpdate

* Tue Jul 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.4-1
- download scheduled package installation in advance (msuchy@redhat.com)
- add parameter cache_only to all client actions (msuchy@redhat.com)

* Mon Jun 14 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.3-1
- 598323 - yumex do not set version (msuchy@redhat.com)
- l10n: Updates to Chinese (China) (zh_CN) translation
  (leahliu@fedoraproject.org)
- l10n: Updates to Spanish (Castilian) (es) translation
  (gguerrer@fedoraproject.org)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)
- cleanup - removing translation file, which does not match any language code
  (msuchy@redhat.com)
- update po files for yum-rhn-plugin (msuchy@redhat.com)
- l10n: Updates to German (de) translation (ttrinks@fedoraproject.org)
- l10n: Updates to Polish (pl) translation (raven@fedoraproject.org)

* Wed May 05 2010 Justin Sherrill <jsherril@redhat.com> 1.1.2-1
- 589120 - fixing issue with traceback from rhn_chec "no attribute cfg"
  (jsherril@redhat.com)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

