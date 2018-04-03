%if 0%{?fedora} || 0%{?suse_version} > 1320 || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%if ( 0%{?fedora} && 0%{?fedora} < 28 ) || ( 0%{?rhel} && 0%{?rhel} < 8 )
%global build_py2   1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}
%{!?python2_sitelib: %global python2_sitelib %(python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

Summary: Support programs and libraries for Red Hat Satellite or Spacewalk
Name: rhn-client-tools
Version: 2.9.0
Release: 1%{?dist}
License: GPLv2
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
URL:     https://github.com/spacewalkproject/spacewalk
BuildArch: noarch
%if 0%{?suse_version}
BuildRequires: update-desktop-files
%endif

Requires: rpm >= 4.2.3-24_nonptl
Requires: gnupg
Requires: coreutils
Requires: %{pythonX}-%{name} = %{version}-%{release}

%if 0%{?suse_version}
Requires: zypper
%else
%if 0%{?fedora} || 0%{?rhel} >= 8
Requires: dnf
%else
Requires: yum
%endif # 0%{?fedora}
%endif # 0%{?suse_version}

Conflicts: up2date < 5.0.0
Conflicts: yum-rhn-plugin < 1.6.4-1
Conflicts: rhncfg < 5.9.23-1
Conflicts: spacewalk-koan < 0.2.7-1
Conflicts: rhn-kickstart < 5.4.3-1
Conflicts: rhn-virtualization-host < 5.4.36-2

BuildRequires: gettext
BuildRequires: intltool
BuildRequires: desktop-file-utils

%if 0%{?fedora}
BuildRequires: fedora-logos
BuildRequires: dnf
%endif

%if 0%{?rhel}
BuildRequires: redhat-logos
%if 0%{?rhel} >= 8
BuildRequires: dnf
%else
BuildRequires: yum
%endif
%endif

%description
Red Hat Satellite Client Tools provides programs and libraries to allow your
system to receive software updates from Red Hat Satellite or Spacewalk.

%if 0%{?build_py2}
%package -n python2-%{name}
Summary: Support programs and libraries for Red Hat Satellite or Spacewalk
%{?python_provide:%python_provide python2-%{name}}
Requires: %{name} = %{version}-%{release}
Requires: rpm-python
Requires: python-dmidecode
Requires: python-ethtool >= 0.4
Requires: rhnlib >= 2.5.78
BuildRequires: python-devel

%if 0%{?fedora}
Requires: pygobject2
Requires: libgudev
Requires: python-hwdata
%else
%if 0%{?suse_version} >= 1140
Requires: python-pyudev
Requires: python-hwdata
%else
%if 0%{?rhel} > 5
Requires: python-gudev
Requires: python-hwdata
%else
Requires: hal >= 0.5.8.1-52
%endif # 0%{?rhel} > 5
%endif # 0%{?suse_version} >= 1140
%endif # 0%{?fedora}

%if 0%{?rhel} == 5 
Requires: newt
%endif

%if 0%{?rhel} > 5 || 0%{?fedora}
Requires: newt-python
%endif

%if 0%{?suse_version}
Requires: dbus-1-python
Requires: python-newt
%else
Requires: dbus-python
%endif # 0%{?suse_version}

# The following BuildRequires are for check only
BuildRequires: python-coverage
BuildRequires: rpm-python
Requires: rhnlib >= 2.5.78

%description -n python2-%{name}
Python 2 specific files of %{name}.
%endif

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: Support programs and libraries for Red Hat Satellite or Spacewalk
%{?python_provide:%python_provide python3-%{name}}
Requires: %{name} = %{version}-%{release}
%if 0%{?suse_version} >= 1140
Requires: python3-dbus-python
Requires: python3-newt
Requires: python3-pyudev
%else
Requires: libgudev
Requires: python3-dbus
Requires: newt-python3
Requires: python3-gobject-base
%endif
Requires: python3-rpm
Requires: python3-dmidecode
Requires: python3-netifaces
Requires: python3-hwdata
Requires: python3-rhnlib >= 2.5.78
BuildRequires: python3-devel

# The following BuildRequires are for check only
BuildRequires: python3-coverage
BuildRequires: python3-rpm
Requires: python3-rhnlib >= 2.5.78

%description -n python3-%{name}
Python 3 specific files of %{name}.
%endif


%package -n rhn-check
Summary: Check for RHN actions
Requires: %{name} = %{version}-%{release}
Requires: %{pythonX}-rhn-check = %{version}-%{release}
%if 0%{?suse_version}
Requires: zypp-plugin-spacewalk
%else
%if 0%{?fedora} || 0%{?rhel} >= 8
Requires: dnf-plugin-spacewalk >= 2.4.0
%else
Requires: yum-rhn-plugin >= 1.6.4-1
%endif
%endif

%description -n rhn-check
rhn-check polls a Red Hat Satellite or Spacewalk server to find and execute
scheduled actions.

%if 0%{?build_py2}
%package -n python2-rhn-check
Summary: Check for RHN actions
%{?python_provide:%python_provide python2-rhn-check}
Requires: rhn-check = %{version}-%{release}

%description -n python2-rhn-check
Python 2 specific files for rhn-check.
%endif

%if 0%{?build_py3}
%package -n python3-rhn-check
Summary: Support programs and libraries for Red Hat Satellite or Spacewalk
%{?python_provide:%python_provide python3-rhn-check}
Requires: rhn-check = %{version}-%{release}

%description -n python3-rhn-check
Python 3 specific files for rhn-check.
%endif


%package -n rhn-setup
Summary: Configure and register an RHN/Spacewalk client
Requires: %{pythonX}-rhn-setup = %{version}-%{release}
%if 0%{?fedora} || 0%{?rhel}
Requires: usermode >= 1.36
%endif
Requires: %{name} = %{version}-%{release}
Requires: rhnsd

%description -n rhn-setup
rhn-setup contains programs and utilities to configure a system to use
Red Hat Satellite or Spacewalk, and to register a system with a Red Hat Satellite or Spacewalk server.

%if 0%{?build_py2}
%package -n python2-rhn-setup
Summary: Configure and register an RHN/Spacewalk client
%{?python_provide:%python_provide python2-rhn-setup}
Requires: rhn-setup = %{version}-%{release}
%if 0%{?rhel} == 5
Requires: newt
%endif
%if 0%{?fedora} || 0%{?rhel} > 5
Requires: newt-python
%endif

%description -n python2-rhn-setup
Python 2 specific files for rhn-setup.
%endif

%if 0%{?build_py3}
%package -n python3-rhn-setup
Summary: Configure and register an RHN/Spacewalk client
%{?python_provide:%python_provide python3-rhn-setup}
Requires: rhn-setup = %{version}-%{release}
Requires: newt-python3

%description -n python3-rhn-setup
Python 3 specific files for rhn-setup.
%endif


%package -n rhn-setup-gnome
Summary: A GUI interface for RHN/Spacewalk Registration
Requires: %{name} = %{version}-%{release}
Requires: %{pythonX}-rhn-setup = %{version}-%{release}
Requires: %{pythonX}-rhn-setup-gnome = %{version}-%{release}
Requires: rhn-setup = %{version}-%{release}
Requires: pam >= 0.72

%description -n rhn-setup-gnome
rhn-setup-gnome contains a GTK+ graphical interface for configuring and
registering a system with a Red Hat Satellite or Spacewalk server.

%if 0%{?build_py2}
%package -n python2-rhn-setup-gnome
Summary: Configure and register an RHN/Spacewalk client
%{?python_provide:%python_provide python2-rhn-setup-gnome}
Requires: rhn-setup-gnome = %{version}-%{release}
%if 0%{?suse_version}
Requires: python-gnome python-gtk
%else
Requires: pygtk2 pygtk2-libglade
Requires: usermode-gtk
%endif
%if 0%{?fedora} || 0%{?rhel} > 5
Requires: liberation-sans-fonts
%endif

%description -n python2-rhn-setup-gnome
Python 2 specific files for rhn-setup-gnome.
%endif

%if 0%{?build_py3}
%package -n python3-rhn-setup-gnome
Summary: Configure and register an RHN/Spacewalk client
%{?python_provide:%python_provide python3-rhn-setup-gnome}
Requires: rhn-setup-gnome = %{version}-%{release}
%if 0%{?suse_version}
Requires: python-gnome python-gtk
%else
Requires: python3-gobject-base gtk3
# gtk-builder-convert
BuildRequires: gtk2-devel
%endif
%if 0%{?fedora} || 0%{?rhel} > 5
Requires: liberation-sans-fonts
%endif

%description -n python3-rhn-setup-gnome
Python 3 specific files for rhn-setup-gnome.
%endif


%prep
%setup -q 

%build
make -f Makefile.rhn-client-tools

%install
%if 0%{?build_py2}
make -f Makefile.rhn-client-tools install VERSION=%{version}-%{release} \
        PYTHONPATH=%{python_sitelib} PYTHONVERSION=%{python_version} \
        PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir}
%endif
%if 0%{?build_py3}
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' src/actions/*.py src/bin/*.py test/*.py
make -f Makefile.rhn-client-tools
for g in data/*.glade ; do
        mv $g $g.old
        gtk-builder-convert $g.old $g
done
sed -i 's/GTK_PROGRESS_LEFT_TO_RIGHT/horizontal/' data/progress.glade
sed -i 's/GtkComboBox/GtkComboBoxText/; /property name="has_separator"/ d;' data/rh_register.glade
sed -i '/class="GtkVBox"/ {
                s/GtkVBox/GtkBox/;
                a \ \ \ \ \ \ \ \ <property name="orientation">vertical</property\>
                }' data/gui.glade
make -f Makefile.rhn-client-tools install VERSION=%{version}-%{release} \
        PYTHONPATH=%{python3_sitelib} PYTHONVERSION=%{python3_version} \
        PREFIX=$RPM_BUILD_ROOT MANPATH=%{_mandir}
%endif

ln -sf consolehelper $RPM_BUILD_ROOT%{_bindir}/rhn_register
ln -s spacewalk-channel $RPM_BUILD_ROOT%{_sbindir}/rhn-channel

mkdir -p $RPM_BUILD_ROOT/var/lib/up2date
mkdir -pm700 $RPM_BUILD_ROOT%{_localstatedir}/spool/up2date
touch $RPM_BUILD_ROOT%{_localstatedir}/spool/up2date/loginAuth.pkl
%if 0%{?fedora}
mkdir -p $RPM_BUILD_ROOT/%{_presetdir}
install 50-spacewalk-client.preset $RPM_BUILD_ROOT/%{_presetdir}
%endif

%if 0%{?build_py2}
%if 0%{?fedora} || 0%{?rhel} > 5 || 0%{?suse_version} >= 1140
rm $RPM_BUILD_ROOT%{python_sitelib}/up2date_client/hardware_hal.*
%else
rm $RPM_BUILD_ROOT%{python_sitelib}/up2date_client/hardware_gudev.*
rm $RPM_BUILD_ROOT%{python_sitelib}/up2date_client/hardware_udev.*
%endif
%endif

%if 0%{?rhel} == 5
%if 0%{?build_py2}
rm -rf $RPM_BUILD_ROOT%{python_sitelib}/up2date_client/firstboot
%endif
rm -f $RPM_BUILD_ROOT%{_datadir}/firstboot/modules/rhn_register.*
%endif
%if 0%{?rhel} == 6
rm -rf $RPM_BUILD_ROOT%{_datadir}/firstboot/modules/rhn_*_*.*
%endif
%if ! 0%{?rhel} || 0%{?rhel} > 6
%if 0%{?build_py2}
rm -rf $RPM_BUILD_ROOT%{python_sitelib}/up2date_client/firstboot
%endif
rm -rf $RPM_BUILD_ROOT%{_datadir}/firstboot/
%endif
%if 0%{?build_py3}
rm -rf $RPM_BUILD_ROOT%{python3_sitelib}/up2date_client/firstboot
%endif

desktop-file-install --dir=${RPM_BUILD_ROOT}%{_datadir}/applications --vendor=rhn rhn_register.desktop
%if 0%{?suse_version}
%suse_update_desktop_file -r rhn_register "Settings;System;SystemSetup;"
# no usermod on SUSE
rm -f $RPM_BUILD_ROOT%{_bindir}/rhn_register
%endif

%find_lang %{name}

# create links to default script version
%define default_suffix %{?default_py3:-%{python3_version}}%{!?default_py3:-%{python_version}}
for i in \
    /usr/sbin/rhn-profile-sync \
    /usr/sbin/rhn_check \
    /usr/sbin/rhn_register \
    /usr/sbin/rhnreg_ks \
    /usr/sbin/spacewalk-channel \
; do
    ln -s $(basename "$i")%{default_suffix} "$RPM_BUILD_ROOT$i"
done

%if 0%{?suse_version}
%py_compile -O %{buildroot}/%{python_sitelib}
%if 0%{?build_py3}
%py3_compile -O %{buildroot}/%{python3_sitelib}
%endif
%endif

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

# dirs
%dir %{_datadir}/rhn
%dir %{_localstatedir}/spool/up2date

%{_sbindir}/rhn-profile-sync

%ghost %attr(600,root,root) %verify(not md5 size mtime) %{_localstatedir}/spool/up2date/loginAuth.pkl

#public keys and certificates
%{_datadir}/rhn/RHNS-CA-CERT

%if 0%{?fedora}
%{_presetdir}/50-spacewalk-client.preset
%endif

%if 0%{?build_py2}
%files -n python2-%{name}
%{_sbindir}/rhn-profile-sync-%{python_version}
%dir %{python_sitelib}/up2date_client/
%{python_sitelib}/up2date_client/__init__.*
%{python_sitelib}/up2date_client/config.*
%{python_sitelib}/up2date_client/haltree.*
%{python_sitelib}/up2date_client/hardware*
%{python_sitelib}/up2date_client/up2dateUtils.*
%{python_sitelib}/up2date_client/up2dateLog.*
%{python_sitelib}/up2date_client/up2dateErrors.*
%{python_sitelib}/up2date_client/up2dateAuth.*
%{python_sitelib}/up2date_client/rpcServer.*
%{python_sitelib}/up2date_client/rhnserver.*
%{python_sitelib}/up2date_client/pkgUtils.*
%{python_sitelib}/up2date_client/rpmUtils.*
%{python_sitelib}/up2date_client/debUtils.*
%{python_sitelib}/up2date_client/rhnPackageInfo.*
%{python_sitelib}/up2date_client/rhnChannel.*
%{python_sitelib}/up2date_client/rhnHardware.*
%{python_sitelib}/up2date_client/transaction.*
%{python_sitelib}/up2date_client/clientCaps.*
%{python_sitelib}/up2date_client/capabilities.*
%{python_sitelib}/up2date_client/rhncli.*
%{python_sitelib}/up2date_client/pkgplatform.*
%endif

%if 0%{?build_py3}
%files -n python3-%{name}
%{_sbindir}/rhn-profile-sync-%{python3_version}
%dir %{python3_sitelib}/up2date_client/
%{python3_sitelib}/up2date_client/__init__.*
%{python3_sitelib}/up2date_client/config.*
%{python3_sitelib}/up2date_client/haltree.*
%{python3_sitelib}/up2date_client/hardware*
%{python3_sitelib}/up2date_client/up2dateUtils.*
%{python3_sitelib}/up2date_client/up2dateLog.*
%{python3_sitelib}/up2date_client/up2dateErrors.*
%{python3_sitelib}/up2date_client/up2dateAuth.*
%{python3_sitelib}/up2date_client/rpcServer.*
%{python3_sitelib}/up2date_client/rhnserver.*
%{python3_sitelib}/up2date_client/pkgUtils.*
%{python3_sitelib}/up2date_client/rpmUtils.*
%{python3_sitelib}/up2date_client/debUtils.*
%{python3_sitelib}/up2date_client/rhnPackageInfo.*
%{python3_sitelib}/up2date_client/rhnChannel.*
%{python3_sitelib}/up2date_client/rhnHardware.*
%{python3_sitelib}/up2date_client/transaction.*
%{python3_sitelib}/up2date_client/clientCaps.*
%{python3_sitelib}/up2date_client/capabilities.*
%{python3_sitelib}/up2date_client/rhncli.*
%{python3_sitelib}/up2date_client/pkgplatform.*
%dir %{python3_sitelib}/up2date_client/__pycache__/
%{python3_sitelib}/up2date_client/__pycache__/__init__.*
%{python3_sitelib}/up2date_client/__pycache__/config.*
%{python3_sitelib}/up2date_client/__pycache__/haltree.*
%{python3_sitelib}/up2date_client/__pycache__/hardware*
%{python3_sitelib}/up2date_client/__pycache__/up2dateUtils.*
%{python3_sitelib}/up2date_client/__pycache__/up2dateLog.*
%{python3_sitelib}/up2date_client/__pycache__/up2dateErrors.*
%{python3_sitelib}/up2date_client/__pycache__/up2dateAuth.*
%{python3_sitelib}/up2date_client/__pycache__/rpcServer.*
%{python3_sitelib}/up2date_client/__pycache__/rhnserver.*
%{python3_sitelib}/up2date_client/__pycache__/pkgUtils.*
%{python3_sitelib}/up2date_client/__pycache__/rpmUtils.*
%{python3_sitelib}/up2date_client/__pycache__/debUtils.*
%{python3_sitelib}/up2date_client/__pycache__/rhnPackageInfo.*
%{python3_sitelib}/up2date_client/__pycache__/rhnChannel.*
%{python3_sitelib}/up2date_client/__pycache__/rhnHardware.*
%{python3_sitelib}/up2date_client/__pycache__/transaction.*
%{python3_sitelib}/up2date_client/__pycache__/clientCaps.*
%{python3_sitelib}/up2date_client/__pycache__/capabilities.*
%{python3_sitelib}/up2date_client/__pycache__/rhncli.*
%{python3_sitelib}/up2date_client/__pycache__/pkgplatform.*
%endif

%files -n rhn-check
%{_mandir}/man8/rhn_check.8*
%{_sbindir}/rhn_check

%if 0%{?build_py2}
%files -n python2-rhn-check
%{_sbindir}/rhn_check-%{python_version}
%dir %{python_sitelib}/rhn
%dir %{python_sitelib}/rhn/actions/
%{python_sitelib}/up2date_client/getMethod.*
# actions for rhn_check to run
%{python_sitelib}/rhn/actions/__init__.*
%{python_sitelib}/rhn/actions/hardware.*
%{python_sitelib}/rhn/actions/systemid.*
%{python_sitelib}/rhn/actions/reboot.*
%{python_sitelib}/rhn/actions/rhnsd.*
%{python_sitelib}/rhn/actions/up2date_config.*
%endif

%if 0%{?build_py3}
%files -n python3-rhn-check
%{_sbindir}/rhn_check-%{python3_version}
%dir %{python3_sitelib}/rhn
%dir %{python3_sitelib}/rhn/actions/
%{python3_sitelib}/up2date_client/getMethod.*
%{python3_sitelib}/rhn/actions/__init__.*
%{python3_sitelib}/rhn/actions/hardware.*
%{python3_sitelib}/rhn/actions/systemid.*
%{python3_sitelib}/rhn/actions/reboot.*
%{python3_sitelib}/rhn/actions/rhnsd.*
%{python3_sitelib}/rhn/actions/up2date_config.*
%dir %{python3_sitelib}/rhn/actions/__pycache__/
%{python3_sitelib}/up2date_client/__pycache__/getMethod.*
%{python3_sitelib}/rhn/actions/__pycache__/__init__.*
%{python3_sitelib}/rhn/actions/__pycache__/hardware.*
%{python3_sitelib}/rhn/actions/__pycache__/systemid.*
%{python3_sitelib}/rhn/actions/__pycache__/reboot.*
%{python3_sitelib}/rhn/actions/__pycache__/rhnsd.*
%{python3_sitelib}/rhn/actions/__pycache__/up2date_config.*
%endif

%files -n rhn-setup
%{_mandir}/man8/rhnreg_ks.8*
%{_mandir}/man8/rhn_register.8*
%{_mandir}/man8/spacewalk-channel.8*
%{_mandir}/man8/rhn-channel.8*

%config(noreplace) %{_sysconfdir}/security/console.apps/rhn_register
%config(noreplace) %{_sysconfdir}/pam.d/rhn_register
%if 0%{?fedora} || 0%{?rhel}
%{_bindir}/rhn_register
%endif
%{_sbindir}/rhn_register
%{_sbindir}/rhnreg_ks
%{_sbindir}/spacewalk-channel
%{_sbindir}/rhn-channel

%{_datadir}/setuptool/setuptool.d/99rhn_register

%if 0%{?suse_version}
# on SUSE directories not owned by any package
%dir %{_sysconfdir}/security/console.apps
%dir %{_datadir}/setuptool
%dir %{_datadir}/setuptool/setuptool.d
%endif

%if 0%{?build_py2}
%files -n python2-rhn-setup
%{_sbindir}/rhn_register-%{python_version}
%{_sbindir}/rhnreg_ks-%{python_version}
%{_sbindir}/spacewalk-channel-%{python_version}
%{python2_sitelib}/up2date_client/rhnreg.*
%{python2_sitelib}/up2date_client/pmPlugin.*
%{python2_sitelib}/up2date_client/tui.*
%{python2_sitelib}/up2date_client/rhnreg_constants.*
%endif

%if 0%{?build_py3}
%files -n python3-rhn-setup
%{_sbindir}/rhn_register-%{python3_version}
%{_sbindir}/rhnreg_ks-%{python3_version}
%{_sbindir}/spacewalk-channel-%{python3_version}
%{python3_sitelib}/up2date_client/rhnreg.*
%{python3_sitelib}/up2date_client/pmPlugin.*
%{python3_sitelib}/up2date_client/tui.*
%{python3_sitelib}/up2date_client/rhnreg_constants.*
%{python3_sitelib}/up2date_client/__pycache__/rhnreg.*
%{python3_sitelib}/up2date_client/__pycache__/pmPlugin.*
%{python3_sitelib}/up2date_client/__pycache__/tui.*
%{python3_sitelib}/up2date_client/__pycache__/rhnreg_constants.*
%endif

%files -n rhn-setup-gnome
%{_datadir}/pixmaps/*png
%{_datadir}/icons/hicolor/16x16/apps/up2date.png
%{_datadir}/icons/hicolor/24x24/apps/up2date.png
%{_datadir}/icons/hicolor/32x32/apps/up2date.png
%{_datadir}/icons/hicolor/48x48/apps/up2date.png
%if 0%{?rhel} > 6 || 0%{?fedora}
%{_datadir}/icons/hicolor/22x22/apps/up2date.png
%{_datadir}/icons/hicolor/256x256/apps/up2date.png
%endif
%{_datadir}/applications/rhn_register.desktop
%{_datadir}/rhn/up2date_client/gui.glade
%{_datadir}/rhn/up2date_client/progress.glade
%{_datadir}/rhn/up2date_client/rh_register.glade

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
%dir %{_datadir}/rhn/up2date_client
%endif

%if 0%{?build_py2}
%files -n python2-rhn-setup-gnome
%{python_sitelib}/up2date_client/messageWindow.*
%{python_sitelib}/up2date_client/rhnregGui.*
%{python_sitelib}/up2date_client/gtk_compat.*
%{python_sitelib}/up2date_client/gui.*
%{python_sitelib}/up2date_client/progress.*
%if 0%{?rhel} == 5
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
%if 0%{?rhel} == 6
%{_datadir}/firstboot/modules/rhn_register.*
%{python_sitelib}/up2date_client/firstboot/rhn_login_gui.*
%{python_sitelib}/up2date_client/firstboot/rhn_start_gui.*
%{python_sitelib}/up2date_client/firstboot/rhn_choose_server_gui.*
%{python_sitelib}/up2date_client/firstboot/rhn_choose_channel.*
%{python_sitelib}/up2date_client/firstboot/rhn_provide_certificate_gui.*
%{python_sitelib}/up2date_client/firstboot/rhn_create_profile_gui.*
%{python_sitelib}/up2date_client/firstboot/rhn_review_gui.*
%{python_sitelib}/up2date_client/firstboot/rhn_finish_gui.*
%endif
%endif
%endif

%if 0%{?build_py3}
%files -n python3-rhn-setup-gnome
%{python3_sitelib}/up2date_client/messageWindow.*
%{python3_sitelib}/up2date_client/rhnregGui.*
%{python3_sitelib}/up2date_client/gtk_compat.*
%{python3_sitelib}/up2date_client/gui.*
%{python3_sitelib}/up2date_client/progress.*
%{python3_sitelib}/up2date_client/__pycache__/messageWindow.*
%{python3_sitelib}/up2date_client/__pycache__/rhnregGui.*
%{python3_sitelib}/up2date_client/__pycache__/gtk_compat.*
%{python3_sitelib}/up2date_client/__pycache__/gui.*
%{python3_sitelib}/up2date_client/__pycache__/progress.*
%endif

%changelog
* Fri Mar 23 2018 Jiri Dostal <jdostal@redhat.com> 2.8.22-1
- strip quotes when reading /etc/sysconfig/network

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.21-1
- don't try to delete python2 files when there are none

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.20-1
- don't build python2 when building python3 only

* Mon Mar 19 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.19-1
- don't build python2 subpackages on systems with default python2
- Regenerating .po and .pot files for rhn-client-tools.
- Updating .po translations from Zanata

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.18-1
- don't require yum on rhel8

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.17-1
- require dnf-plugin-spacewalk on rhel8
- rhel8 utilizes python3

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.16-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Wed Dec 13 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.15-1
- 1417185 - do chmod an the new file, not the old one which will be deleted
- 1417185 - change permissions to default provided by rhn-client-tools rpm

* Fri Dec 08 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.14-1
- fix warning: numeric expression expected (got ")

* Fri Dec 01 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.13-1
- dist cannot detect the distribution anymore
- fix rpm names in SUSE
- rhn-client-tools: fix filelist for SUSE and enable py3 build for Tumbleweed

* Wed Nov 22 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.12-1
- update rhn-setup-gnome to work on python3 based systems

* Wed Nov 15 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.11-1
- sh-utils provide has been removed from coreutils

* Wed Oct 25 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.10-1
- device.sys_path is attribute not function

* Mon Oct 23 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.9-1
- make getting device properties compatible with older versions of pyudev
- use new pyudev module on SUSE to get udev information
- add getting device information using pyudev module

* Wed Oct 18 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.8-1
- expanded tabs to spaces
- 1502695 - remove dependency on libgnome

* Tue Oct 17 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.7-1
- 1502695 - removed dependency on libgnome
- fixed typo introduced in 8ed741dfaf76b37dc88724692f90240aed7a85a5
- gui has moved to standard path
- removed settings for old RH build system

* Thu Oct 05 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- 1494389 - detect if action has been picked up for 2nd time
- 1494389 - Revert "[1260527] RHEL7 reboot loop"
- 1494389 - Revert "fix except to be compatible with Python 2.4"

* Mon Oct 02 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.5-1
- fixed python2 on Fedora requires

* Fri Sep 29 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- require the same version of other packages
- move client actions to rhn namespace
- import methods from standard path
- all python modules are now in standard sitelib

* Wed Sep 27 2017 Gennadii Altukhov <grinrag@gmail.com> 2.8.3-1
- fix dependencies of rhn-client-tools on different platforms

* Fri Sep 22 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- install files into python_sitelib/python3_sitelib
- let rpmbuild take care of .pyc/.pyo
- move rhn-setup-gnome files into proper python2/python3 subpackages
- move rhn-setup files into proper python2/python3 subpackages
- move rhn-check files into proper python2/python3 subpackages
- move rhn-client-tools files into proper python2/python3 subpackages
- split rhn-setup-gnome into python2/python3 specific packages
- split rhn-setup into python2/python3 specific packages
- split rhn-check into python2/python3 specific packages
- split rhn-client-tools into python2/python3 specific packages
- simplified Requires/Provides definition
- remove unused import

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.16-1
- precompile py3 bytecode on Fedora 23+
- use standard brp-python-bytecompile

* Mon Aug 07 2017 Eric Herget <eherget@redhat.com> 2.7.15-1
- another pass to update copyright year

* Fri Aug 04 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.14-1
- 1430298 - rhnreg_ks man page missing documentation for some options

* Wed Aug 02 2017 Gennadii Altukhov <grinrag@gmail.com> 2.7.13-1
- 1477149 - fix rhn-profile sync on Fedora 26 fix ipv6 network mask calculation

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.12-1
- update copyright year

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.11-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 2.7.10-1
- Regenerating .po and .pot files for rhn-client-tools
- Updating .po translations from Zanata
- PR 500 - Add epoch information for deb packages

* Mon Apr 24 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.9-1
- 1444764 - sgmlop module might not be available on RHEL 7

* Fri Apr 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.8-1
- Enable detection of Oracle Linux during registration.

* Wed Apr 19 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.7-1
- change requirement from python2 package to python3 for fedora

* Mon Mar 06 2017 Gennadii Altukhov <galt@redhat.com> 2.7.6-1
- 1371871 - fix UnicodeDecodeError when running rhnreg_ks with a different
  locale than en_US
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Fri Mar 03 2017 Jiri Dostal <jdostal@redhat.com> 2.7.5-1
- 1427249 - Fix rhn_register crashing on startup on Python < 2.5.

* Wed Feb 01 2017 Eric Herget <eherget@redhat.com> 2.7.4-1
- 1414579 - remove sstr call on list arguments to fix rhel7 client issue

* Wed Jan 18 2017 Eric Herget <eherget@redhat.com> 2.7.3-1
- 1414579 - rhn-search traceback - immediateTrigger-server exists with certain
  identification

* Mon Jan 02 2017 Jiri Dostal <jdostal@redhat.com> 2.7.2-1
- urlsplit back compatibility with python 2.4 fixing bug introduced in dc7ee6d

* Tue Nov 15 2016 Gennadii Altukhov <galt@redhat.com> 2.7.1-1
- fix except to be compatible with Python 2.4
- Bumping package versions for 2.7.

* Fri Nov 11 2016 Jiri Dostal <jdostal@redhat.com> 2.6.7-1
- [1260527] RHEL7 reboot loop

* Wed Nov 09 2016 Gennadii Altukhov <galt@redhat.com> 2.6.6-1
- Revert Project-Id-Version for translations

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 2.6.5-1
- Regenerating .po and .pot files for rhn-client-tools.
- Updating .po translations from Zanata

* Tue Oct 25 2016 Gennadii Altukhov <galt@redhat.com> 2.6.4-1
- 1320468 - add newline before hostname in LoginPage label

* Fri Sep 23 2016 Jiri Dostal <jdostal@redhat.com> 2.6.3-1
- Fix of deprecated functions urllib.splittype and urllib.splithost

* Thu Sep 22 2016 Jan Dobes 2.6.2-1
- fedora 24 client will not send it's smbios because there is a warning and it
  fails on syntax error

* Wed Aug 03 2016 Tomas Lestach <tlestach@redhat.com> 2.6.1-1
- fix typo/missing space in rhn_check rpm description
- Bumping package versions for 2.6.

* Tue May 24 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.16-1
- updating copyright years
- Regenerating .po and .pot files for rhn-client-tools.
- Updating .po translations from Zanata

* Thu May 12 2016 Gennadii Altukhov <galt@redhat.com> 2.5.15-1
- change build dependency on python-devel, because we don't use Python3 during
  package building

* Wed May 11 2016 Gennadii Altukhov <galt@redhat.com> 2.5.14-1
- 1326306 - use 'netifaces' module for Python3 instead of 'ethtools'

* Fri Feb 19 2016 Jan Dobes 2.5.13-1
- fixed 'exceptions.ValueError: invalid literal for int(): 0oxxx' to work in
  python 2.4 (RHEL5)

* Thu Feb 18 2016 Jan Dobes 2.5.12-1
- delete file with input files after template is created
- try to generate more similar order of entries in template
- pulling *.po translations from Zanata
- fixing current *.po translations

* Fri Feb 12 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.11-1
- 1259884 - fixed missing method for sorting of rhnChannels
- 1259884 - open terminal for write only

* Fri Jan 22 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.10-1
- Bug 1300251 - clientCaps.py : IndexError: string index out of range

* Tue Jan 19 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.9-1
- yet another python3 fixes

* Tue Jan 12 2016 Grant Gainey 2.5.8-1
- 875728 - Clarify useNoSSLForPackages comment to match reality

* Tue Jan 12 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.7-1
- 1259884, 1286555 - more python3 fixes

* Fri Jan 08 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.6-1
- updated dnf / rhnlib / rhn-client-tools dependencies
- fixed rpmbuild tests

* Fri Jan 08 2016 Michael Mraka <michael.mraka@redhat.com> 2.5.5-1
- 1259884, 1286555 - updated to work in python3

* Fri Jan 08 2016 Tomas Lestach <tlestach@redhat.com> 2.5.4-1
- 1260454 - clean up channels to subscribe before processing results

* Thu Dec 17 2015 Jan Dobes 2.5.3-1
- 1262780 - alow to use existing rpcServer when creating RhnServer

* Tue Nov 24 2015 Jan Dobes 2.5.2-1
- rhel client tools: po files updated
- rhel client tools: remove virtualization host platform entitlement references
- rhel client tools: drop references to update entitlements
- client-tools: Remove 'provisioning_entitled' slot from RHEL and Debian
- backend: unused reg_num parameter removed from documentation
- client-tools: Remove 'monitoring_entitled' slot from RHEL and Debian

* Thu Oct 15 2015 Tomas Lestach <tlestach@redhat.com> 2.5.1-1
- fix rhnChannel instance has no attribute 'get'
- Bumping package versions for 2.5.

* Thu Sep 24 2015 Jan Dobes 2.4.11-1
- Bumping copyright year.

* Wed Sep 23 2015 Jan Dobes 2.4.10-1
- Pulling updated *.po translations from Zanata.

* Wed Sep 16 2015 Jan Dobes 2.4.9-1
- 1263707 - fixing python2.4 to python3.3 exception compatibility

* Wed Sep 02 2015 Jan Dobes 2.4.8-1
- Show a descriptive message on reboot

* Fri Jul 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.7-1
- merge if into into one registerSystem call
- remove dead code

* Thu May 21 2015 Matej Kollar <mkollar@redhat.com> 2.4.6-1
- dnf is default on fedora22, so require it instead of yum-rhn-plugin
- Dependencies on rhnlib

* Tue May 19 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.5-1
- dnf is default on fedora22, so require it instead of yum

* Fri Apr 24 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.4-1
- make code python 2.4 to 3.3 compatible

* Thu Apr 23 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.2-1
- allow rhn-client-tool use yum or dnf

* Mon Apr 20 2015 Michael Mraka <michael.mraka@redhat.com> 2.4.1-1
- missing buildrequires for F23

* Thu Mar 19 2015 Grant Gainey 2.3.16-1
- Updating copyright info for 2015
- Revert "allow building rhn-client-tools package on rhel5"

* Thu Mar 19 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.15-1
- allow building rhn-client-tools package on rhel5

* Fri Mar 06 2015 Matej Kollar <mkollar@redhat.com> 2.3.14-1
- Fixed typos with options and function name

* Fri Mar 06 2015 Matej Kollar <mkollar@redhat.com> 2.3.13-1
- Fix issue introduced by b0cd7ef72cd92837155e6c5dcdb5213cba31af48

* Mon Mar 02 2015 Grant Gainey 2.3.12-1
- Use plural for lists
- Refactoring
- Sanitize input
- Fix grammar
- Extract listing of available channels
- Extract listing of base channel
- Extract channels listing
- Extract channel removal
- Extract channel addition
- Extract logging function
- Cleanup
- Pylint/Pep8
- Get rid of unused global variable

* Mon Mar 02 2015 Matej Kollar <mkollar@redhat.com> 2.3.11-1
- 1147425 - we might be registered also via rhsm
- 1147425 - avoid "list index out of range"
- Make indentation more PEP8

* Fri Feb 20 2015 Matej Kollar <mkollar@redhat.com> 2.3.10-1
- Localize error messages
- Typo
- 1036586 - separate username/password request
- Remove unused variable
- Indentation homogenization
- Separate definitions from directly executed code
- Remove unused import

* Wed Feb 18 2015 Matej Kollar <mkollar@redhat.com> 2.3.9-1
- 916597 - More helpful message

* Thu Feb 05 2015 Matej Kollar <mkollar@redhat.com> 2.3.8-1
- Updating function names
- Documentation changes - fix name and refer to RFC.

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 2.3.7-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Mon Dec 22 2014 Stephen Herr <sherr@redhat.com> 2.3.6-1
- rhn-client-tools: no usermod on SUSE

* Thu Oct 09 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.5-1
- fixed translations

* Thu Oct 09 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- fixed ar.po formating

* Tue Oct 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.3-1
- disable sgmlop import in rhn_check

* Mon Oct 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.2-1
- rhn-client-tools translations backported from RHEL6
- rhn-client-tools translations updated from Transifex

* Tue Aug 26 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.1-1
- updated translations

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- fix copyright years

* Thu Jul 10 2014 Tomas Kasparek <tkasparek@redhat.com> 2.2.6-1
- Update .po and .pot files for rhn-client-tools.

* Wed Jul 09 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.5-1
- allow unicode characters in proxy username / password

* Fri Jun 13 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.4-1
- replace python-gudev by gudev introspection

* Wed Jun 04 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- tmpDir option from up2date is no longer used, removing

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- spec file polish

* Mon May 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.1-1
- use set() for list of unique values
- 1094749 - fix cpu socket counting

* Fri Feb 14 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.16-1
- 1061013 - remove up2date_config.rpmmacros client action
- 1061013 - remove macros.up2date from package build

* Fri Feb 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.15-1
- 1061013 - remove unneeded rpm macros file
- 1060742 - new information icon in gnome3

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.14-1
- Updating the copyright years info
- Update .po and .pot files for rhn-client-tools.

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

