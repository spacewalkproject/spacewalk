Summary: Support programs and libraries for Red Hat Satellite or Spacewalk
License: GPLv2
Group: System Environment/Base
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
URL:     https://fedorahosted.org/spacewalk
Name: rhn-client-tools
Version: 2.1.13
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
%if 0%{?suse_version}
BuildRequires: update-desktop-files
%endif

Requires: rhnlib >= 2.5.57
Requires: rpm >= 4.2.3-24_nonptl
Requires: rpm-python 
Requires: python-ethtool >= 0.4
Requires: gnupg
Requires: sh-utils
%if 0%{?suse_version}
Requires: dbus-1-python
%else
Requires: dbus-python
%endif
%if 0%{?fedora} || 0%{?rhel} > 5 || 0%{?suse_version} >= 1140
Requires: python-gudev
Requires: python-hwdata
%else
Requires: hal >= 0.5.8.1-52
%endif
%if 0%{?suse_version}
Requires: python-newt
%endif
%if 0%{?rhel} == 5
Requires: newt
%endif
%if 0%{?fedora} || 0%{?rhel} > 5
Requires: newt-python
%endif
Requires: python-dmidecode
%if 0%{?suse_version}
Requires: zypper
%else
Requires: yum
%endif

Conflicts: up2date < 5.0.0
Conflicts: yum-rhn-plugin < 1.6.4-1
Conflicts: rhncfg < 5.9.23-1
Conflicts: spacewalk-koan < 0.2.7-1
Conflicts: rhn-kickstart < 5.4.3-1
Conflicts: rhn-virtualization-host < 5.4.36-2

BuildRequires: python-devel
BuildRequires: gettext
BuildRequires: intltool
BuildRequires: desktop-file-utils

%if 0%{?fedora}
BuildRequires: fedora-logos
%endif
%if 0%{?rhel}
BuildRequires: redhat-logos
%endif

# The following BuildRequires are for check only
%if 0%{?fedora}
BuildRequires: python-coverage
BuildRequires: rhnlib
BuildRequires: rpm-python
%endif

%description
Red Hat Satellite Client Tools provides programs and libraries to allow your
system to receive software updates from Red Hat Satellite or Spacewalk.

%package -n rhn-check
Summary: Check for RHN actions
Group: System Environment/Base
Requires: %{name} = %{version}-%{release}
%if 0%{?suse_version}
Requires: zypp-plugin-spacewalk
%else
Requires: yum-rhn-plugin >= 1.6.4-1
%endif

%description -n rhn-check
rhn-check polls a Red Hat Satelliteor Spacewalk server to find and execute 
scheduled actions.

%package -n rhn-setup
Summary: Configure and register an RHN/Spacewalk client
Group: System Environment/Base
Requires: usermode >= 1.36
Requires: %{name} = %{version}-%{release}
Requires: rhnsd
%if 0%{?rhel} == 5
Requires: newt
%endif
%if 0%{?fedora} || 0%{?rhel} > 5
Requires: newt-python
%endif

%description -n rhn-setup
rhn-setup contains programs and utilities to configure a system to use
Red Hat Satellite or Spacewalk, and to register a system with a Red Hat Satellite or Spacewalk server.

%package -n rhn-setup-gnome
Summary: A GUI interface for RHN/Spacewalk Registration
Group: System Environment/Base
Requires: %{name} = %{version}-%{release}
Requires: rhn-setup = %{version}-%{release}
Requires: pam >= 0.72
%if 0%{?suse_version}
Requires: python-gnome python-gtk
%else
Requires: pygtk2 pygtk2-libglade gnome-python2 gnome-python2-canvas
%endif
Requires: usermode-gtk
%if 0%{?fedora} || 0%{?rhel} > 5
Requires: gnome-python2-gnome gnome-python2-bonobo
Requires: liberation-sans-fonts
%endif

%description -n rhn-setup-gnome
rhn-setup-gnome contains a GTK+ graphical interface for configuring and
registering a system with a Red Hat Satellite or Spacewalk server.


%prep
%setup -q 

%build
make -f Makefile.rhn-client-tools

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.rhn-client-tools install VERSION=%{version}-%{release} PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir}

mkdir -p $RPM_BUILD_ROOT/var/lib/up2date
mkdir -pm700 $RPM_BUILD_ROOT%{_localstatedir}/spool/up2date
touch $RPM_BUILD_ROOT%{_localstatedir}/spool/up2date/loginAuth.pkl
%if 0%{?fedora} >= 18
mkdir -p $RPM_BUILD_ROOT/%{_presetdir}
install 50-spacewalk-client.preset $RPM_BUILD_ROOT/%{_presetdir}
%endif

%if 0%{?fedora} || 0%{?rhel} > 5 || 0%{?suse_version} >= 1140
rm $RPM_BUILD_ROOT%{_datadir}/rhn/up2date_client/hardware_hal.*
%else
rm $RPM_BUILD_ROOT%{_datadir}/rhn/up2date_client/hardware_gudev.*
%endif

%if 0%{?rhel} > 0
%if 0%{?rhel} < 6
rm -rf $RPM_BUILD_ROOT%{_datadir}/rhn/up2date_client/firstboot
rm -f $RPM_BUILD_ROOT%{_datadir}/firstboot/modules/rhn_register.*
%endif
%if 0%{?rhel} == 6
rm -rf $RPM_BUILD_ROOT%{_datadir}/firstboot/modules/rhn_*_*.*
%endif
%if 0%{?rhel} > 6
rm -rf $RPM_BUILD_ROOT%{_datadir}/rhn/up2date_client/firstboot
rm -rf $RPM_BUILD_ROOT%{_datadir}/firstboot/
%endif
%else
rm -rf $RPM_BUILD_ROOT%{_datadir}/firstboot/modules/rhn_*_*.*
%endif

desktop-file-install --dir=${RPM_BUILD_ROOT}%{_datadir}/applications --vendor=rhn rhn_register.desktop
%if 0%{?suse_version}
%suse_update_desktop_file -r rhn_register "Settings;System;SystemSetup;"
%endif

%find_lang %{name}

%post
rm -f %{_localstatedir}/spool/up2date/loginAuth.pkl

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

%if 0%{?fedora}
%check

make -f Makefile.rhn-client-tools test
%endif

%files -f %{name}.lang
# some info about mirrors
%doc doc/mirrors.txt 
%doc doc/AUTHORS
%doc doc/LICENSE
%{_mandir}/man8/rhn-profile-sync.8*
%{_mandir}/man5/up2date.5*

