%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

%define _binaries_in_noarch_packages_terminate_build 0
%global debug_package %{nil}
Summary: Boot server configurator
Name: cobbler20
License: GPLv2+
AutoReq: no
Version: 2.0.11
Release: 55%{?dist}
Source0: cobbler-%{version}.tar.gz
Source1: cobblerd.service
Patch0: catch_cheetah_exception.patch
Patch1: lvm_storage.patch
Patch2: koan_no_selinux_set.patch
Patch3: buildiso.patch
Patch4: koan-rhel7-virtinst.patch
Patch5: koan-extra-options.patch
Patch6: cobbler-interface-type.patch
Patch7: cobblerd-python-s.patch
Patch8: cobbler-power-status.patch
Patch9: cobbler-rhel7-variant.patch
Patch10: cobbler-findks.patch
Patch11: cobbler-arm-arch.patch
Patch12: cobbler-modprobe-d.patch
Patch13: fedora_os_entry.patch
Patch14: centos7-version.patch
Patch15: unicode-scripts.patch
Patch16: cobbler-bz1214458.patch
Patch17: whitelist.patch
Patch18: disable_https.patch
Patch19: buildiso-boot-options.patch
Patch20: buildiso-no-local-hdd.patch
Patch21: cobbler-s390-kernel-options.patch
Group: Applications/System
Requires: python >= 2.3

Provides: cobbler = %{version}-%{release}
Obsoletes: cobbler <= %{version}-%{release}
Conflicts: cobbler-epel

%if 0%{?suse_version} >= 1000
Requires: apache2
Requires: apache2-mod_python
Requires: tftp
%else
Requires: httpd
Requires: tftp-server
%endif

Requires: mod_wsgi
Requires: syslinux

Requires: createrepo
%if 0%{?fedora}
Requires: fence-agents-all
%endif
%if 0%{?fedora} || 0%{?rhel} >= 6
Requires: genisoimage
%else
Requires: mkisofs
%endif
Requires: libyaml
Requires: python-cheetah
Requires: python-devel
Requires: python-netaddr
Requires: python-simplejson
%if 0%{?fedora} && 0%{?fedora} < 21
BuildRequires: python-setuptools-devel
%else
BuildRequires: python-setuptools
%endif
Requires: python-urlgrabber
Requires: PyYAML
%if 0%{?suse_version} < 0
BuildRequires: redhat-rpm-config
%endif
Requires: rsync
%if 0%{?fedora} || 0%{?rhel} >= 5
Requires: yum-utils
%endif

%if 0%{?fedora}
BuildRequires: systemd
%else
Requires(post):  /sbin/chkconfig
Requires(preun): /sbin/chkconfig
Requires(preun): /sbin/service
%endif

%if 0%{?fedora} || 0%{?rhel} >= 6
%{!?pyver: %define pyver %(%{__python} -c "import sys ; print sys.version[:3]" || echo 0)}
Requires: python(abi) >= %{pyver}
%endif

BuildRequires: PyYAML
BuildRequires: python-cheetah
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch
Url: http://fedorahosted.org/cobbler

%description

Cobbler is a network install server.  Cobbler 
supports PXE, virtualized installs, and 
reinstalling existing Linux machines.  The last two 
modes use a helper tool, 'koan', that 
integrates with cobbler.  There is also a web interface
'cobbler-web'.  Cobbler's advanced features 
include importing distributions from DVDs and rsync 
mirrors, kickstart templating, integrated yum 
mirroring, and built-in DHCP/DNS Management.  Cobbler has 
a XMLRPC API for integration with other applications.

%prep
%setup -q -n cobbler-%{version}
%patch0 -p1
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p1
%patch6 -p1
%if 0%{?fedora} || (0%{?rhel} && 0%{?rhel} > 5)
%patch7 -p1
%endif
%patch8 -p1
%patch9 -p1
%patch10 -p1
%patch11 -p1
%patch12 -p1
%patch13 -p1
%patch14 -p0
%patch15 -p1
%patch16 -p1
%patch17 -p1
%patch18 -p1
%patch19 -p1
%patch20 -p1
%patch21 -p1

