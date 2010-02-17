Summary: Support programs and libraries for Red Hat Network or Spacewalk
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
Name: rhn-client-tools
Version: 0.9.0
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
%if 0%{?suse_version: %{suse_version} > 1000} 
%{!?suse_version:1}
BuildArch: noarch
BuildRequires: update-desktop-files
%endif

Requires: rhnlib >= 2.5.20
Requires: rpm >= 4.2.3-24_nonptl
Requires: rpm-python 
Requires: python-ethtool
Requires: gnupg
Requires: sh-utils
Requires: dbus-python
Requires: hal >= 0.5.8.1-52
Requires: newt
Requires: python-dmidecode
Requires: libxml2-python

Conflicts: up2date < 5.0.0

BuildRequires: python-devel
BuildRequires: gettext
BuildRequires: intltool
BuildRequires: desktop-file-utils

# The following BuildRequires are for check only
%if 0%{?fedora} >= 12
BuildRequires: python-coverage
BuildRequires: rhnlib
# python-setuptools can be removed when 556290 gets fixed
BuildRequires: python-setuptools
BuildRequires: rpm-python
%endif

%description
Red Hat Network Client Tools provides programs and libraries to allow your
system to receive software updates from Red Hat Network or Spacewalk.

%package -n rhn-check
Summary: Check for RHN actions
Group: System Environment/Base
Requires: %{name} = %{version}-%{release}
Requires: yum-rhn-plugin >= 0.5.3-30

%description -n rhn-check
rhn-check polls a Red Hat Network or Spacewalk server to find and execute 
scheduled actions.

%package -n rhn-setup
Summary: Configure and register an RHN/Spacewalk client
Group: System Environment/Base
Requires: usermode >= 1.36
Requires: %{name} = %{version}-%{release}
Requires: rhnsd

%description -n rhn-setup
rhn-setup contains programs and utilities to configure a system to use
Red Hat Network or Spacewalk, and to register a system with a Red Hat Network
or Spacewalk server.

%package -n rhn-setup-gnome
Summary: A GUI interface for RHN/Spacewalk Registration
Group: System Environment/Base
Requires: %{name} = %{version}-%{release}
Requires: rhn-setup = %{version}-%{release}
Requires: pam >= 0.72
Requires: pygtk2 pygtk2-libglade gnome-python2 gnome-python2-canvas 
Requires: usermode-gtk

%description -n rhn-setup-gnome
rhn-setup-gnome contains a GTK+ graphical interface for configuring and
registering a system with a Red Hat Network or Spacewalk server.


%prep
%setup -q 

%build
make -f Makefile.rhn-client-tools

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.rhn-client-tools install VERSION=%{version}-%{release} PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir}

mkdir -p $RPM_BUILD_ROOT/var/lib/up2date

desktop-file-install --dir=${RPM_BUILD_ROOT}%{_datadir}/applications --vendor=rhn rhn_register.desktop
%if 0%{?suse_version}
%suse_update_desktop_file rhn_register System
%endif

%find_lang %{name}

%post -n rhn-setup-gnome
touch --no-create %{_datadir}/icons/hicolor &>/dev/null || :

%postun -n rhn-setup-gnome
if [ $1 -eq 0 ] ; then
    touch --no-create %{_datadir}/icons/hicolor &>/dev/null
    gtk-update-icon-cache %{_datadir}/icons/hicolor &>/dev/null || :
fi

%posttrans -n rhn-setup-gnome
gtk-update-icon-cache %{_datadir}/icons/hicolor &>/dev/null || :


%clean
rm -rf $RPM_BUILD_ROOT

%if 0%{?fedora} >= 12
%check

make -f Makefile.rhn-client-tools test
%endif

%files -f %{name}.lang
%defattr(-,root,root,-)
# some info about mirrors
%doc doc/ChangeLog 
%doc doc/mirrors.txt 
%doc doc/fedora-core-1 
%doc doc/updates-released
%doc doc/AUTHORS
%doc doc/LICENSE
%{_mandir}/man8/rhn-profile-sync.8*
%{_mandir}/man5/up2date.5*

%dir %{_sysconfdir}/sysconfig/rhn
%dir %{_sysconfdir}/sysconfig/rhn/clientCaps.d
%dir %{_sysconfdir}/sysconfig/rhn/allowed-actions
%dir %{_sysconfdir}/sysconfig/rhn/allowed-actions/configfiles
%dir %{_sysconfdir}/sysconfig/rhn/allowed-actions/script
%config(noreplace) %{_sysconfdir}/sysconfig/rhn/up2date
%config(noreplace) %{_sysconfdir}/logrotate.d/up2date
%config(noreplace) %{_sysconfdir}/rpm/macros.up2date

# dirs
%dir %{_datadir}/rhn
%dir %{_datadir}/rhn/up2date_client