%dir %{_sysconfdir}/sysconfig/rhn
%dir %{_sysconfdir}/sysconfig/rhn/clientCaps.d
%dir %{_sysconfdir}/sysconfig/rhn/allowed-actions
%dir %{_sysconfdir}/sysconfig/rhn/allowed-actions/configfiles
%dir %{_sysconfdir}/sysconfig/rhn/allowed-actions/script
%verify(not md5 mtime size) %config(noreplace) %{_sysconfdir}/sysconfig/rhn/up2date
%config(noreplace) %{_sysconfdir}/logrotate.d/up2date
%{_sysconfdir}/rpm/macros.up2date

# dirs
%dir %{_datadir}/rhn
%dir %{_datadir}/rhn/up2date_client
%dir %{_localstatedir}/spool/up2date

#files
%{_datadir}/rhn/up2date_client/__init__.*
%{_datadir}/rhn/up2date_client/config.*
%{_datadir}/rhn/up2date_client/haltree.*
%{_datadir}/rhn/up2date_client/hardware*
%{_datadir}/rhn/up2date_client/up2dateUtils.*
%{_datadir}/rhn/up2date_client/up2dateLog.*
%{_datadir}/rhn/up2date_client/up2dateErrors.*
%{_datadir}/rhn/up2date_client/up2dateAuth.*
%{_datadir}/rhn/up2date_client/rpcServer.*
%{_datadir}/rhn/up2date_client/rhnserver.*
%{_datadir}/rhn/up2date_client/pkgUtils.*
%{_datadir}/rhn/up2date_client/rpmUtils.*
%{_datadir}/rhn/up2date_client/debUtils.*
%{_datadir}/rhn/up2date_client/rhnPackageInfo.*
%{_datadir}/rhn/up2date_client/rhnChannel.*
%{_datadir}/rhn/up2date_client/rhnHardware.*
%{_datadir}/rhn/up2date_client/transaction.*
%{_datadir}/rhn/up2date_client/clientCaps.*
%{_datadir}/rhn/up2date_client/capabilities.*
%{_datadir}/rhn/up2date_client/rhncli.*
%{_datadir}/rhn/up2date_client/pkgplatform.*
%{_datadir}/rhn/__init__.*

%{_sbindir}/rhn-profile-sync

%ghost %attr(600,root,root) %verify(not md5 size mtime) %{_localstatedir}/spool/up2date/loginAuth.pkl

#public keys and certificates
%{_datadir}/rhn/RHNS-CA-CERT

%if 0%{?fedora} >= 18
%{_presetdir}/50-spacewalk-client.preset
%endif

%files -n rhn-check
%dir %{_datadir}/rhn/actions
%{_mandir}/man8/rhn_check.8*

%{_sbindir}/rhn_check

%{_datadir}/rhn/up2date_client/getMethod.*

# actions for rhn_check to run
%{_datadir}/rhn/actions/__init__.*
%{_datadir}/rhn/actions/hardware.*
%{_datadir}/rhn/actions/systemid.*
%{_datadir}/rhn/actions/reboot.*
%{_datadir}/rhn/actions/rhnsd.*
%{_datadir}/rhn/actions/up2date_config.*

%files -n rhn-setup
%{_mandir}/man8/rhnreg_ks.8*
%{_mandir}/man8/rhn_register.8*
%{_mandir}/man8/spacewalk-channel.8*
%{_mandir}/man8/rhn-channel.8*

%config(noreplace) %{_sysconfdir}/security/console.apps/rhn_register
%config(noreplace) %{_sysconfdir}/pam.d/rhn_register

%{_bindir}/rhn_register
%{_sbindir}/rhn_register
%{_sbindir}/rhnreg_ks
%{_sbindir}/spacewalk-channel
%{_sbindir}/rhn-channel

%{_datadir}/rhn/up2date_client/rhnreg.*
%{_datadir}/rhn/up2date_client/yumPlugin.*
%{_datadir}/rhn/up2date_client/tui.*
%{_datadir}/rhn/up2date_client/rhnreg_constants.*

%{_datadir}/setuptool/setuptool.d/99rhn_register

%if 0%{?suse_version}
# on SUSE directories not owned by any package
%dir %{_sysconfdir}/security/console.apps
%dir %{_datadir}/setuptool
%dir %{_datadir}/setuptool/setuptool.d
%endif

%files -n rhn-setup-gnome
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
%if 0%{?rhel} > 6 || 0%{?fedora} > 17
%{_datadir}/icons/hicolor/22x22/apps/up2date.png
%{_datadir}/icons/hicolor/256x256/apps/up2date.png
%endif
%{_datadir}/applications/rhn_register.desktop

%if 0%{?rhel} > 0 && 0%{?rhel} < 6
%{_datadir}/firstboot/modules/rhn_login_gui.*
%{_datadir}/firstboot/modules/rhn_choose_channel.*
%{_datadir}/firstboot/modules/rhn_register_firstboot_gui_window.*
%{_datadir}/firstboot/modules/rhn_start_gui.*
%{_datadir}/firstboot/modules/rhn_choose_server_gui.*
%{_datadir}/firstboot/modules/rhn_provide_certificate_gui.*
%{_datadir}/firstboot/modules/rhn_create_profile_gui.*
%{_datadir}/firstboot/modules/rhn_review_gui.*
%{_datadir}/firstboot/modules/rhn_finish_gui.*
%else
%if 0%{?rhel} < 7
%{_datadir}/firstboot/modules/rhn_register.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_login_gui.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_start_gui.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_choose_server_gui.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_choose_channel.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_provide_certificate_gui.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_create_profile_gui.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_review_gui.*
%{_datadir}/rhn/up2date_client/firstboot/rhn_finish_gui.*
%endif
%endif

%if 0%{?suse_version}
# on SUSE these directories are part of packages not installed
# at buildtime. OBS failed with not owned by any package
%dir %{_datadir}/icons/hicolor
%dir %{_datadir}/icons/hicolor/16x16
%dir %{_datadir}/icons/hicolor/16x16/apps
%dir %{_datadir}/icons/hicolor/24x24
%dir %{_datadir}/icons/hicolor/24x24/apps
%dir %{_datadir}/icons/hicolor/32x32
%dir %{_datadir}/icons/hicolor/32x32/apps
%dir %{_datadir}/icons/hicolor/48x48
%dir %{_datadir}/icons/hicolor/48x48/apps
%dir %{_datadir}/rhn/up2date_client/firstboot
%dir %{_datadir}/firstboot
%dir %{_datadir}/firstboot/modules
%endif

