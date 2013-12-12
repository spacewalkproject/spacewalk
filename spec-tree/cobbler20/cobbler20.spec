%{!?python_sitelib: %define python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

%define _binaries_in_noarch_packages_terminate_build 0
%global debug_package %{nil}
Summary: Boot server configurator
Name: cobbler20
License: GPLv2+
AutoReq: no
Version: 2.0.11
Release: 21%{?dist}
Source0: cobbler-%{version}.tar.gz
Source1: cobblerd.service
Patch0: catch_cheetah_exception.patch
Patch1: lvm_storage.patch
Patch2: koan_no_selinux_set.patch
Patch3: buildiso.patch
Patch4: koan-rhel7-virtinst.patch
Patch5: koan-extra-options.patch
Group: Applications/System
Requires: python >= 2.3

Provides: cobbler = %{version}-%{release}
Obsoletes: cobbler <= %{version}-%{release}

%if 0%{?suse_version} >= 1000
Requires: apache2
Requires: apache2-mod_python
Requires: tftp
%else
Requires: httpd
Requires: tftp-server
%endif

Requires: mod_wsgi

Requires: createrepo
%if 0%{?fedora}
%if 0%{?fedora} >= 19
Requires: fence-agents-all
%else
Requires: fence-agents
%endif
%endif
%if 0%{?fedora} >= 11 || 0%{?rhel} >= 6
Requires: genisoimage
%else
Requires: mkisofs
%endif
Requires: libyaml
Requires: python-cheetah
Requires: python-devel
Requires: python-netaddr
Requires: python-simplejson
%if 0%{?fedora} >= 8
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
%if 0%{?fedora} >= 6 || 0%{?rhel} >= 5
Requires: yum-utils
%endif

%if 0%{?fedora}
%if 0%{?fedora} > 18
BuildRequires: systemd
%else
Requires(post):  /bin/systemctl
Requires(preun): /bin/systemctl
%endif
%else
Requires(post):  /sbin/chkconfig
Requires(preun): /sbin/chkconfig
Requires(preun): /sbin/service
%endif

%if 0%{?fedora} >= 11 || 0%{?rhel} >= 6
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
%if 0%{?fedora} >= 9 || 0%{?rhel} >= 5
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
%if 0%{?fedora} > 8 || 0%{?rhel} >= 6
%{python_sitelib}/cobbler*.egg-info
%endif
%doc AUTHORS CHANGELOG README COPYING

%package -n koan

Summary: Helper tool that performs cobbler orders on remote machines.
Group: Applications/System
Requires: python >= 1.5
BuildRequires: python-devel
%if 0%{?fedora} >= 11 || 0%{?rhel} >= 6
%{!?pyver: %define pyver %(%{__python} -c "import sys ; print sys.version[:3]")}
Requires: python(abi) >= %{pyver}
%endif
%if 0%{?fedora} >= 8
BuildRequires: python-setuptools-devel
%endif
%if 0%{?rhel} >= 4
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
#%if 0%{?fedora} > 8
#%{python_sitelib}/koan*.egg-info
#%endif
%dir /var/spool/koan
%{_bindir}/koan
%{_bindir}/cobbler-register
%dir %{python_sitelib}/koan
%{python_sitelib}/koan/*.py*
%if 0%{?fedora} >= 9 || 0%{?rhel} >= 5
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
%if 0%{?fedora} >= 11 || 0%{?rhel} >= 6
%{!?pyver: %define pyver %(%{__python} -c "import sys ; print sys.version[:3]")}
Requires: python(abi) >= %{pyver}
%endif
%if 0%{?fedora} >= 8
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