%build
%{__python} setup.py build 

%install
test "x$RPM_BUILD_ROOT" != "x" && rm -rf $RPM_BUILD_ROOT
%if 0%{?suse_version} >= 1000
PREFIX="--prefix=/usr"
%endif
%{__python} setup.py install --optimize=1 --root=$RPM_BUILD_ROOT $PREFIX
mkdir $RPM_BUILD_ROOT/var/www/cobbler/rendered/
%if 0%{?fedora}
rm $RPM_BUILD_ROOT/etc/init.d/cobblerd
mkdir -p $RPM_BUILD_ROOT%{_unitdir}
install -m 0644 %{SOURCE1} $RPM_BUILD_ROOT%{_unitdir}/
%endif

%post
if [ "$1" = "1" ];
then
    # This happens upon initial install. Upgrades will follow the next else
    if [ -f /etc/init.d/cobblerd ]; then
        /sbin/chkconfig --add cobblerd
    fi
elif [ "$1" -ge "2" ];
then
    # backup config
    if [ -e /var/lib/cobbler/distros ]; then
        cp /var/lib/cobbler/distros*  /var/lib/cobbler/backup 2>/dev/null
        cp /var/lib/cobbler/profiles* /var/lib/cobbler/backup 2>/dev/null
        cp /var/lib/cobbler/systems*  /var/lib/cobbler/backup 2>/dev/null
        cp /var/lib/cobbler/repos*    /var/lib/cobbler/backup 2>/dev/null
        cp /var/lib/cobbler/networks* /var/lib/cobbler/backup 2>/dev/null
    fi
    if [ -e /var/lib/cobbler/config ]; then
        cp -a /var/lib/cobbler/config    /var/lib/cobbler/backup 2>/dev/null
    fi
    # upgrade older installs
    # move power and pxe-templates from /etc/cobbler, backup new templates to *.rpmnew
    for n in power pxe; do
      rm -f /etc/cobbler/$n*.rpmnew
      find /etc/cobbler -maxdepth 1 -name "$n*" -type f | while read f; do
        newf=/etc/cobbler/$n/`basename $f`
        [ -e $newf ] &&  mv $newf $newf.rpmnew
        mv $f $newf
      done
    done
    # upgrade older installs
    # copy kickstarts from /etc/cobbler to /var/lib/cobbler/kickstarts
    rm -f /etc/cobbler/*.ks.rpmnew
    find /etc/cobbler -maxdepth 1 -name "*.ks" -type f | while read f; do
      newf=/var/lib/cobbler/kickstarts/`basename $f`
      [ -e $newf ] &&  mv $newf $newf.rpmnew
      cp $f $newf
    done
    # reserialize and restart
    # FIXIT: ?????
    #/usr/bin/cobbler reserialize
%if 0%{?fedora}
    /bin/systemctl condrestart cobblerd.service
%else
    /sbin/service cobblerd condrestart
%endif
fi

%preun
if [ $1 = 0 ]; then
    if [ -f /etc/init.d/cobblerd ]; then
        /sbin/service cobblerd stop >/dev/null 2>&1 || :
        chkconfig --del cobblerd || :
    fi
fi

%postun
if [ "$1" -ge "1" ]; then
%if 0%{?fedora}
    /bin/systemctl condrestart cobblerd.service >/dev/null 2>&1 || :
    /bin/systemctl condrestart httpd.service >/dev/null 2>&1 || :
%else
    /sbin/service cobblerd condrestart >/dev/null 2>&1 || :
    /sbin/service httpd condrestart >/dev/null 2>&1 || :
%endif
fi


%clean
test "x$RPM_BUILD_ROOT" != "x" && rm -rf $RPM_BUILD_ROOT

%files

%defattr(755,apache,apache)
%dir /var/www/cobbler/pub/
%dir /var/www/cobbler/web/
/var/www/cobbler/web/index.html
%dir /var/www/cobbler/svc/
%dir /var/www/cobbler/rendered/
/var/www/cobbler/svc/*.py*
/var/www/cobbler/svc/*.wsgi*

%defattr(755,root,root)
%dir /usr/share/cobbler/installer_templates
%defattr(744,root,root)
/usr/share/cobbler/installer_templates/*.template
%defattr(744,root,root)
/usr/share/cobbler/installer_templates/defaults
#%defattr(755,apache,apache)               (MOVED to cobbler-web)
#%dir /usr/share/cobbler/webui_templates   (MOVED to cobbler-web)
#%defattr(444,apache,apache)               (MOVED to cobbler-web)
#/usr/share/cobbler/webui_templates/*.tmpl (MOVED to cobbler-web)

%defattr(755,apache,apache)
%dir /var/log/cobbler
%dir /var/log/cobbler/tasks
%dir /var/log/cobbler/kicklog
%dir /var/www/cobbler/
%dir /var/www/cobbler/localmirror
%dir /var/www/cobbler/repo_mirror
%dir /var/www/cobbler/ks_mirror
%dir /var/www/cobbler/ks_mirror/config
%dir /var/www/cobbler/images
%dir /var/www/cobbler/links
%defattr(755,apache,apache)
#%dir /var/www/cobbler/webui (MOVED to cobbler-web)
%dir /var/www/cobbler/aux
%defattr(444,apache,apache)
#/var/www/cobbler/webui/*    (MOVED TO cobbler-web)
/var/www/cobbler/aux/anamon
/var/www/cobbler/aux/anamon.init

%defattr(755,root,root)
%{_bindir}/cobbler
%{_bindir}/cobbler-ext-nodes
%{_bindir}/cobblerd

%defattr(-,root,root)
%dir /etc/cobbler
%dir /etc/cobbler/pxe
%dir /etc/cobbler/reporting
%dir /etc/cobbler/power
%config(noreplace) /var/lib/cobbler/kickstarts/*.ks
%config(noreplace) /var/lib/cobbler/kickstarts/*.seed
%config(noreplace) /etc/cobbler/*.template
%config(noreplace) /etc/cobbler/pxe/*.template
%config(noreplace) /etc/cobbler/reporting/*.template
%config(noreplace) /etc/cobbler/power/*.template
%config(noreplace) /etc/cobbler/rsync.exclude
%config(noreplace) /etc/logrotate.d/cobblerd_rotate
%config(noreplace) /etc/cobbler/modules.conf
%config(noreplace) /etc/cobbler/users.conf
%config(noreplace) /etc/cobbler/cheetah_macros
%dir %{python_sitelib}/cobbler
%dir %{python_sitelib}/cobbler/modules
%{python_sitelib}/cobbler/*.py*
#%{python_sitelib}/cobbler/server/*.py*
%{python_sitelib}/cobbler/modules/*.py*
%if 0%{?fedora} || 0%{?rhel} >= 5
%exclude %{python_sitelib}/cobbler/sub_process.py*
%endif
%{_mandir}/man1/cobbler.1.gz
%if 0%{?fedora}
%{_unitdir}/cobblerd.service
%else
/etc/init.d/cobblerd
%endif

%if 0%{?suse_version} >= 1000
%config(noreplace) /etc/apache2/conf.d/cobbler.conf
%else
%config(noreplace) /etc/httpd/conf.d/cobbler_wsgi.conf
%exclude /etc/httpd/conf.d/cobbler.conf
%endif

%dir /var/log/cobbler/syslog
%dir /var/log/cobbler/anamon

%defattr(755,root,root)
%dir /var/lib/cobbler
%dir /var/lib/cobbler/config/
%dir /var/lib/cobbler/config/distros.d/
%dir /var/lib/cobbler/config/profiles.d/
%dir /var/lib/cobbler/config/systems.d/
%dir /var/lib/cobbler/config/repos.d/
%dir /var/lib/cobbler/config/images.d/
%dir /var/lib/cobbler/kickstarts/
%dir /var/lib/cobbler/backup/
%dir /var/lib/cobbler/triggers
%dir /var/lib/cobbler/triggers/change
%dir /var/lib/cobbler/triggers/add
%dir /var/lib/cobbler/triggers/add/distro
%dir /var/lib/cobbler/triggers/add/distro/pre
%dir /var/lib/cobbler/triggers/add/distro/post
%dir /var/lib/cobbler/triggers/add/profile
%dir /var/lib/cobbler/triggers/add/profile/pre
%dir /var/lib/cobbler/triggers/add/profile/post
%dir /var/lib/cobbler/triggers/add/system
%dir /var/lib/cobbler/triggers/add/system/pre
%dir /var/lib/cobbler/triggers/add/system/post
%dir /var/lib/cobbler/triggers/add/repo
%dir /var/lib/cobbler/triggers/add/repo/pre
%dir /var/lib/cobbler/triggers/add/repo/post
%dir /var/lib/cobbler/triggers/delete
%dir /var/lib/cobbler/triggers/delete/distro
%dir /var/lib/cobbler/triggers/delete/distro/pre
%dir /var/lib/cobbler/triggers/delete/distro/post
%dir /var/lib/cobbler/triggers/delete/profile
%dir /var/lib/cobbler/triggers/delete/profile/pre
%dir /var/lib/cobbler/triggers/delete/profile/post
%dir /var/lib/cobbler/triggers/delete/system
%dir /var/lib/cobbler/triggers/delete/system/pre
%dir /var/lib/cobbler/triggers/delete/system/post
%dir /var/lib/cobbler/triggers/delete/repo
%dir /var/lib/cobbler/triggers/delete/repo/pre
%dir /var/lib/cobbler/triggers/delete/repo/post
%dir /var/lib/cobbler/triggers/sync
%dir /var/lib/cobbler/triggers/sync/pre
%dir /var/lib/cobbler/triggers/sync/post
%dir /var/lib/cobbler/triggers/install
%dir /var/lib/cobbler/triggers/install/pre
%dir /var/lib/cobbler/triggers/install/post
%dir /var/lib/cobbler/snippets/
%dir /var/cache/cobbler
%dir /var/cache/cobbler/buildiso

%defattr(664,root,root)
%config(noreplace) /etc/cobbler/settings
/var/lib/cobbler/version
%config(noreplace) /var/lib/cobbler/snippets/*
%dir /var/lib/cobbler/loaders/
/var/lib/cobbler/loaders/zpxe.rexx
%defattr(660,root,root)
%config(noreplace) /etc/cobbler/users.digest 

%defattr(664,root,root)
%config(noreplace) /var/lib/cobbler/cobbler_hosts

%defattr(-,root,root)
%if 0%{?fedora} || 0%{?rhel} >= 6
%{python_sitelib}/cobbler*.egg-info
%endif
%doc AUTHORS CHANGELOG README COPYING

%package -n koan

Summary: Helper tool that performs cobbler orders on remote machines.
Group: Applications/System
Requires: python >= 1.5
BuildRequires: python-devel
%if 0%{?fedora} || 0%{?rhel} >= 6
%{!?pyver: %define pyver %(%{__python} -c "import sys ; print sys.version[:3]")}
Requires: python(abi) >= %{pyver}
%endif
%if 0%{?fedora} && 0%{?fedora} < 21
BuildRequires: python-setuptools-devel
%else
BuildRequires: python-setuptools
%endif
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch
Url: http://fedorahosted.org/cobbler/


%description -n koan

Koan stands for kickstart-over-a-network and allows for both
network installation of new virtualized guests and reinstallation 
of an existing system.  For use with a boot-server configured with Cobbler

%files -n koan
%defattr(-,root,root)
# FIXME: need to generate in setup.py
%dir /var/spool/koan
%{_bindir}/koan
%{_bindir}/cobbler-register
%dir %{python_sitelib}/koan
%{python_sitelib}/koan/*.py*
%if 0%{?fedora} || 0%{?rhel} >= 5
%exclude %{python_sitelib}/koan/sub_process.py*
%exclude %{python_sitelib}/koan/opt_parse.py*
%exclude %{python_sitelib}/koan/text_wrap.py*
%endif
%{_mandir}/man1/koan.1.gz
%{_mandir}/man1/cobbler-register.1.gz
%dir /var/log/koan
%doc AUTHORS COPYING CHANGELOG README

%package -n cobbler2
Summary: Compatibility package to pull in cobbler from Spacewalk repo
Group: Applications/System
Requires: cobbler20 = %{version}-%{release}

%description -n cobbler2

Compatibility package to pull in cobbler from Spacewalk repo.

%files -n cobbler2

%package -n cobbler-epel
Summary: Compatibility package to pull in cobbler package from EPEL/Fedora
Group: Applications/System
Requires: cobbler >= 2.2
Provides: cobbler2

%description -n cobbler-epel

Compatibility package to pull in cobbler package from EPEL/Fedora.

%files -n cobbler-epel

%package -n cobbler-web

Summary: Web interface for Cobbler
Group: Applications/System
Requires: cobbler
Requires: Django
%if 0%{?suse_version} >= 1000
Requires: apache2-mod_python
%else
Requires: mod_python
%endif
%if 0%{?fedora} || 0%{?rhel} >= 6
%{!?pyver: %define pyver %(%{__python} -c "import sys ; print sys.version[:3]")}
Requires: python(abi) >= %{pyver}
%endif
%if 0%{?fedora} && 0%{?fedora} < 21
BuildRequires: python-setuptools-devel
%else
BuildRequires: python-setuptools
%endif
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch: noarch
Url: http://fedorahosted.org/cobbler/

%description -n cobbler-web

Web interface for Cobbler that allows visiting http://server/cobbler_web to configure the install server.

%files -n cobbler-web
%defattr(-,apache,apache)
%dir /usr/share/cobbler/web
/usr/share/cobbler/web/*
%dir /usr/share/cobbler/web/cobbler_web
/usr/share/cobbler/web/cobbler_web/*
%config(noreplace) /etc/httpd/conf.d/cobbler_web.conf
%dir /var/lib/cobbler/webui_sessions
%dir /var/www/cobbler_webui_content
/var/www/cobbler_webui_content/*
%doc AUTHORS COPYING CHANGELOG README

%changelog
* Wed Nov 04 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-55
- add system support to --no-local-hdd option without need of profiles

* Mon Oct 05 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-54
- timeout to 1st available profile with --no-local-hdd instead of local hdd

* Mon Oct 05 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-53
- 

* Wed Sep 02 2015 Jan Dobes 2.0.11-52
- 1199214 - removing kernel options for s390 systems

* Tue Sep 01 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-51
- add option to skip local harddrive as buildiso entry

* Wed Jun 17 2015 Jan Dobes 2.0.11-50
- 1095198 - fixing multiple nameserver boot options on rhel7 and fedora

* Thu Jun 11 2015 Jan Dobes 2.0.11-49
- fix adding netmask kernel parameter into isolinux.cfg

* Wed Jun 10 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-48
- fix paths for disable_https patch

* Wed Jun 10 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-47
- cobbler20 needs to conflict with cobbler-epel - DNF is too smart
- include disable_https.patch in cobbler20 spec

* Tue Jun 09 2015 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-46
- disable https comunication with spacewalk

* Mon May 11 2015 Jan Dobes 2.0.11-45
- enabling patch
- adding keyword also into config file

* Wed Apr 22 2015 Stephen Herr <sherr@redhat.com> 2.0.11-44
- 1214458 - fix cobbler timing window that can mess up pxe file permissions

* Wed Apr 15 2015 Jan Dobes 2.0.11-43
- 1096263 - specify unicode encoding for Cheetah

* Fri Jan 23 2015 Stephen Herr <sherr@redhat.com> 2.0.11-42
- Make cobbler detect os version for CentOS 7 Taken from upstream:
  https://github.com/cobbler/cobbler/pull/1021

* Mon Jan 19 2015 Tomas Lestach <tlestach@redhat.com> 2.0.11-41
- adapt cobbler20 for fc21
- 1136538 - support while loop syntax for Cheetah templates

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.0.11-40
- Make cobbler20 require syslinux. Upstream versions require it, too. This
  fixes BZ#988329

* Fri Dec 05 2014 Tomas Lestach <tlestach@redhat.com> 2.0.11-39
- 1169741 - accept more power status messages

* Thu Dec 04 2014 Stephen Herr <sherr@redhat.com> 2.0.11-38
- 1162311 - cobbler template files need to not have comments

* Wed Oct 08 2014 Tomas Lestach <tlestach@redhat.com> 2.0.11-37
- use fedora18 as fedora kickstart type

* Tue Sep 30 2014 Tomas Lestach <tlestach@redhat.com> 2.0.11-36
- cobbler needs to know 'fedora' OS entry

* Mon Sep 15 2014 Michael Mraka <michael.mraka@redhat.com> 2.0.11-35
- 979966 - updated patch to match latest post_install_network_config version

* Mon Sep 15 2014 Michael Mraka <michael.mraka@redhat.com> 2.0.11-34
- 979966 - support modprobe.d on RHEL6

* Fri Sep 05 2014 Stephen Herr <sherr@redhat.com> 2.0.11-33
- 1138451 - fixing a couple of cobbler problems with aarch64 support

* Thu Sep 04 2014 Stephen Herr <sherr@redhat.com> 2.0.11-32
- 1138451 - add aarch64 provisioning support

* Tue Jul 15 2014 Stephen Herr <sherr@redhat.com> 2.0.11-31
- 1119758 - Make cobbler findks work and be compatible with Proxy

* Mon Jul 14 2014 Stephen Herr <sherr@redhat.com> 2.0.11-30
- bump cobbler version to avoid conflict with 2.2 branch
- Cobbler needs to know about newer OSs

* Mon Jul 07 2014 Stephen Herr <sherr@redhat.com> 2.0.11-28
- Fixes for cobbler power status command

* Tue Jul 01 2014 Stephen Herr <sherr@redhat.com> 2.0.11-27
- 1109276 - cobbler interface type patch fix

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.0.11-26
- vim helpfully auto-stripped ending whitespace and broke my patch :(

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.0.11-25
- adding status power command to cobbler

* Tue Jun 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.0.11-24
- cobblerd: don't search user's ~/.local on Fedora and RHEL-6

* Fri Jun 13 2014 Stephen Herr <sherr@redhat.com> 2.0.11-23
- 1109276 - make cobbler20 guest kickstart work with new koan

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.0.11-22
- spec polishing

* Thu Dec 12 2013 Stephen Herr <sherr@redhat.com> 2.0.11-21
- 1042381 - Add extra options to koan for virt-install
- 1042363 - make koan virt guest installs work on newer operating systems

* Fri Jul 05 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-20
- polishing cobbler20 dependencies for fedora19

* Wed Jul 03 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.11-19
- make cobbler20 build-able on F19
- replace legacy name of Tagger with new one

* Thu Apr 11 2013 Stephen Herr <sherr@redhat.com> 2.0.11-18
- fixing cobbler patch file

* Thu Apr 11 2013 Stephen Herr <sherr@redhat.com> 2.0.11-17
- 506485 - enable cobbler buildiso functionality

* Wed Apr 10 2013 Tomas Lestach <tlestach@redhat.com> 2.0.11-16
- 768451 - fix previous patch

* Wed Apr 10 2013 Tomas Lestach <tlestach@redhat.com> 2.0.11-15
- 768451 - do not set selinux context for patition locations

* Thu Feb 21 2013 Tomas Lestach <tlestach@redhat.com> 2.0.11-14
- 768451 - lvm storage koan fix

* Mon Feb 18 2013 Michael Mraka <michael.mraka@redhat.com> 2.0.11-13
- update tftp dependency for systemd

* Thu Feb 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.0.11-12
- fixed systemd services description

* Fri Feb 08 2013 Stephen Herr <sherr@redhat.com> 2.0.11-11
- Cobbler sometimes wants to share things through /tmp

* Wed Feb 06 2013 Stephen Herr <sherr@redhat.com> 2.0.11-10
- Actually forcing cobblerd to not fork seems to work much better
- cobblerd must be marked as forking for systemd to treat it correctly

* Fri Feb 01 2013 Michael Mraka <michael.mraka@redhat.com> 2.0.11-9
- let's use native systemd service on fedora
- create systemd service for cobblerd

* Wed Jan 23 2013 Jan Pazdziora 2.0.11-7
- Move to mod_wsgi both on Fedoras and on RHEL 5.

* Mon Nov 12 2012 Tomas Lestach <tlestach@redhat.com> 2.0.11-6
- 866326 - catch xmlrpclib.Fault instead of general Exception in cobbler's
  mod_python/mod_wsgi

* Thu Nov 08 2012 Tomas Lestach <tlestach@redhat.com> 2.0.11-5
- 866326 - catch cheetah exception in mod_pythod/mod_wsgi and forward it as 500
  SERVER ERROR

* Fri Oct 19 2012 Jan Pazdziora 2.0.11-4
- We need one extra package in the dependency chain to prefer cobbler20 upon
  fresh installation.

* Tue Oct 16 2012 Jan Pazdziora 2.0.11-3
- Compatibility package to provide cobbler 2.0.

* Tue Apr 26 2011 Scott Henson <shenson@redhat.com> - 2.0.11-2
- Actually include a change log entry

* Tue Apr 26 2011 Scott Henson <shenson@redhat.com> - 2.0.11-1
- New Upstream Release

* Fri Dec 24 2010 Scott Henson <shenson@redhat.com> - 2.0.10-1
- New upstream release

* Wed Dec  8 2010 Scott Henson <shenson@redhat.com> - 2.0.9-1
- New upstream release

* Fri Dec  3 2010 Scott Henson <shenson@redhat.com> - 2.0.8-1
- New upstream release

* Wed Oct 18 2010 Scott Henson <shenson@redhat.com> - 2.0.7-1
- Bug fix relase, see Changelog for details

* Tue Jul 13 2010 Scott Henson <shenson@redhat.com> - 2.0.5-1
- Bug fix release, see Changelog for details

* Tue Apr 27 2010 Scott Henson <shenson@redhat.com> - 2.0.4-1
- Bug fix release, see Changelog for details

* Mon Mar  1 2010 Scott Henson <shenson@redhat.com> - 2.0.3.1-3
- Bump release because I forgot cobbler-web

* Mon Mar  1 2010 Scott Henson <shenson@redhat.com> - 2.0.3.1-2
- Remove requires on mkinitrd as it is not used

* Mon Feb 15 2010 Scott Henson <shenson@redhat.com> - 2.0.3.1-1
- Upstream Brown Paper Bag Release (see CHANGELOG)

* Thu Feb 11 2010 Scott Henson <shenson@redhat.com> - 2.0.3-1
- Upstream changes (see CHANGELOG)

* Mon Nov 23 2009 John Eckersberg <jeckersb@redhat.com> - 2.0.2-1
- Upstream changes (see CHANGELOG)

* Tue Sep 15 2009 Michael DeHaan <mdehaan@redhat.com> - 2.0.0-1
- First release with unified spec files