%changelog
* Thu Dec 12 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.13-1
- 1038694 - remove text from registration screen
- 1038694 - new error icon in gnome3

* Mon Dec 09 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.12-1
- 1037778 - new registration icons

* Wed Nov 27 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.11-1
- 1035330 - run TUI registration when executed from setuptool

* Wed Oct 09 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.10-1
- 1017249 - TUI rhn_register: string polish
- 1017249 - GUI rhn_register: string polish

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.9-1
- removed trailing whitespaces

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.8-1
- 994531 - uptime report: respect xmlrpc's integer limits

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.7-1
- Grammar error occurred

* Wed Sep 11 2013 Stephen Herr <sherr@redhat.com> 2.1.6-1
- 988839 - rhn-client-tools can get the variant information from the new place

* Thu Aug 29 2013 Tomas Lestach <tlestach@redhat.com> 2.1.5-1
- fix source string typo

* Wed Aug 28 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.4-1
- No firstboot modules on RHEL 7 and later

* Thu Aug 15 2013 Stephen Herr <sherr@redhat.com> 2.1.3-1
- 919432 - rhn-client-tools should correctly conflict with old virt-host
  versions

* Wed Aug 14 2013 Tomas Lestach <tlestach@redhat.com> 2.1.2-1
- 983999 - put the 1st element of the python search path to the end

* Tue Aug 06 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.1-1
- Branding clean-up of proxy stuff in client dir
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.
- get install time for packages with arch

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.14-1
- Update .po and .pot files for rhn-client-tools.

* Wed Jul 10 2013 Dimitar Yordanov <dyordano@redhat.com> 1.10.13-1
- 983066 - fix rhnreg_ks man page example section

* Tue Jul 09 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.12-1
- 963552 - print prompt on tty instead of stdout

* Thu Jun 27 2013 Dimitar Yordanov <dyordano@redhat.com> 1.10.11-1
- 873784 - Multiple serverURL values could  not end with semicolon

* Wed Jun 19 2013 Jan Dobes 1.10.10-1
- 957506 - unicode support for Remote Command scripts

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.9-1
- rebranding few more strings in client stuff

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.8-1
- rebranding RHN Proxy to Red Hat Proxy in client stuff
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 28 2013 Stephen Herr <sherr@redhat.com> 1.10.7-1
- 948337 - Make client tools only pass up cpu_socket if server has capability
- man pages branding cleanup + misc branding fixes

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.6-1
- branding clean-up of rhel client stuff

* Fri May 03 2013 Stephen Herr <sherr@redhat.com> 1.10.5-1
- 873531 - correctly handle a deactivated account error message

* Thu Apr 25 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.4-1
- setup default presets for client services

* Wed Apr 03 2013 Stephen Herr <sherr@redhat.com> 1.10.3-1
- 947639 - Make timeout of yum-rhn-plugin calls through rhn-client-tools
  configurable

* Mon Mar 25 2013 Stephen Herr <sherr@redhat.com> 1.10.2-1
- Client tools able to pass up socket info

* Wed Mar 20 2013 Miroslav Suchý <msuchy@redhat.com> 1.10.1-1
- rpm macros must not be marked as config file
- Bumping package versions for 1.9
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Feb 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.10-1
- let's enable & start rhnsd properly in systemd

* Mon Feb 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.9-1
- fixed cpu type for ppc64

* Fri Feb 15 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.9.8-1
- fix reading cpuinfo on s390x
- try to get the FQDN as hostname
- Revert "Update rhn_check to send abrt data to the server"
- Updating copyright for 2012
- Update .po and .pot files for rhn-client-tools.
- Download translations from Transifex for rhn-client-tools.

* Mon Dec 10 2012 Jan Pazdziora 1.9.7-1
- 885170 - provide translations of a new error recieved from Hosted
- 882174 - read the hostname from /etc/hostname if needed

* Fri Nov 30 2012 Jan Pazdziora 1.9.6-1
- 876740 - fix typo
- 876740 - server url auto-corrects common mistakes, messages say "Satellite"

* Wed Nov 21 2012 Jan Pazdziora 1.9.5-1
- 876328 - Merging the new translation work form RHEL 6.4
- Revert "876328 - updating rhel client tools translations"

* Fri Nov 16 2012 Stephen Herr <sherr@redhat.com> 1.9.4-1
- 876740 - add server url edit screen to rhn_register tui

* Fri Nov 16 2012 Jan Pazdziora 1.9.3-1
- 876740 - updating error message for rhn_register TUI if SSL cert missing
- 876328 - updating rhel client tools translations
- 823551 - Download icon in "Are you sure" screen of rhn_register is incorrect

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 1.9.2-1
- check if system id has changed
- check if /etc/sysconfig/network is a file
- no hal for openSUSE >= 11.4

* Wed Oct 31 2012 Jan Pazdziora 1.9.1-1
- 871867 - progress bar in rhn-client-tools can now translate its title

* Tue Oct 30 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.26-1
- check CA cert files only when needed

* Tue Oct 30 2012 Jan Pazdziora 1.8.25-1
- Update the copyright year.
- Update .po and .pot files for rhn-client-tools.
- New translations from Transifex for rhn-client-tools.
- Download translations from Transifex for rhn-client-tools.

* Wed Oct 24 2012 Stephen Herr <sherr@redhat.com> 1.8.24-1
- 869814 - removing firstboot and RHN Hosted integration from rhn-client-tools

* Thu Sep 27 2012 Stephen Herr <sherr@redhat.com> 1.8.23-1
- 855992 - fix typo in urlunsplit method call

* Wed Sep 26 2012 Jan Pazdziora 1.8.22-1
- 859281 - translatable strings
- 859281 - rhn-channel: new option to list base channel of a system

* Mon Sep 17 2012 Jan Pazdziora 1.8.21-1
- 823551 - fixing problem with firstboot
- 823551 - gui and text changes for firstboot and rhn_register
- 810389 - rhn_register / firstboot gui minor updates
- 810315 - New "updates availabe" screenshot for firstboot
- 851657 - polish registration strings
- 855992 - make rhn-channel smart enough to use proxy if configured
- 855883 - rhn_check: use gettext correctly when needed

* Mon Sep 10 2012 Jan Pazdziora 1.8.20-1
- 786422 - fixing typo in rhn_register tui

* Thu Aug 30 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.19-1
- workaround missing python-ethtool