#files
%{_datadir}/rhn/up2date_client/__init__.*
%{_datadir}/rhn/up2date_client/config.*
%{_datadir}/rhn/up2date_client/haltree.*
%{_datadir}/rhn/up2date_client/hardware.*
%{_datadir}/rhn/up2date_client/up2dateUtils.*
%{_datadir}/rhn/up2date_client/up2dateLog.*
%{_datadir}/rhn/up2date_client/up2dateErrors.*
%{_datadir}/rhn/up2date_client/up2dateAuth.*
%{_datadir}/rhn/up2date_client/rpcServer.*
%{_datadir}/rhn/up2date_client/rhnserver.*
%{_datadir}/rhn/up2date_client/rpmUtils.*
%{_datadir}/rhn/up2date_client/rhnPackageInfo.*
%{_datadir}/rhn/up2date_client/rhnChannel.*
%{_datadir}/rhn/up2date_client/rhnErrata.*
%{_datadir}/rhn/up2date_client/rhnHardware.*
%{_datadir}/rhn/up2date_client/transaction.*
%{_datadir}/rhn/up2date_client/clientCaps.*
%{_datadir}/rhn/up2date_client/capabilities.*
%{_datadir}/rhn/up2date_client/rhncli.*
%{_datadir}/rhn/__init__.*

%{_sbindir}/rhn-profile-sync

#public keys and certificates
%{_datadir}/rhn/RHNS-CA-CERT

%files -n rhn-check
%defattr(-,root,root,-)
%dir %{_datadir}/rhn/actions
%{_mandir}/man8/rhn_check.8*

%{_sbindir}/rhn_check

%{_datadir}/rhn/up2date_client/getMethod.*

# actions for rhn_check to run
%{_datadir}/rhn/actions/__init__.*
%{_datadir}/rhn/actions/hardware.*
%{_datadir}/rhn/actions/errata.*
%{_datadir}/rhn/actions/systemid.*
%{_datadir}/rhn/actions/reboot.*
%{_datadir}/rhn/actions/rhnsd.*
%{_datadir}/rhn/actions/up2date_config.*

%files -n rhn-setup
%defattr(-,root,root,-)
%{_mandir}/man8/rhnreg_ks.8*
%{_mandir}/man8/rhn_register.8*
%{_mandir}/man8/spacewalk-channel.8*

%config(noreplace) %{_sysconfdir}/security/console.apps/rhn_register
%config(noreplace) %{_sysconfdir}/pam.d/rhn_register

%{_bindir}/rhn_register
%{_sbindir}/rhn_register
%{_sbindir}/rhnreg_ks
%{_sbindir}/spacewalk-channel
%{_sbindir}/rhn-channel

%{_datadir}/rhn/up2date_client/rhnreg.*
%{_datadir}/rhn/up2date_client/tui.*
%{_datadir}/rhn/up2date_client/rhnreg_constants.*

# firstboot is smart enough now to skip these modules
# if the modules say to
%{_datadir}/firstboot/modules/rhn_activate_gui.*
%{_datadir}/firstboot/modules/rhn_login_gui.*
%{_datadir}/firstboot/modules/rhn_register_firstboot_gui_window.*
%{_datadir}/firstboot/modules/rhn_start_gui.*
%{_datadir}/firstboot/modules/rhn_choose_server_gui.*
%{_datadir}/firstboot/modules/rhn_provide_certificate_gui.*
%{_datadir}/firstboot/modules/rhn_create_profile_gui.*
%{_datadir}/firstboot/modules/rhn_choose_org_gui.*
%{_datadir}/firstboot/modules/rhn_review_gui.*
%{_datadir}/firstboot/modules/rhn_finish_gui.*