* Thu Aug 02 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.18-1
- registerUser is dead since b27c6ad4b90a6c4c3f970fc0f8faefae7c134c9c

* Mon Jul 30 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.17-1
- removed dead code

* Tue Jul 24 2012 Stephen Herr <sherr@redhat.com> 1.8.16-1
- 842836 - Make multi-line lists in conf files parse correctly

* Wed Jul 18 2012 Jan Pazdziora 1.8.15-1
- Update rhn_check to send abrt data to the server

* Fri Jul 13 2012 Jan Pazdziora 1.8.14-1
- 771749 - if the exception is <type 'instance'>, just plain if will fail.

* Thu Jul 12 2012 Stephen Herr <sherr@redhat.com> 1.8.13-1
- 839776 - rhn-profile-sync exits with status 1 if libvirtd is not running

* Tue Jul 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.12-1
- Add missing space to log message
- Fix missing exception scope

* Mon Jul 09 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.11-1
- Fix typo in 'Fatal error in Python code occurred'

* Wed Jul 04 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.10-1
- read memory information even on kernels 3.x

* Sat Jun 16 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.9-1
- allow to set value on Debian

* Sat Jun 16 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.8-1
- workaround problem on suse and debian where you inherit from two same classes

* Sat Jun 16 2012 Miroslav Suchý 1.8.7-1
- allow linking against openssl (msuchy@redhat.com)

* Fri Jun 15 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.6-1
- on Debian use Debian logo

* Fri Jun 15 2012 Miroslav Suchý 1.8.5-1
- fix files header, filese are not released under GPLv2+ but only GPLv2
- fix files headers. our code is under gplv2 license
- %%defattr is not needed since rpm 4.4

* Wed May 02 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.8.4-1
- 816199 - fix package dependency on newt

* Wed Apr 25 2012 Milan Zazrivec <mzazrivec@redhat.com> 1.8.3-1
- 816199 - include package dependency on newt

* Tue Apr 03 2012 Jan Pazdziora 1.8.2-1
- 804559 - not all msgs are CommunicationError objects (mzazrivec@redhat.com)
- 804559 - correct string catenation (mzazrivec@redhat.com)

* Fri Mar 09 2012 Miroslav Suchý 1.8.1-1
- fix typo in man page
- 772070 - classic hosted alignment is no longer needed (mzazrivec@redhat.com)
- 772070 - firstboot gui re-design (mzazrivec@redhat.com)
- 772070 - correct button text (mzazrivec@redhat.com)
- 772070 - new title for "cannot contact server" dialog (mzazrivec@redhat.com)
- 799926 - correct path to rhsm's certlib (mzazrivec@redhat.com)
- Bumping package versions for 1.8. (jpazdziora@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 1.7.14-1
- Update the copyright year info.

* Tue Feb 28 2012 Jan Pazdziora 1.7.13-1
- Update .po and .pot files for rhn-client-tools.
- Download translations from Transifex for rhn-client-tools.

* Mon Feb 27 2012 Simon Lukasik <slukasik@redhat.com> 1.7.12-1
- Do not require libxml2-python (slukasik@redhat.com)

* Mon Feb 27 2012 Jan Pazdziora 1.7.11-1
- 790748 - prevent introspection.
- Make indent more clear.

* Thu Feb 23 2012 Jan Pazdziora 1.7.10-1
- removed unused file (michael.mraka@redhat.com)

* Tue Feb 14 2012 Miroslav Suchý 1.7.9-1
- 781421 - avoid TB if error is in unicode

* Fri Jan 27 2012 Miroslav Suchý 1.7.8-1
- 729342 - fix another TB with errmsg instance

* Wed Jan 18 2012 Miroslav Suchý 1.7.7-1
- 781421 - newt can not accept unicode
- 781421 - sys.stderr.write could not handle decoded unicode

* Tue Jan 17 2012 Miroslav Suchý 1.7.6-1
- implement YumBaseError and RepoError on ImportError if yum cannot be loaded
  (mc@suse.de)

* Tue Jan 17 2012 Jan Pazdziora 1.7.5-1
- Renaming platform to pkgplatform, to avoid clash with the standard python
  module.

* Thu Jan 12 2012 Miroslav Suchý 1.7.4-1
- 746983 - in spacewalk_channel print to STDERR only error message, TB + error
  goes to log file
- 745095 - provide virtualization info when registering via rhn_register
  (tlestach@redhat.com)

* Tue Jan 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.3-1
- 748876 - convert paths to absolute before saving
- 748876 - simplify ConfigFile.save() loop
- 751893 - fix typo

* Mon Jan 09 2012 Miroslav Suchý 1.7.2-1
- 771167 - verify login/password just after user will file it in
- do not print yum-rhn-plugin warning if zypp-plugin is used
- removed dead remaining_subscriptions() (michael.mraka@redhat.com)

* Fri Dec 30 2011 Aron Parsons <parsonsa@bit-sys.com> 1.7.1-1
- continue to search for the hostname if IPv6 is disabled (parsonsa@bit-
  sys.com)

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.46-1
- update copyright info
- 751760 - use __getattr__ rather then __getattribute__ (msuchy@redhat.com)

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.45-1
- updated translations

* Tue Dec 20 2011 Miroslav Suchý 1.6.44-1
- 744111 - notify subscription-manager to recheck compliance status

* Fri Dec 16 2011 Jan Pazdziora 1.6.43-1
- Revert "always return RPC data in plain string (utf-8 encoded)"

* Tue Dec 13 2011 Jan Pazdziora 1.6.42-1
- Fixing typo.

* Mon Dec 12 2011 Jan Pazdziora 1.6.41-1
- 703833 - if /sbin/service is not available, try to use /usr/sbin/service.

* Fri Dec 09 2011 Miroslav Suchý 1.6.40-1
- 569790 - for scope on rhel5 do s/global/universe/

* Fri Dec 02 2011 Miroslav Suchý 1.6.39-1
- IPv6: first try findHostByRoute() and then try getaddrinfo()
- IPv6: assign to hostname only if we are unable to resolve it
- IPv6: IPv4 is most probably set up better, lets overwrite IPv6 values (if
  mismatch)
- 743259 - take hostname of client instead of server

* Tue Nov 29 2011 Miroslav Suchý 1.6.38-1
- define __init__, __getattribute__, __setattr__ on Debian and workaround those
  mising methods on RHEL5

* Thu Nov 24 2011 Jan Pazdziora 1.6.37-1
- 735346 - add space after do_call in cases like
  do_callpackages.checkNeedUpdate(rhnsd=1,){}.

* Mon Nov 21 2011 Miroslav Suchý 1.6.36-1
- 751760 - make errmsg as an alias to value (for setter too)

* Mon Nov 21 2011 Miroslav Suchý 1.6.35-1
- 751760 - make errmsg as an alias to value

* Mon Nov 07 2011 Miroslav Suchý 1.6.34-1
- call parent's constructor
- 751760 - use attribute value, which our ancestor use
- correctly assign converted unicode string
- correctly check for unicode type

* Thu Nov 03 2011 Miroslav Suchý 1.6.33-1
- 595837 - add missing import

* Wed Nov 02 2011 Miroslav Suchý 1.6.32-1
- 595837 - all up2date bugs now inherit from YumBaseError so yum/pup can catch
  them

* Tue Nov 01 2011 Miroslav Suchý 1.6.31-1
- 595837 - properly handle two exceptions (msuchy@redhat.com)

* Tue Nov 01 2011 Tomas Lestach <tlestach@redhat.com> 1.6.30-1
- 706148 - fix setting uri (luvilla@redhat.com)

* Mon Oct 31 2011 Miroslav Suchý 1.6.29-1
- 743259 - initialize variable before use

* Fri Oct 28 2011 Jan Pazdziora 1.6.28-1
- add missing import (mzazrivec@redhat.com)

* Fri Oct 21 2011 Jan Pazdziora 1.6.27-1
- Pass the verbose option (-vv) from rhnreg_ks to rhn_check as well.

* Fri Oct 21 2011 Miroslav Suchý 1.6.26-1
- 627809 - send xen virtual block devices to rhnParent
- Revert "729161 - default to RHSM in firstboot registration"
  (mzazrivec@redhat.com)

* Wed Oct 19 2011 Miroslav Suchý 1.6.25-1
- 743259 - RHEL5 now has python-ethtool 0.6 - simplify code
- 743259 - get_ipv6_addresses does not return one item, but list
- 745438 - up2date_config: use localhost to avoid confusion
  (mzazrivec@redhat.com)

* Tue Oct 18 2011 Miroslav Suchý 1.6.24-1
- move errata.py action to the yum-rhn-plugin package (iartarisi@suse.cz)

* Tue Oct 11 2011 Tomas Lestach <tlestach@redhat.com> 1.6.23-1
- 706148 - set _uri, when connecting to a different server (luvilla@redhat.com)

* Fri Oct 07 2011 Miroslav Suchý 1.6.22-1
- 743259 - if IPv6 is not present, send empty string instead of None

* Thu Oct 06 2011 Miroslav Suchý 1.6.21-1
- 743259 - send IPv6 addresses only if server support it

* Thu Oct 06 2011 Miroslav Suchý 1.6.20-1
- 743259 - really send ipv6 address

* Tue Oct 04 2011 Miroslav Suchý 1.6.19-1
- 743259 - support for IPv6

* Mon Oct 03 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.18-1
- require rhnlib with IDN stuff

* Mon Sep 19 2011 Martin Minar <mminar@redhat.com> 1.6.17-1
- 688072 - polish registration welcome message a bit (mzazrivec@redhat.com)

* Fri Sep 09 2011 Jan Pazdziora 1.6.16-1
- 576223 - make rhn-profile-sync write errors to stderr.

* Wed Aug 24 2011 Martin Minar <mminar@redhat.com> 1.6.15-1
- Revert "727908 - registration: send correct hostname during kickstart"
  (mzazrivec@redhat.com)

* Wed Aug 17 2011 Martin Minar <mminar@redhat.com> 1.6.14-1
- 729468 - TUI: polish registration messages (mzazrivec@redhat.com)

* Fri Aug 12 2011 Miroslav Suchý 1.6.13-1
- do not verify md5, size and mtime for /etc/sysconfig/rhn/up2date

* Thu Aug 11 2011 Jan Pazdziora 1.6.12-1
- 729161 - default to RHSM in firstboot registration (mzazrivec@redhat.com)
- 729468 - firstboot dialogs polishing (mzazrivec@redhat.com)

* Thu Aug 11 2011 Miroslav Suchý 1.6.11-1
- do not mask original error by raise in execption

* Thu Aug 11 2011 Martin Minar <mminar@redhat.com> 1.6.10-1
- 702084 - always print trailing newline for error messages
  (mzazrivec@redhat.com)

* Wed Aug 10 2011 Martin Minar <mminar@redhat.com> 1.6.9-1
- 684913 - fix SSLCertificateVerifyFailedError exception message
  (mzazrivec@redhat.com)

* Fri Aug 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.8-1
- convert args to string first

* Thu Aug 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.7-1
- the latest yum-rhn-plugin and rhn-client-tools require each other

* Thu Aug 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.6-1
- 710065 - handle unicode log messages
- 710065 - handle unicode error messages
- merged duplicated code to NoLogError class
- moved duplicated code to base Error class
- 684250 - correct priority for initial registration screen

* Thu Aug 04 2011 Martin Minar <mminar@redhat.com> 1.6.5-1
- 727908 - registration: send correct hostname during kickstart
  (mzazrivec@redhat.com)

* Wed Aug 03 2011 Martin Minar <mminar@redhat.com> 1.6.4-1
- 702107 - cogent error message for exception when listing child channels
  (mzazrivec@redhat.com)

* Tue Aug 02 2011 Martin Minar <mminar@redhat.com> 1.6.3-1
- 702084 - rhn-channel: meaningful message when wrong username / password
  (mzazrivec@redhat.com)

* Thu Jul 28 2011 Jan Pazdziora 1.6.2-1
- 713548 - enable running rhn-channel on RHEL5 (tlestach@redhat.com)
- 713548 - enable running rhn-channel against both RHN and RHN Satellite
  (tlestach@redhat.com)

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- The rhn-client-tools/doc/releases.txt is out of date, removing.
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Tue Jul 19 2011 Jan Pazdziora 1.5.16-1
- Merging Transifex changes for rhn-client-tools.
- Fixing the `msgid' and `msgstr' entries do not both end with '\n' bug.
- Download translations from Transifex for rhn-client-tools.

* Tue Jul 19 2011 Jan Pazdziora 1.5.15-1
- update .po and .pot files for rhn-client-tools

* Tue Jun 21 2011 Jan Pazdziora 1.5.14-1
- 714113 - handle writing unicode to log file (msuchy@redhat.com)

* Wed Jun 15 2011 Miroslav Suchý 1.5.13-1
- forward port translation from RHEL6 (msuchy@redhat.com)
- forward port translation from RHEL5 (msuchy@redhat.com)

* Wed Jun 15 2011 Jan Pazdziora 1.5.12-1
- forward port translation from RHEL5 (msuchy@redhat.com)

* Tue Jun 14 2011 Miroslav Suchý 1.5.11-1
- forward port translation from RHEL5 (msuchy@redhat.com)
- forward port translation from RHEL5 (msuchy@redhat.com)
- add missing \n and hyperlink to zh_TW (msuchy@redhat.com)
- add missing \n and hyperlink to zh_CN (msuchy@redhat.com)
- fix typo in te.po (msuchy@redhat.com)

* Mon Jun 13 2011 Jan Pazdziora 1.5.10-1
- forward port translation from RHEL5 (msuchy@redhat.com)
- Download translations from Transifex for rhn-client-tools (msuchy@redhat.com)

* Tue May 31 2011 Jan Pazdziora 1.5.9-1
- fix typo (msuchy@redhat.com)

* Mon May 23 2011 Miroslav Suchý 1.5.8-1
- 683200 - u'foo'.decode('utf-8') does not work, while unicode(u'foo') works
  and is idempotent (msuchy@redhat.com)
- 683200 - if I want url in unicode, I must us decode - remember that
  (msuchy@redhat.com)

* Thu Apr 28 2011 Simon Lukasik <slukasik@redhat.com> 1.5.7-1
- The Debian client on x86_64 should send amd64-debian-linux
  (slukasik@redhat.com)

* Sun Apr 17 2011 Simon Lukasik <slukasik@redhat.com> 1.5.6-1
- Codename might not be always present within lsb_release on Debian
  (slukasik@redhat.com)

* Sat Apr 16 2011 Simon Lukasik <slukasik@redhat.com> 1.5.5-1
- Do not import yum on Debian platform (slukasik@redhat.com)

* Fri Apr 15 2011 Jan Pazdziora 1.5.3-1
- modify spec file to build rhn-client-tools on SUSE (mc@suse.de)
- get model id from PRODUCT key (msuchy@redhat.com)
- <type exceptions.UnboundLocalError>: local variable usb referenced before
  assignment (msuchy@redhat.com)

* Wed Apr 13 2011 Jan Pazdziora 1.5.2-1
- Revert "some usb device may not return product" (msuchy@redhat.com)
- fix typo in key "product" vs. "PRODUCT" (msuchy@redhat.com)
- some usb device may not return product (msuchy@redhat.com)

* Tue Apr 12 2011 Miroslav Suchý 1.5.1-1
- enhance getOSVersionAndRelease to find SUSE distributions (mc@suse.de)
- Bumping package versions for 1.5 (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 1.4.15-1
- fix fr translation (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 1.4.14-1
- Revert "idn_unicode_to_pune() have to return string" (msuchy@redhat.com)

* Fri Apr 08 2011 Miroslav Suchý 1.4.13-1
- update copyright years (msuchy@redhat.com)
- download spacewalk.rhn-client-tools from Transifex (msuchy@redhat.com)

* Wed Apr 06 2011 Simon Lukasik <slukasik@redhat.com> 1.4.12-1
- Move code for enabling yum-rhn-plugin to separate module
  (slukasik@redhat.com)
- Extract method: setDebugVerbosity (slukasik@redhat.com)
- Introduce pkgUtils as an abstraction of either debUtils or rpmUtils
  (slukasik@redhat.com)
- Introduce Debian equivalent of rpmUtils. (slukasik@redhat.com)
- Removing packages.verifyAll capability; it was never used.
  (slukasik@redhat.com)
- OS information is platform dependent; introducing a platform interface.
  (slukasik@redhat.com)
- versionOverride applies only to version; moving to getVersion
  (slukasik@redhat.com)
- Updated unittests (slukasik@redhat.com)

* Tue Apr 05 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.11-1
- idn_unicode_to_pune() has to return string

* Mon Apr 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.10-1
- urlsplit returns tuple on RHEL5
- 691188 - inherit SSLCertificateVerifyFailedError from RepoError

* Wed Mar 30 2011 Miroslav Suchý 1.4.9-1
- 683200 - support IDN
- 691837 - default to RHN Classic in firstboot (mzazrivec@redhat.com)

* Thu Mar 24 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.8-1
- utilize config.getServerlURL()
- atomic save of /etc/sysconfig/rhn/up2date

* Thu Mar 17 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.7-1
- 680124 - do not count cpu from /proc/cpuinfo, but use /sys/devices/system/cpu

* Wed Mar 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.6-1
- 684245 - lookup of the subscription-manager page via localized title is
  volatile, let's use its __module__ name. (jpazdziora@redhat.com)
- 624748 - report virtual network interfaces (mzazrivec@redhat.com)

* Fri Mar 11 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.5-1
- declare that we are using utf-8

* Thu Mar 10 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.4-1
- 683546 - optparse isn't friendly to translations in unicode
- update .po files
- 679217 - mention subscription manager as alternative to rhn_register

* Tue Mar 01 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.3-1
- Revert "provide path to puplet-screenshot.png" (msuchy@redhat.com)
- 666860 - remove glade warnings (msuchy@redhat.com)
- provide path to puplet-screenshot.png (msuchy@redhat.com)
- move <accessibility> in front of <signal> (msuchy@redhat.com)
- 580479 - do not let combo box to fill available space (msuchy@redhat.com)
- 651792 - if system is not registered, print nice error insted of TB
  (msuchy@redhat.com)
- 651857 - fix typo in variable name (msuchy@redhat.com)
- 671039 - do not Traceback if system was never registered (msuchy@redhat.com)

* Wed Feb 16 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.2-1
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)

* Tue Feb 08 2011 Miroslav Suchý <msuchy@redhat.com> 1.4.1-1
- fix typo
- 671039 - add warning about subsription manager to TUI part of rhn_register
- 671039 - add warning about subsription manager to GUI part of rhn_register
- l10n: Updates to German (de) translation (delouw@fedoraproject.org)
- 671041 - substitute RHN with "RHN Satellite or RHN Classic"
- 671032 - disable rhnplugin by default and enable it only after successful
  registration
- Bumping package versions for 1.4 (tlestach@redhat.com)

* Mon Jan 31 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.12-1
- cp firstboot/rhn_choose_channel.py firstboot-legacy-rhel5/

* Fri Jan 28 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.11-1
- break circular import
- 580479 - put new submodule into package
- W: 28: Unused import glade
- 580479 - Graphical firstboot should offer EUS channel selection
- 581482 - make tui consistent with gui
- 596108 - firstboot: don't allow multiple system registrations
- 606222 - label could not have focus

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 1.3.10-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- update .po and .pot files for rhn-client-tools (tlestach@redhat.com)
- 602609 - fix DeprecationWarning when using gtk.MessageDialog()
  (mzazrivec@redhat.com)
- 617066 - fix "Why register" dialog size (msuchy@redhat.com)
- 667739 - use accessibility tags (msuchy@redhat.com)
- 626752 - correct virt. type detection for RHEL-6 FV Xen guests
  (mzazrivec@redhat.com)
- 651403 - reference to RHEL6 as actuall system (msuchy@redhat.com)
- dead code: removal of function foobar() (msuchy@redhat.com)
- 649233 - reset busy mouse cursor back to arrow after unexpected error
  (msuchy@redhat.com)

* Mon Jan 17 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.9-1
- Revert "update .po and .pot files for rhn-client-tools"
- Revert "removing msgctxt which rhel5 could not handle"

* Mon Jan 17 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.8-1
- removing msgctxt which rhel5 could not handle

* Mon Jan 17 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.7-1
- update .po and .pot files for rhn-client-tools
- 651789 - fail if adding/removal of channels fail
- 651792 - list all available child channels related to system
- localize spacewalk-channel script
- 651857 - print error if you specify --add or --remove, but you do not specify
  any channel
- 651857 - removing forgotten lines, which makes no sense and cause TB
- 652424 - return back useNoSSLForPackages option
- 668809 - mention the requirement to use FQDN

* Wed Jan 05 2011 Miroslav Suchý <msuchy@redhat.com> 1.3.6-1
- 665013 - do not send None for ipaddr in IPv6 only system

* Tue Jan 04 2011 Jan Pazdziora 1.3.5-1
- 666860 - Add support for subscription-manager in firstboot.

* Tue Dec 14 2010 Jan Pazdziora 1.3.4-1
- l10n: Updates to Malayalam (ml) translation (anipeter@fedoraproject.org)

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.3-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Fri Dec 03 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.2-1
- on el5 do not send IPv6 addresses (msuchy@redhat.com)

* Sat Nov 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.3.1-1
- 655310 - replace gethostbyname by getaddrinfo (msuchy@redhat.com)
- 655310 - send IPv6 addresses to server (msuchy@redhat.com)
- 481721 - _ts report epoch as int, but satelite and rhn use string, this does
  not work for comparement like pkg in [['name', 'version', 'release', 'epoch',
  'arch']..] (msuchy@redhat.com)
- Bumping package versions for 1.3. (jpazdziora@redhat.com)

* Wed Nov 10 2010 Jan Pazdziora 1.2.15-1
- rebuild

* Wed Nov 10 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.14-1
- 650520 - allow # in password

* Wed Nov 03 2010 Jan Pazdziora 1.2.13-1
- Update .po and .pot files for rhn-client-tools (fix for RHEL 5).

* Tue Nov 02 2010 Jan Pazdziora 1.2.12-1
- Clearing msgctx which is not supported by gettext on RHEL 5.

* Tue Nov 02 2010 Jan Pazdziora 1.2.11-1
- Update copyright years in the rest of the repo.
- update .po and .pot files for rhn-client-tools
- require versions which can handle cache_only (msuchy@redhat.com)

* Mon Oct 25 2010 Jan Pazdziora 1.2.10-1
- correct man page acording to reality (msuchy@redhat.com)

* Tue Oct 12 2010 Jan Pazdziora 1.2.9-1
- l10n: Updates to Panjabi (Punjabi) (pa) translation (jassy@fedoraproject.org)

* Thu Sep 30 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.8-1
- 638981 - encode smbios data before sending over xmlrpc (msuchy@redhat.com)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)

* Tue Sep 14 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.7-1
- 632203 - fix comment to corespond with code, decoding unicode to unicode
  produce traceback (msuchy@redhat.com)
- l10n: Updates to Oriya (or) translation (mgiri@fedoraproject.org)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)