%files -n rhn-setup-gnome
%defattr(-,root,root,-)
%{_datadir}/rhn/up2date_client/messageWindow.*
%{_datadir}/rhn/up2date_client/rhnregGui.*
%{_datadir}/rhn/up2date_client/rh_register.glade
%{_datadir}/rhn/up2date_client/gui.*
%{_datadir}/rhn/up2date_client/progress.*
%{_datadir}/pixmaps/*png
%{_datadir}/icons/hicolor/16x16/apps/up2date.png
%{_datadir}/icons/hicolor/24x24/apps/up2date.png
%{_datadir}/icons/hicolor/32x32/apps/up2date.png
%{_datadir}/icons/hicolor/48x48/apps/up2date.png
%{_datadir}/applications/rhn_register.desktop

%changelog
* Fri Feb  5 2010 Miroslav Suchy <msuchy@redhat.com> 0.8.12-1
- 543509 - found another part of code where we use hal for getting DMI inforation, removing

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.10-1
- updated copyrights
- 561485 - clear dmi warnings on ia64

* Wed Feb 03 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.9-1
- fixed several unit test

* Tue Feb 02 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.8-1
- fixed failed build 

* Mon Feb 01 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.7-1
- use rhnLockfile.py from rhnlib
- 543509 - don't send "Not Settable"/"Not Present" when guest have no UUID

* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.8.6-1
- 557370 - clear dmi warnings for xen pv guests (mzazrivec@redhat.com)
- 546312 - fix typo - we do not want to assign the result of the SetResultType operation. (jpazdziora@redhat.com)
- Remove other branches that check SubscriptionWindow by name. (jpazdziora@redhat.com)
- Since SubscriptionWindow is not in the list now, remove the whole class. (jpazdziora@redhat.com)
- Remove the SubscriptionWindow from the list. (jpazdziora@redhat.com)

* Thu Jan 21 2010 Miroslav Suchý <msuchy@redhat.com> 0.8.5-1
- 557059 - convert dbus.string to unicode

* Thu Jan 21 2010 Milan Zazrivec <mzazrivec@redhat.com> 0.8.4-1
- 557370 - put dmidecode import warnings into log

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.3-1
- 554317 - fix for gui registration traceback
- removed dead code
- 513660 - save / update up2date config during firstboot

* Tue Dec 15 2009 Miroslav Suchý <msuchy@redhat.com> 0.8.2-1
- 546312 - do not depend on hald for rhnreg_ks

* Tue Dec  1 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.11-1
- 541262 - fix networkRetries logic (mzazrivec@redhat.com)

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.10-1
- 216808 - add man page to package
- 216808 - create new script spacewalk-channel
- 527412 - compute delta and write it to logs only if writeChangesToLog is set to 1
- 536789 - remove forgotten lines
- 536789 - set only necessary network info

* Thu Nov  5 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.9-1
- suse has its own macro for updating icons
- enable build for suse 10.00 too
- hardcode MANPATH
- fix build under opensuse
- 532145 - define local variable ipaddr before it is used
- Dont halt registration if the hardware info could not be acquired for rhnreg_ks.

* Fri Oct 23 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.7-1
- 530369 - header is inmutable

* Thu Oct 22 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.5-1
- 449167 - record installation date of rpm package

* Mon Oct  5 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.4-1
- add versioned conflict to up2date

* Tue Sep 22 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.3-1
- comment out hosted url, so spacewalk users do not ping theirs machines

* Fri Sep  4 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.2-1
- Rhpl was removed from rhel client packages (lukas.durfina@gmail.com)
 
* Tue Sep  1 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.1-1
- change appeareance of icon and put it to Administration rather then to Preferences
- add scriplet to refres icon cache
- move "Requires: yum-rhn-plugin" from rhn-client-tools to rhn-check

* Wed Aug 05 2009 John Matthews <jmatthew@redhat.com> 0.6.2-1
- 494019 - Fixing the registration on python 2.6 to not include dbus.String
  objects in hardware profile as new xmlrpclib _dump method validates based on
  __dict__ on value. (pkilambi@redhat.com)

* Wed Jul 29 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-9
- Resolves: #445881

* Mon Jun 29 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-8
- Resolves: #467866

* Fri Jun 26 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.1-1
- code cleanup - there is no usage of md5 in this code
- bump up version to 0.6

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.4.28-1
- 503090 - Fix missing packages reported during rhnreg_ks.
  (dgoodwin@redhat.com)
- 467866 - Raise a more cleaner message if clients end up getting badStatusLine
  error due to 502 proxy errors (pkilambi@redhat.com)
- 504292 - fix the registration gui and tui to honor the ssl cert paths
  specified in the config. Set the paths to default locations only if the user
  hasn't explicitly defined it. (pkilambi@redhat.com)
- 504296 - removing debug statements from hardware probing
  (pkilambi@redhat.com)
- Support infinite available entitlements in TUI registration
  (jbowes@redhat.com)
- account for virt_uuid is None case (pkilambi@redhat.com)
- Send smbios data to remaining_subscriptions during registration
  (jbowes@redhat.com)

* Fri Jun 12 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-7
- Resolves: #504292 #467866

* Fri Jun  5 2009 Pradeep Kilambi <pkilambi@redhat.com>
- Resolves: #504296
 
* Thu May 21 2009 jesus m. rodriguez <jesusr@redhat.com> 0.4.27-1
- new build (pkilambi@redhat.com)
- 501316 - chnaging the network switch to always send network info by default
  unless there is a skipNetwork flag. This helps the upgrades issues where the
  config file gets saved by rpms and causing issues (pkilambi@redhat.com)
- merging additional spec changes and minor edits from svn
  (pkilambi@redhat.com)
- 467866 - catch the BadStatusLine and let use know that the server is
  unavailable temporarily (pkilambi@redhat.com)
-  -adding missing config option (pkilambi@redhat.com)
- Send smbios data in the new_system() call (jbowes@redhat.com)
- 499860 Ability to define location for the temporary transport file
  descriptors, uses /tmp by default (pkilambi@redhat.com)
- 479706 - send network and netInterface information on hardware probing during
  registration and profile sync is now an option and on by default. Users who
  do not wish to send network information can jus trun off sendNetwork option
  in the config. (pkilambi@redhat.com)
-  Letting firstboot know if the system is already registered through a
  kickstart so it would'nt prompt the user to re register during firstboot
  sequence (pkilambi@redhat.com)
- Throw an InvalidRedirectionError if redirect url does'nt fetch the package
  (pkilambi@redhat.com)
- adding NoSystemIdError exception class for 444581 (pkilambi@redhat.com)
- 467139 - fixing the rhn_check's action name to work for different locale
  (pkilambi@redhat.com)
- 491258 - adding check to see if haldaemon or messagebus is running. If not
  warn the user with right message and dont probe the hal and dmi as we'll
  obviously get a dbus_exception. (pkilambi@redhat.com)

* Mon May 18 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-5
- Resolves: #501316

* Tue May 12 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-4
- Resolves: #467866

* Mon May 11 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-3
- new build

* Fri May  8 2009 Pradeep Kilambi <pkilambi@redhat.com> 0.4.20-2
- Resolves: #204449 #227638 #445881 #454005 #466718 #479706
- Resolves: #491258 #494928 #250312 #464827 #467139 #476797
- Resolves: #476894 #487754

* Fri May 01 2009 Devan Goodwin <dgoodwin@redhat.com> 0.4.25-1
- Stop using spec file Source line for desktop file. (dgoodwin@redhat.com)
- Adding support to send smbios information to the servers if implemented.
  add_smbios_info needs to be implemented on the server to fully take advantage
  of this call. Xen host/guests + para/fully virt types should work as usual
  for now. (pkilambi@redhat.com)
- 250312 - Do not spam the cert directory with backup certs, instead use the
  one requested by the user and proceed if its valid else reprompt to upload a
  valid certificate (pkilambi@redhat.com)
- removing config set logic as this code block will prevent from accessing the
  provide security certificate page. Also Adding supporing code to handle
  missing CA cert cases, instead of erroring out. (pkilambi@redhat.com)
- updating translations (pkilambi@redhat.com)
- 476797 -  profile-sync should not  probe dmidecode info on PV guests as there
  is no SMBIOS entry. (pkilambi@redhat.com)
- 204449 - Deprecating contactinfo flag functionality from rhnreg_ks
  (pkilambi@redhat.com)
- rhn-client-tools should now depend on cdn enabled rhnlib package
  (pkilambi@redhat.com)
- 476894 - Fix to support multiarch support for errata with multiarch packages.
  Errata apply should only install installed arch updates. If i386 and x86_64
  are installed, updates for both arches will be applied. (pkilambi@redhat.com)

* Fri Apr 24 2009 Pradeep Kilambi <pkilambi@redhat.com>
- Resolves: #487754 - rhn-client-tools depends on cdn enabled rhnlib package

* Mon Mar 30 2009 Miroslav Suchy <msuchy@redhat.com> 0.4.24-1
- 490438 - add .desktop file, own allowed-actions dir

* Mon Mar 16 2009 Miroslav Suchy <msuchy@redhat.com> 0.4.22-1
- use macros insted hardcoded paths

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.4.21-1
- replace "!#/usr/bin/env python" with "!#/usr/bin/python"

* Mon Jan 19 2009 Devan Goodwin <dgoodwin@redhat.com> 0.4.20-1
- Remove usage of version and sources files.

* Fri Dec  5 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-17
- Resolves: #473429 #473425

* Tue Nov 18 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-15
- Resolves: #249425 #405671

* Wed Nov 12 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-10
- Resolves: #471245

* Tue Nov 11 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-9
- Resolves: #249425 #470496 #231902 #470481

* Wed Nov  5 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-8
- Resolves: #429334 #249425 #231902

* Mon Oct 27 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-6
- Resolves: #467887

* Fri Oct 24 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-5
- Resolves: #467705 #467870 #468039

* Fri Sep 26 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-4
- new build

* Thu Sep 18 2008 Pradeep Kilambi <pkilambi@redhat.com> 0.4.19-2
- Resolves: #231902 #241209 #249127 #249425 #253596 
- Resolves: #385321 #405671 #429334 #430155 #430156 
- Resolves: #432426 #433097 #434550 #439383 #442923 
- Resolves: #442930 #450597 #451775 #452829 #457953  #460685

* Tue Apr 16 2008 Pradeep Kilambi <pkilambi@redhat.com> 
- Resolves: #442694

* Mon Mar 16 2008 Pradeep Kilambi <pkilambi@redhat.com> - 0.4.17-3
- Resolves:  #435177

* Wed Jan 16 2008 Pradeep Kilambi <pkilambi@redhat.com> - 0.4.17-1
- Resolves: #211127, #212539, #213587, #216225, #216951, #216959
- Resolves: #219814, #221912, #228240, #231041, #249426, #253031
- Resolves: #315421, #364171, #364181, #364191, #372771, #426851

* Thu Jun 07 2007 James Slagle <jslagle@redhat.com> - 0.4.16-1
- Resolves: #212300, #212407, #217857, #218860, #224633, #227399
- Resolves: #228028, #229785, #229951, #232567, #233067, #234238
- Resolves: #234880, #236925, #237300

* Thu Feb 08 2007 James Bowes <jbowes@redhat.com> - 0.4.13-1
- Add missing translations.
- Related: #211568

* Tue Feb 06 2007 James Bowes <jbowes@redhat.com> - 0.4.12-1
- Add missing translations.
- Related: #211568
- Fix 'rhn_register dies when calling activateHardwareInfo' (jesusr)
- Resolves: #227408
 
* Thu Feb 01 2007 James Bowes <jbowes@redhat.com> - 0.4.11-1
- Add missing translations.
- Related: #211568

* Thu Feb 01 2007 James Bowes <jbowes@redhat.com> - 0.4.10-1
- Updated code to use more robust UUID/virt_type discovery mechanisms, which
  allows us to workaround BZ 225203. (pvetere)
- Resolves: #225203

* Mon Jan 29 2007 James Bowes <jbowes@redhat.com> - 0.4.9-1
- Add missing code required by packages.verify
- Resolves: #224631

* Mon Jan 22 2007 James Bowes <jbowes@redhat.com> - 0.4.8-1
- Add messages for virt entitlements
- Client side support for sending uuid and virt type during registration
- Look for orgs and INs even on satellite
- Catch InvalidRegNumException for hardware numbers
- Resolves: #223322, #223860, #223295, #223307, #223359

* Wed Jan 17 2007 James Bowes <jbowes@redhat.com> - 0.4.7-1
- Update translations.
- Related: #211568

* Wed Jan 10 2007 James Bowes <jbowes@redhat.com> - 0.4.6-1
- Update translations.
- Related: #211568

* Mon Dec 18 2006 James Bowes <jbowes@redhat.com> - 0.4.5-1
- Remove the last of the references to the up2date text domain.
- Related: #211568

* Fri Dec 15 2006 James Bowes <jbowes@redhat.com> - 0.4.4-1
- Update translations.
- Make sure translations are used in all parts of the gui and tui
- Related: #211568

* Thu Dec 14 2006 John Wregglesworth <wregglej@redhat.com> - 0.4.3-1
- Update translations.
- Related: #211568, #215285

* Mon Dec 11 2006 James Bowes <jbowes@redhat.com> - 0.4.2-1
- Updated translations.
- Related: #211568

* Thu Dec 07 2006 James Slagle <jslagle@redhat.com> - 0.4.1-1
- Resolves: #218714

* Tue Dec 05 2006 James Bowes <jbowes@redhat.com> - 0.4.0-1
- Updated translations.

* Fri Dec 01 2006 James Bowes <jbowes@redhat.com> - 0.3.9-2
- Stop packaging unused png.

* Fri Dec 01 2006 James Bowes <jbowes@redhat.com> - 0.3.9-1
- Updated translations.

* Thu Nov 30 2006 James Bowes <jbowes@redhat.com> - 0.3.8-1
- Resolves: #212666, #216812, #215362, #210948, #216527, #213589

* Wed Nov 29 2006 James Slagle <jslagle@redhat.com> - 0.3.7-1
- Resolves: #212589, #212464

* Wed Nov 29 2006 James Slagle <jslagle@redhat.com> - 0.3.6-1
- Fixes for #212305, #212394

* Wed Nov 22 2006 James Slagle <jslagle@redhat.com> - 0.3.5-1
- Fixes for #213955, #212389, #212253

* Mon Nov 20 2006 James Bowes <jbowes@redhat.com> - 0.3.4-1
- Fixes for #213573, #215992, #215958, #214844, #214190

* Tue Nov 14 2006 James Bowes <jbowes@redhat.com> - 0.3.3-1
- Fixes for #213089, #213958, #214691, #215085, #414414, #213134, #214882 
- Fixes for #214844, #214523, #214609
- Include new manual pages and AUTHORS file.

* Mon Nov 06 2006 James Slagle <jslagle@redhat.com> - 0.3.2-1
- Fix for #213952

* Thu Nov 01 2006 James Bowes <jbowes@redhat.com> - 0.3.1-1
- Fixes for #212460, #211414, #213089

* Tue Oct 31 2006 Shannon Hughes <shughes@redhat.com> - 0.3.0-1
- up2date/rhn_register support for hicolor theme
- Fix for #212666
- Fixes for #213133, #213090, #212020

* Mon Oct 30 2006 James Slagle <jslagle@redhat.com> - 0.2.9-1
- Add noSidebar attribute to the firstboot modules (except the 1st one).
- Fix for #211696

* Mon Oct 30 2006 James Bowes <jbowes@redhat.com> - 0.2.8-1
- New and updated translations.
- Fixes for #211480, #211568, #212618, #212539, #211415, #210948, #211389
- Fixes for #212052, #212453, #211382, #212599

* Thu Oct 26 2006 James Bowes <jbowes@redhat.com> - 0.2.7-1
- Update to 0.2.7
- Fixes for #212212, #211132

* Wed Oct 25 2006 Peter Vetere <pvetere@redhat.com> - 0.2.6-1
- Update to 0.2.6
- Fixed rhnreg_ks call to registerSystem.  Used "token" arg instead of 
  "activationKey."

* Wed Oct 25 2006 James Bowes <jbowes@redhat.com> - 0.2.5-1
- Update to 0.2.5
- Fixes for #211407, #211291, #211888, #212088, #212027, #211456, #211855

* Tue Oct 24 2006 James Bowes <jbowes@redhat.com> - 0.2.4-1
- Update to 0.2.4
- Fixes for #212001, #211876, #211132, #211376, #211374, #211359, #211231,
  and #211186

* Fri Oct 20 2006 Daniel Benamy <dbenamy@redhat.com> - 0.2.3-1
- New version (some bugfixes and an added image file).

* Tue Oct 17 2006 James Bowes <jbowes@redhat.com> - 0.2.2-2
- Conflict up2date, since we install in the same location.

* Mon Oct 16 2006 James Bowes <jbowes@redhat.com> - 0.2.2-1
- New version.

* Mon Oct 16 2006 James Bowes <jbowes@redhat.com> - 0.2.1-1
- New version.

* Mon Oct 16 2006 James Bowes <jbowes@redhat.com> - 0.2.0-1
- New version.

* Fri Oct 13 2006 James Bowes <jbowes@redhat.com> - 0.1.9-1
- No longer provide or obsolete up2date

* Fri Oct 13 2006 James Bowes <jbowes@redhat.com> - 0.1.8-3
- reverted to desktop-file-install. It appears to be the preferred way.

* Thu Oct 12 2006 James Bowes <jbowes@redhat.com> - 0.1.8-2
- Update the summary and description of rhn-setup-gnome

* Thu Oct 12 2006 James Bowes <jbowes@redhat.com> - 0.1.8-1
- Fix for bz #210348
- use update-desktop-database rather than desktop-file-install

* Wed Oct 11 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.7-1
- Remove rhn_shared.py from firstboot stuff.

* Mon Oct 09 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.6-1
- New release for the milestone build that includes all the overhauling so far.

* Mon Oct 09 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.5-7
- Add rhn_review_gui firstboot module.

* Fri Oct 06 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.5-6
- Remove old new account and opt out firstboot modules.
- Add finish firstboot module.

* Wed Oct 04 2006 James Slagle <jslagle@redhat.com> - 0.1.5-5
- Add rhnreg_constants module.

* Wed Sep 27 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.5-4
- Add rhn_choose_org_gui firstboot module.

* Mon Sep 25 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.5-3
- Use rhn_start_gui firstboot module instead of rhn_choose_to_register_gui.

* Wed Sep 20 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.5-2
- Add file that firstboot create profile screen is moving to.

* Thu Sep 14 2006 James Bowes <jbowes@redhat.com> - 0.1.5-1
- Fix whitespace error in rhn-profile-sync.py

* Wed Sep 13 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.4-9
- Add file containing firstboot provide cert screen.

* Wed Sep 13 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.4-8
- Add file containing firstboot choose server screen.

* Tue Sep 12 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.4-7
- Add file containing firstboot screen asking if user wants to register.

* Mon Sep 11 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.4-6
- Add file containing base class for firstboot windows.

* Thu Sep 07 2006 James Bowes <jbowes@redhat.com> - 0.1.4-5
- Remove references to up2date-uuid.

* Wed Sep 06 2006 Daniel Benamy <dbenamy@redhat.com> - 0.1.4-4
- Remove configdlg and put needed functionality in rh_register.glade and 
  rhnregGui.py.

* Wed Aug 30 2006 James Bowes <jbowes@redhat.com> - 0.1.4-3
- Move messageWindow and tui from client-tools to setup-gnome
  and setup.
- Add haltree

* Mon Aug 28 2006 James Bowes <jbowes@redhat.com> - 0.1.4-2
- Remove python-optik requires.

* Fri Jul 28 2006 James Bowes <jbowes@redhat.com> - 0.1.4-1
- New release.

* Thu Jul 27 2006 James Bowes <jbowes@redhat.com> - 0.1.3-1
- New release.
- Remove sourcesConfig from the spec file.

* Fri Jul 21 2006 James Bowes <jbowes@redhat.com> - 0.1.2-1
- New release.
- Remove rhnDefines from package.

* Fri Jul 21 2006 James Bowes <jbowes@redhat.com> - 0.1.1-1
- New release.
- Remove mkdir /etc/sysconfig/rhn from install; this is done
  in the Makefile.

* Thu Jul 20 2006 James Bowes <jbowes@redhat.com> - 0.1.0-2
- Remove rhn_register obsoletes.

* Thu Jul 20 2006 James Bowes <jbowes@redhat.com> - 0.1.0-1
- New release.

* Thu Jul 20 2006 James Bowes <jbowes@redhat.com> - 0.0.9-1
- New release.

* Tue Jul 19 2006 James Bowes <jbowes@redhat.com> - 0.0.8-3
- Make sub-packages depend on the exact version and release of
  the master package.

* Tue Jul 18 2006 James Bowes <jbowes@redhat.com> - 0.0.8-2
- Point to the new docs location in the source tree.

* Fri Jul 14 2006 James Bowes <jbowes@redhat.com> - 0.0.8-1
- Generate a uuid file from scratch during post.

* Wed Jun 21 2006 James Bowes <jbowes@redhat.com> - 0.0.7-1
- Removed the packages action.

* Fri Jun 02 2006 James Bowes <jbowes@redhat.com> - 0.0.6-2
- Remove reference to cliUtils

* Fri Jun 02 2006 James Bowes <jbowes@redhat.com> - 0.0.6-1
- new rhn-profile-sync command for syncing package, hardware,
  and virtualization profiles with rhn.

* Tue May 30 2006 James Bowes <jbowes@redhat.com> - 0.0.5-1
- Remove unneeded imports and circular imports.

 Tue May 23 2006 Pete Vetere <pvetere@redhat.com> - 0.0.4-1
- Add support for sending virtualization info to RHN

* Mon May 22 2006 James Bowes <jbowes@redhat.com> - 0.0.3-2
- Properly link rhn_register and up2date-config

* Thu May 18 2006 James Bowes <jbowes@redhat.com> - 0.0.3-1
- Remove more unused code and data files.

* Tue May 09 2006 James Bowes <jbowes@redhat.com> - 0.0.2-1
- Remove non-up2date repo backends.

* Mon May 08 2006 James Bowes <jbowes@redhat.com> - 4.4.69-6
- bump required version of rhnlib for pkg/iso redirect.

* Tue May 02 2006 James Bowes <jbowes@redhat.com> - 4.4.69-3
- fix for #87837, inaccurate error message when missing '-f' for kernel updates
- fix for #125049, misleading usage message: "Please specify either -l, -u, ...
- fix for #126528, up2date +get source fails if no source available
- fix for #168312, up2date config file is not ignored in rpm -V
- fix for #171057, CRM# 696030 repomd error after up2date
- fix for #171643, repomd error after up2date
- fix for #s 179896, 179898  rpm verify fails due to config files in .spec not marked ...

* Mon Apr 24 2006 Bret McMillan <bretm@redhat.com> 4.4.69-1
- fix for #178498, #176123 -- make --channel limit the channel universes for various operations
- fix for #162106, RHN 'sync packages to system' installing i386 glibc on i686
- fix for #175593, up2date --whatprovides doesn't handle compat arch provides

* Tue Apr 11 2006 James Bowes <jbowes@redhat.com> 0.0.1-1
- Pull out rhnsd stuff so we can build as noarch.
- Make seperate rpms for rhn_check, and register.

* Wed Feb 01 2006 Adrian Likins <alikins@redhat.com> 4.4.6800000000000eleventybillion
- gratuitous version rev to test up2date of up2date

* Tue Jan 31 2006 Bret McMillan <bretm@redhat.com> 4.4.67-4
- fix release tag

* Fri Jan 27 2006 Adrian Likins <alikins@redhat.com> 4.4.67-3
- fix for #179110 - up2date fails to update xerces-j
- more fixed for #176195 "up2date-nox --configure changes current value of numeric attribute to Yes/No if 1/0 is selected"

* Fri Jan 27 2006 Bret McMillan <bretm@redhat.com> 4.4.65-3
- fix for #176195 "up2date-nox --configure changes current value of numeric attribute to Yes/No if 1/0 is selected"

* Thu Jan 19 2006 Adrian Likins <alikins@redhat.com> 4.4.63-4
- rest of fix for #169880 up2date --arch updates primary arch if package is out of date instead of arch specified.
- even better fix for #178261 "Invalid function call attempted" when installing a RHN proxy

* Thu Jan 19 2006 Bret McMillan <bretm@redhat.com> 4.4.60-4
- rebuild with fixes for:
- fix #169293 -- up2date unable to download very large rpms
- fix #177784 -- up2date gives error if select-all is checked
- fix #177786 -- up2date unselects all pakcages if select-all is checked and user selects 'back'

* Thu Jan 12 2006 Adrian Likins <alikins@redhat.com> 4.4.58
- fix for #165157 - firstboot 'Read our Privacy Statement' shows a blank text box

* Fri Jan 6 2006 Adrian Likins <alikins@redhat.com> 4.4.56-4.1
- rebuild for #176182 (new gcc)

* Thu Dec 8 2005 Adrian Likins <alikins@redhat.com> 4.4.55
- add bug fix for  #175321  rhnreg_ks cannot import name capabilities -- circular import

* Wed Nov 15 2005 Adrian Likins <alikins@redhat.com> 4.4.54
- revert orig fix for #165024 - "invalid function call" error on proxy installs
- add new bug fix for #165204
- revert "fix" for #169882, #159955 - up2date man page does not describe --undo option.
- add --unfo to man page fixing #169882, #159955


* Wed Nov 09 2005 Adrian Likins <alikins@redhat.com> 4.4.52
- fix #165024 - "invalid function call" error on proxy installs
- fix #169881, #167732 -  'up2date --configure' always saves changes if useNetwork is false on startup
 

* Mon Oct 10 2005 Adrian Likins <alikins@redhat.com> 4.4.51
- fix #169882, #159955 - up2date man page does not describe --undo option.
  (remove deprecated undo option)
- fix #170065, #166034 - up2date "forward" button disabled if packages selected via spacebar.
- fix #157087, #170055 - up2date --configure fails when failover serverURL is configured.

* Thu Sep 15 2005 Adrian Likins <alikins@redhat.com> 4.4.50-4
- new up2date.pot, synced up
- fix uncommitted changes that were causing string 
  translations not to show up
- more translations updates for #160608

* Mon Sep 12 2005 Adrian Likins <alikins@redhat.com> 4.4.45
- fix for #160602 (updated russian translations)


* Fri Aug 26 2005 Adrian Likins <alikins@redhat.com> 4.4.44
- fix for #166868 - fatal python error when  installing package

* Tue Aug 23 2005 Adrian Likins <alikins@redhat.com> 4.4.43
- more fixes for #144800

* Tue Aug 23 2005 Adrian Likins <alikins@redhat.com> 4.4.42
- more fixes for #159858/#157070

* Mon Aug 15 2005 Adrian Likins <alikins@redhat.com> 4.4.41
- fix #164660

* Thu Aug 11 2005 Adrian Likins <alikins@redhat.com> 4.4.40
- attempt "fix" for #165636 (require new rpm versions)

* Wed Aug 10 2005 Adrian Likins <alikins@redhat.com> 4.4.39
- more fix for #157070
- require newer rhnlib for #165360

* Thu Aug 4 2005 Adrian Likins <alikins@redhat.com> 4.4.38
- fix desktop files rpmdiff complained about

* Thu Aug 4 2005 Adrian Likins <alikins@redhat.com> 4.4.37
- fix specfile to work on ppc

* Wed Aug 3 2005 Adrian Likins <alikins@redhat.com> 4.4.36
- fix for #162701

* Wed Aug 3 2005 Adrian Likins <alikins@redhat.com> 4.4.35
- fix for #160602 (updated ru.po)

* Tue Aug 2 2005 Adrian Likins <alikins@redhat.com> 4.4.34
- fix for #144800

* Thu Jul 28 2005 Adrian Likins <alikins@redhat.com> 4.4.33
- fix for #149472

* Wed Jul 27 2005 Adrian Likins <alikins@redhat.com> 4.4.32
- fix for #144800
- fix for #137942

* Tue Jul 26 2005 Adrian Likins <alikins@redhat.com> 4.4.31
- fix for #155583

* Tue Jul 12 2005 Adrian Likins <alikins@redhat.com> 4.4.30
- more fixes for sources on RHEL-3
- have to include "3" as a release as well

* Mon Jul 11 2005 Adrian Likins <alikins@redhat.com> 4.4.28
- fix for issues with updating the package list after
  actions correctly #125790

* Thu Jul 7 2005 Jason Connor <jconnor@redhat.com> 4.4.27.2
- hotfix for bug 148952

* Tue Jun 7 2005 Adrian Likins <alikins@redhat.com> 4.4.25
- delay/avoid doing repomd if it's not in use

* Mon Jun 6 2005 Adrian Likins <alikins@redhat.com> 4.4.24
- dont require the old extended_packages cap

* Thu May 19 2005 Adrian Likins <alikins@redhat.com> 4.4.23
- change the way the version substitution works to pass pkg checker

* Thu May 19 2005 Adrian Likins <alikins@redhat.com> 4.4.22
- fix #158256 - up2date errors if yum isnt installed, but doesn't need to

* Thu May 19 2005 Adrian Likins <alikins@redhat.com> 4.4.20
- fix #154814 -  Selecting all packages in the GUI only selects first package

* Tue May 17 2005 Adrian Likins <alikins@redhat.com> 4.4.19
- fix #155583 - don't allow kernel-smp.x86_64 to be installed on ia32e
- fix #157070 - make yum/apt repos support proxies
- fix #148952 - patch from Jack Neely <jjneely@pams.ncsu.edu)

* Mon May 16 2005 Adrian Likins <alikins@redhat.com> 4.4.19
- fix #150418 – rhel-4 client machine capabilities not recognized sometimes
- fix #145554 – rhn_register fails if proxy username begins at '0'
- fix #154137 up2date does not always send the arch

* Mon May 9 2005 Adrian Likins <alikins@redhat.com> 4.4.18
- fix problem with missing import

* Wed Apr 27 2005 Adrian Likins <alikins@redhat.com> 4.4.17
- fix some bugs in the way repomdRepo creates the package lists

* Tue Apr 26 2005 Adrian Likins <alikins@redhat.com> 4.4.16
- support repomd repos (and use the yum config if it exists)
  bugzilla #135121

* Tue Apr 19 2005 Adrian Likins <alikins@redhat.com> 4.4.15
- fix #149444 up2date --dry-run --upgrade-to-release changes registered base channel
- fix #151328 (tracback when registering with *'s in password)
- added some general uncaught exception catching
- truncate rpm changelog (see up2date.spec.changelog)
- update translations

* Thu Apr 14 2005 Jason Connor <jconnor@redhat.com> 4.4.14
- fix #135121 - uncommented rpmmd registration, fixed api
- fix #149281 - added check for failed read

* Fri Apr 8 2005 Adrian Likins <alikins@redhat.com> 4.4.13
- update translations

* Thu Apr 7 2005 Adrian Likins <alikins@redhat.com> 4.4.12
- update translations

* Thu Mar 3 2005 Adrian Likins <alikins@redhat.com> 4.4.10
- fix #150210
- revert change for package list refresh for this
  release

* Tue Mar 1 2005 Adrian Likins <alikins@redhat.com> 4.4.9
- fix #149947

* Tue Feb 15 2005 Adrian Likins <alikins@redhat.com> 4.4.8
- fix #139537

* Fri Jan 14 2005 Adrian Likins <alikins@redhat.com> 4.4.7
- fix #136497
- fix #142750, #142589 (less deprecation warnings) 

* Mon Jan 10 2005 Adrian Likins <alikins@redhat.com> 4.4.6
- fix #144704

* Wed Dec 15 2004 Adrian Likins <alikins@redhat.com> 4.4.5
- fix #142406 (again)

* Wed Dec 15 2004 Adrian Likins <alikins@redhat.com> 4.4.4
- fix #142332
- fix #129909

* Tue Dec 14 2004 Adrian Likins <alikins@redhat.com> 4.4.3
- fix #142406

* Mon Dec 6 2004 Adrian Likins <alikins@redhat.com> 4.4.2
- fix #139495 (updated translations)

* Fri Dec 3 2004 Adrian Likins <alikins@redhat.com> 4.4.1
- fix #141820 (add kernel-devel to list of packages to
  intall not update)

* Fri Dec 3 2004 Adrian Likins <alikins@redhat.com> 4.4.0
- rev to 4.4.0