* Tue Aug 31 2010 Jan Pazdziora 1.2.6-1
- 603028 - when checking package architecture during errata update, allow
  transition to and from noarch.

* Tue Aug 31 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.5-1
- 621135 - report resonable cpuinfo in s390(x)

* Mon Aug 30 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.4-1
- 559797 - fixed configuration file name
- Sort the available channels so that the listing is not random.

* Wed Aug 25 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.3-1
- 626822 - don't submit action result in cache only mode

* Tue Aug 24 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.2-1
- 625778 - require newer yum-rhn-plugin
- 554693 - networkRetries should be positive number
- l10n: Updates to Russian (ru) translation
- l10n: Updates to Telugu (te) translation

* Thu Aug 12 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.2.1-1
- 623137 - merge translated strings with .desktop file (mzazrivec@redhat.com)
- update .po and .pot files for rhn-client-tools (msuchy@redhat.com)

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 1.1.14-1
- 618267 - all data in F12+ should be in unicode, lets decode it
- 619098 - take manufacturer from system group
- 618267 - add missing import and foo
- update .po files
- Revert "update .po files"
- 618267 - encode latin-1 characters to unicode
- 617425 - add missing 'the's
- 617425 - point the user to the correct menu item
- add man page for rhn-channel as alias for spacewalk-channel
- default for kwargs should be {}
- update .po files
- 616371 - typo fix
- add parameter cache_only to up2date_config.* actions
- enable caching for action errata.update

* Tue Jul 20 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.13-1
- add parameter cache_only to all client actions (msuchy@redhat.com)
- simplify code (msuchy@redhat.com)
- put parser of action xml to separate function (msuchy@redhat.com)
- l10n: Updates to Italian (it) translation (fvalen@fedoraproject.org)

* Mon Jul 19 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.12-1
- we want to pre-cache if server *has* staging ability (msuchy@redhat.com)
- use correct rhnserver class (msuchy@redhat.com)
- l10n: Updates to Swedish (sv) translation (goeran@fedoraproject.org)

* Thu Jul 15 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.11-1
- 614389 - add missing import (msuchy@redhat.com)
- basic framework for prefetching content from spacewalk (msuchy@redhat.com)

* Fri Jul 09 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.10-1
- 604106 - finish page should be loaded even without network
  (msuchy@redhat.com)
- 612547 - update copyright clauses up until 2010. (jpazdziora@redhat.com)
- 607599 - prevent firstboot from show_all()-ing what we have hidden.
  (jpazdziora@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.9-1
- Clean up a few remaining references to kbase 6227
  (joshua.roys@gtri.gatech.edu)
- 604101 - kbase article 6227 changed name & location (mzazrivec@redhat.com)

* Fri Jun 18 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.8-1
- fix syntax error (msuchy@redhat.com)

* Thu Jun 17 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.7-1
- l10n: Updates to Chinese (China) (zh_CN) translation
  (leahliu@fedoraproject.org)
- 601683 - properly import get_computer_info routine (mzazrivec@redhat.com)
- 596237 - use correct constant in HardwareWindow (tui) (mzazrivec@redhat.com)
- 596237 - use constants in SendingWindow (mzazrivec@redhat.com)
- 596237 - use constants in SendWindow (mzazrivec@redhat.com)
- 596237 - use constants in PackagesWindow (mzazrivec@redhat.com)
- 596237 - use constants in HardwareWindow (mzazrivec@redhat.com)
- 596237 - use constants in OSReleaseWindow & AlreadyRegisteredWindow
  (mzazrivec@redhat.com)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)
- 600316 - don't traceback for zero subscribed channels (mzazrivec@redhat.com)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)
- l10n: Updates to Russian (ru) translation (ypoyarko@fedoraproject.org)
- l10n: Updates to Spanish (Castilian) (es) translation
  (gguerrer@fedoraproject.org)
- 598890 - always return product version as string (mzazrivec@redhat.com)
- l10n: Updates to Spanish (Castilian) (es) translation
  (gguerrer@fedoraproject.org)
- Remove three more exceptions that are not used in our code base.
  (jpazdziora@redhat.com)
- The rhn-client-tools ChangeLog has't been updated since 2002, removing.
  (jpazdziora@redhat.com)
- Removing WarningDialog, OkDialog, and QuestionDialog that are not used in our
  code. (jpazdziora@redhat.com)
- Remove 23 exceptions that are not used in our code base.
  (jpazdziora@redhat.com)
- Method resetServerList not used in our code, removing.
  (jpazdziora@redhat.com)
- When startRhnCheck was replaced by spawnRhnCheckForUI, it became unused,
  removing. (jpazdziora@redhat.com)
- Method getFailedSystemSlots not used in our code, removing.
  (jpazdziora@redhat.com)
- get_device_property not used in our code, removing. (jpazdziora@redhat.com)
- termsAndConditions not used in our code, removing. (jpazdziora@redhat.com)
- sat_supports_virt_guest_registration not used in our code, removing.
  (jpazdziora@redhat.com)
- finishMessage not used in our code, removing. (jpazdziora@redhat.com)
- When autoActivateNumbersOnce was removed, autoActivatedHardwareInfo was made
  unused, removing. (jpazdziora@redhat.com)
- When ActivateSubscriptionPage was removed, activatedRegistrationNumber was
  made unused, removing. (jpazdziora@redhat.com)
- 597263 - give the focus to the ButtonBar (and thus to the Yes button), to
  behave as RHEL 5 did. (jpazdziora@redhat.com)
- 596101 - skip the chooseChannelPage when going Back as well, if it should not
  be shown. (jpazdziora@redhat.com)
- 596102 - fit hw profile into a 2x6 table (mzazrivec@redhat.com)
- 595688 - cancel busy cursor after ValidationError (michael.mraka@redhat.com)
- 595837 - write nice error in case of "connection reset by peer" and xmlrpc
  protocol error (msuchy@redhat.com)
- 585188 - we need to implement fatalError for loginPageApply and
  createProfilePageApply. (jpazdziora@redhat.com)
- Remove except which cannot be reached. (jpazdziora@redhat.com)
- 585188 - refactor the RHN Register firstboot code to match firstboot 1.110 on
  Fedora 12 and RHEL 6. (jpazdziora@redhat.com)
- 585188 - only install legacy firstboot on RHEL 5 (and earlier), the new
  firstboot for other systems. (jpazdziora@redhat.com)
- 585188 - the firstboot modules for RHEL 5 shall retire in firstboot-legacy-
  rhel5. (jpazdziora@redhat.com)
- 593194 - fix creating the $(PREFIX)/usr/share/setuptool/setuptool.d when
  building the package. (jpazdziora@redhat.com)
- 595669 - fix regexp and do not fail if regexp do not match
  (msuchy@redhat.com)
- whitespace cleanup (msuchy@redhat.com)
- We don't need hwdata target anymore (mzazrivec@redhat.com)
- 580493 - use correct product logos in rhn_register (gui)
  (mzazrivec@redhat.com)
- 557059 - do not fail on IBM-ESXS controler where ID_PATH is not set
  (msuchy@redhat.com)
- 580489 - fix requires for rhn-setup-gnome (mzazrivec@redhat.com)
- python-hwdata finaly made it into Fedora and Epel so we can remove from this
  package and depend on python-hwdata (msuchy@redhat.com)
- 593194 - 99rhn_register to add RHN Register to setup's list of tools.
  (jpazdziora@redhat.com)
- The bugzilla 556290 had errata released, python-setuptools should be pulled
  in by python-coverage. (jpazdziora@redhat.com)
- 584780 - move the firstboot _gui.* files to rhn-setup-gnome.
  (jpazdziora@redhat.com)
- 557059 - we cannot have class None. (jpazdziora@redhat.com)
- 591798  - Completly remove hal code from rhn-client-tools for F-13 and RHEL-6
  (msuchy@redhat.com)
- 591422 - add hwdata.py to rhn-client-tools. (jpazdziora@redhat.com)
- l10n: Updates to German (de) translation (ttrinks@fedoraproject.org)
- l10n update .pot and .po files for rhn-client-tools (msuchy@redhat.com)
- l10n - translate desktop file too (msuchy@redhat.com)
- cleanup - removing translation file, which does not match any language code
  (msuchy@redhat.com)
- update po files for rhn-client-tools (msuchy@redhat.com)

* Wed May 05 2010 Jan Pazdziora 1.1.3-1
- 589100 - address issue when clients were not able to register to the server.

* Thu Apr 29 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.2-1
- 585386 - do not fail if file do not exist
- bump up version

* Wed Apr 28 2010 Miroslav Suchý <msuchy@redhat.com> 1.0.1-1
- 585386 - set properly acl for /var/spool/up2date/loginAuth.pkl
- make read_cpuinfo() more readable

* Thu Apr 08 2010 Jan Pazdziora 1.0.0-1
- Bumping up version to 1.0.0.

