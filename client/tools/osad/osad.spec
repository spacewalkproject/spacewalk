%global rhnroot /usr/share/rhn
%global rhnconf /etc/sysconfig/rhn
%global client_caps_dir /etc/sysconfig/rhn/clientCaps.d
%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

%if 0%{?suse_version}
%global apache_group www
%global apache_user wwwrun
%global include_selinux_package 0
%else
%global apache_group apache
%global apache_user apache
%global include_selinux_package 1
%endif

%if 0%{?fedora} || 0%{?rhel} >= 8
%global build_py3   1
%global default_py3 1
%endif

%if ( 0%{?fedora} && 0%{?fedora} < 28 ) || ( 0%{?rhel} && 0%{?rhel} < 8 )
%global build_py2   1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Name: osad
Summary: Open Source Architecture Daemon
License: GPLv2
Version: 5.11.100
Release: 1%{?dist}
URL:     https://github.com/spacewalkproject/spacewalk
Source0: https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch: noarch
%if 0%{?fedora} > 26
BuildRequires: perl-interpreter
%else
BuildRequires: perl
%endif
Requires: %{pythonX}-%{name} = %{version}-%{release}
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
%if 0%{?fedora} || 0%{?rhel} >= 7
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

%if 0%{?build_py2}
%package -n python2-%{name}
Summary: Open Source Architecture Daemon
%{?python_provide:%python_provide python2-%{name}}
Requires: %{name} = %{version}-%{release}
Requires: python
Requires: rhnlib >= 2.8.3
Requires: spacewalk-usix
Requires: jabberpy
Requires: python2-rhn-client-tools >= 2.8.4
Requires: python2-osa-common = %{version}
%if 0%{?rhel} && 0%{?rhel} <= 5
Requires: python-hashlib
%endif
BuildRequires: python-devel
%description -n python2-%{name}
Python 2 specific files for %{name}
%endif

%if 0%{?build_py3}
%package -n python3-%{name}
Summary: Open Source Architecture Daemon
%{?python_provide:%python_provide python3-%{name}}
Requires: %{name} = %{version}-%{release}
Requires: python3
Requires: python3-rhnlib >= 2.8.3
Requires: python3-spacewalk-usix
Requires: python3-jabberpy
Requires: python3-rhn-client-tools >= 2.8.4
Requires: python3-osa-common = %{version}
BuildRequires: python3-devel
%description -n python3-%{name}
Python 3 specific files for %{name}
%endif

%if 0%{?build_py2}
%package -n python2-osa-common
Summary: OSA common files
Requires: jabberpy
Conflicts: %{name} < %{version}-%{release}
Conflicts: %{name} > %{version}-%{release}
Obsoletes: osa-common <= 5.11.91
Provides:  osa-common = %{version}
%description -n python2-osa-common
Python 2 common files needed by osad and osa-dispatcher
%endif

%if 0%{?build_py3}
%package -n python3-osa-common
Summary: OSA common files
Requires: python3-jabberpy
Conflicts: %{name} < %{version}-%{release}
Conflicts: %{name} > %{version}-%{release}
Obsoletes: osa-common <= 5.11.91
Provides:  osa-common = %{version}
%description -n python3-osa-common
Python 3 common files needed by osad and osa-dispatcher
%endif

%package -n osa-dispatcher
Summary: OSA dispatcher
Requires: spacewalk-backend-server >= 1.2.32
Requires: python2-osa-dispatcher = %{version}-%{release}
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

%if 0%{?build_py2}
%package -n python2-osa-dispatcher
Summary: OSA dispatcher
%if 0%{?fedora} >= 28
BuildRequires: python2-devel
Requires: python2
%else
BuildRequires: python-devel
Requires: python
%endif
Requires: jabberpy
Requires: python2-osa-common = %{version}
%description -n python2-osa-dispatcher
Python 2 specific files for osa-dispatcher.
%endif

%if 0%{?build_py3}
%package -n python3-osa-dispatcher
Summary: OSA dispatcher
BuildRequires: python3-devel
Requires: python3
Requires: python3-jabberpy
Requires: python3-osa-common = %{version}
%description -n python3-osa-dispatcher
Python 3 specific files for osa-dispatcher.
%endif

%if 0%{?include_selinux_package}
%package -n osa-dispatcher-selinux
%global selinux_variants mls strict targeted
%global selinux_policyver %(sed -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2> /dev/null)
%global POLICYCOREUTILSVER 1.33.12-1

%global moduletype apps
%global modulename osa-dispatcher

Summary: SELinux policy module supporting osa-dispatcher
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
%if 0%{?fedora} || (0%{?rhel} && 0%{?rhel} > 5)
sed -i 's@^#!/usr/bin/python$@#!/usr/bin/python -s@' invocation.py
%endif

%build
make -f Makefile.osad all PYTHONPATH=%{python_sitelib}

%if 0%{?include_selinux_package}
%{__perl} -i -pe 'BEGIN { $VER = join ".", grep /^\d+$/, split /\./, "%{version}.%{release}"; } s!\@\@VERSION\@\@!$VER!g;' osa-dispatcher-selinux/%{modulename}.te
%if 0%{?fedora} || 0%{?rhel} >= 7
cat osa-dispatcher-selinux/%{modulename}.te.fedora17 >> osa-dispatcher-selinux/%{modulename}.te
%endif
%if 0%{?fedora} >= 26
cat osa-dispatcher-selinux/%{modulename}.te.fedora26 >> osa-dispatcher-selinux/%{modulename}.te
%endif
for selinuxvariant in %{selinux_variants}
do
    make -C osa-dispatcher-selinux NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv osa-dispatcher-selinux/%{modulename}.pp osa-dispatcher-selinux/%{modulename}.pp.${selinuxvariant}
    make -C osa-dispatcher-selinux NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done
%endif

%install
install -d $RPM_BUILD_ROOT%{rhnroot}
%if 0%{?build_py2}
make -f Makefile.osad install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} INITDIR=%{_initrddir} \
        PYTHONPATH=%{python_sitelib} PYTHONVERSION=%{python_version}
%endif
%if 0%{?build_py3}
make -f Makefile.osad install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} INITDIR=%{_initrddir} \
        PYTHONPATH=%{python3_sitelib} PYTHONVERSION=%{python3_version}
sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' $RPM_BUILD_ROOT/usr/sbin/osad-%{python3_version}
%endif

%define default_suffix %{?default_py3:-%{python3_version}}%{!?default_py3:-%{python_version}}
ln -s osad%{default_suffix} $RPM_BUILD_ROOT/usr/sbin/osad
# osa-dispatcher is python2 even on Fedora
ln -s osa-dispatcher-%{python_version} $RPM_BUILD_ROOT/usr/sbin/osa-dispatcher

mkdir -p %{buildroot}%{_var}/log/rhn
touch %{buildroot}%{_var}/log/osad
touch %{buildroot}%{_var}/log/rhn/osa-dispatcher.log

%if 0%{?fedora} || 0%{?rhel} > 6
sed -i 's/#LOGROTATE-3.8#//' $RPM_BUILD_ROOT%{_sysconfdir}/logrotate.d/osa-dispatcher
%endif

%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?rhel} >= 7
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
    %if 0%{?fedora} || 0%{?rhel} >= 7
    %systemd_preun osad.service
    %else
    /sbin/service osad stop > /dev/null 2>&1
    /sbin/chkconfig --del osad
    %endif
fi
%endif

%postun
%if 0%{?fedora} || 0%{?rhel} >= 7
%systemd_postun_with_restart osad.service
%else
%if 0%{?suse_version} >= 1210
%service_del_postun osad.service
%endif
%endif

%if 0%{?suse_version} >= 1210
%pre
%service_add_pre osad.service

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
if [ -f %{_unitdir}/osa-dispatcher.service ]; then
    %systemd_post osa-dispatcher.service
    if [ "$1" = "2" ]; then
        # upgrade from old init.d
        if [ -L /etc/rc2.d/S86osa-dispatcher ]; then
            /usr/bin/systemctl enable osa-dispatcher.service >/dev/null 2>&1
        fi
        rm -f /etc/rc?.d/[SK]??osa-dispatcher
    fi
fi
%endif

%preun -n osa-dispatcher
%if 0%{?suse_version} >= 1210
%service_del_preun osa-dispatcher.service
%else
if [ $1 = 0 ]; then
    %if 0%{?fedora} || 0%{?rhel} >= 7
    %systemd_preun osa-dispatcher.service
    %else
    /sbin/service osa-dispatcher stop > /dev/null 2>&1
    /sbin/chkconfig --del osa-dispatcher
    %endif
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
  for selinuxvariant in %{selinux_variants}
    do
      /usr/sbin/semanage module -s ${selinuxvariant} -l > /dev/null 2>&1 \
        && /usr/sbin/semodule -s ${selinuxvariant} -r %{modulename} || :
    done
fi

rpm -ql osa-dispatcher | xargs -n 1 /sbin/restorecon -rvi {}
/sbin/restorecon -vvi /var/log/rhn/osa-dispatcher.log
%endif

%files
%{_sbindir}/osad
%config(noreplace) %{_sysconfdir}/sysconfig/rhn/osad.conf
%verify(not md5 mtime size) %config(noreplace) %attr(600,root,root) %{_sysconfdir}/sysconfig/rhn/osad-auth.conf
%config(noreplace) %{client_caps_dir}/*
%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?rhel} >= 7
%{_unitdir}/osad.service
%else
%attr(755,root,root) %{_initrddir}/osad
%endif
%doc LICENSE
%config(noreplace) %attr(644,root,root) %{_sysconfdir}/logrotate.d/osad
%ghost %attr(600,root,root) %{_var}/log/osad
%if 0%{?suse_version}
# provide directories not owned by any package during build
%dir %{_sysconfdir}/sysconfig/rhn
%dir %{_sysconfdir}/sysconfig/rhn/clientCaps.d
%endif

%if 0%{?build_py2}
%files -n python2-%{name}
%attr(755,root,root) %{_sbindir}/osad-%{python_version}
%dir %{python_sitelib}/osad
%{python_sitelib}/osad/osad.py*
%{python_sitelib}/osad/osad_client.py*
%{python_sitelib}/osad/osad_config.py*
%endif

%if 0%{?build_py3}
%files -n python3-%{name}
%attr(755,root,root) %{_sbindir}/osad-%{python3_version}
%dir %{python3_sitelib}/osad
%{python3_sitelib}/osad/osad.py*
%{python3_sitelib}/osad/osad_client.py*
%{python3_sitelib}/osad/osad_config.py*
%dir %{python3_sitelib}/osad/__pycache__
%{python3_sitelib}/osad/__pycache__/osad.*
%{python3_sitelib}/osad/__pycache__/osad_client.*
%{python3_sitelib}/osad/__pycache__/osad_config.*
%endif

%files -n osa-dispatcher
%{_sbindir}/osa-dispatcher
%config(noreplace) %{_sysconfdir}/sysconfig/osa-dispatcher
%config(noreplace) %{_sysconfdir}/logrotate.d/osa-dispatcher
%{rhnroot}/config-defaults/rhn_osa-dispatcher.conf
%dir %{_sysconfdir}/rhn/tns_admin
%dir %{_sysconfdir}/rhn/tns_admin/osa-dispatcher
%config(noreplace) %{_sysconfdir}/rhn/tns_admin/osa-dispatcher/sqlnet.ora
%if 0%{?fedora} || 0%{?suse_version} >= 1210 || 0%{?rhel} >= 7
%{_unitdir}/osa-dispatcher.service
%else
%attr(755,root,root) %{_initrddir}/osa-dispatcher
%endif
%attr(770,root,%{apache_group}) %dir %{_var}/log/rhn/oracle
%attr(770,root,root) %dir %{_var}/log/rhn/oracle/osa-dispatcher
%doc LICENSE
%ghost %attr(640,%{apache_user},root) %{_var}/log/rhn/osa-dispatcher.log
%if 0%{?suse_version}
%attr(750,root,%{apache_group}) %dir %{_sysconfdir}/rhn
%dir %{rhnroot}
%attr(755,root,%{apache_group}) %dir %{rhnroot}/config-defaults
%dir %{_var}/log/rhn
%endif

%if 0%{?build_py2}
%files -n python2-osa-dispatcher
%attr(755,root,root) %{_sbindir}/osa-dispatcher-%{python_version}
%dir %{python_sitelib}/osad
%{python_sitelib}/osad/osa_dispatcher.py*
%{python_sitelib}/osad/dispatcher_client.py*
%endif

%if 0%{?build_py3}
%files -n python3-osa-dispatcher
%attr(755,root,root) %{_sbindir}/osa-dispatcher-%{python3_version}
%dir %{python3_sitelib}/osad
%{python3_sitelib}/osad/osa_dispatcher.py*
%{python3_sitelib}/osad/dispatcher_client.py*
%{python3_sitelib}/osad/__pycache__/osa_dispatcher.*
%{python3_sitelib}/osad/__pycache__/dispatcher_client.*
%endif

%if 0%{?build_py2}
%files -n python2-osa-common
%{python_sitelib}/osad/__init__.py*
%{python_sitelib}/osad/jabber_lib.py*
%{python_sitelib}/osad/rhn_log.py*
%endif

%if 0%{?build_py3}
%files -n python3-osa-common
%{python3_sitelib}/osad/__init__.py*
%{python3_sitelib}/osad/jabber_lib.py*
%{python3_sitelib}/osad/rhn_log.py*
%{python3_sitelib}/osad/__pycache__/__init__.*
%{python3_sitelib}/osad/__pycache__/jabber_lib.*
%{python3_sitelib}/osad/__pycache__/rhn_log.*
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
* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 5.11.100-1
- use python3 for rhel8 in osad

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 5.11.99-1
- removed %%%%defattr from specfile
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Mon Oct 23 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.98-1
- osad: add missing directory to filelist

* Fri Oct 20 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.97-1
- use sssd macros only on Fedora 26

* Wed Oct 18 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.96-1
- 1501866 - osa-dispatcher is now link to actual executable

* Mon Oct 09 2017 Tomas Kasparek <tkasparek@redhat.com> 5.11.95-1
- 1451770 - simplify expression using format_exc

* Fri Oct 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.94-1
- install files into python_sitelib/python3_sitelib
- move osa-dispatcher files into proper python2/python3 subpackages
- move osa-common files into proper python2/python3 subpackages
- move osad files into proper python2/python3 subpackages
- split osa-dispatcher into python2/python3 specific packages
- split osa-common into python2/python3 specific packages
- split osad into python2/python3 specific packages

* Thu Oct 05 2017 Tomas Kasparek <tkasparek@redhat.com> 5.11.93-1
- (bz#1491451) osad: set KillMode=process in systemd unit
- 1494389 - Revert "[1260527] RHEL7 reboot loop"

* Tue Oct 03 2017 Tomas Kasparek <tkasparek@redhat.com> 5.11.92-1
- Revert "(bz#1491451) osad: set KillMode=process in systemd unit"
- (bz#1491451) osad: set KillMode=process in systemd unit

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.91-1
- purged changelog entries for Spacewalk 2.0 and older
- fixed selinux error messages during package install, see related BZ#1446487

* Mon Aug 21 2017 Jan Dobes 5.11.90-1
- 1373789 - fixing permissions for logrotate file

* Thu Aug 10 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.89-1
- make sure osa_dispatcher_upstream_notif_server_port_t has been removed

* Thu Aug 10 2017 Tomas Kasparek <tkasparek@redhat.com> 5.11.88-1
- 1479849 - BuildRequires: perl has been renamed to perl-interpreter on Fedora
  27

* Mon Aug 07 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.87-1
- recompile osa-dispatcher with py2 even on F23+

* Thu Aug 03 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.86-1
- 1477753 - use standard brp-python-bytecompile to make proper .pyc/.pyo

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 5.11.85-1
- update copyright year

* Thu Jul 27 2017 Eric Herget <eherget@redhat.com> 5.11.84-1
- 1446487 - spacewalk-selinux error messages during package install

* Tue Jul 25 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.83-1
- 1471946 - allow osad to work with older RHEL6 and RHEL7 rhnlib

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 5.11.82-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 5.11.81-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- fix TypeError: descriptor 'with_traceback'

* Thu Feb 16 2017 Eric Herget <eherget@redhat.com> 5.11.80-1
- BZ1410781 - osad doesn't pick up tasks following a reboot event

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 5.11.79-1
- require spacewalk-usix indead of spacewalk-backend-usix

* Tue Feb 07 2017 Eric Herget <eherget@redhat.com> 5.11.78-1
- 1419199 - fix osa_dispatcher so it can successfully register with jabberd

* Mon Jan 23 2017 Jan Dobes 5.11.77-1
- removing selinux port requirements
- Drop code used from the Perl stack to 'trickle' OSAD

* Tue Nov 29 2016 Jan Dobes 5.11.76-1
- perl isn't in Fedora 25 buildroot

* Mon Nov 21 2016 Gennadii Altukhov <galt@redhat.com> 5.11.75-1
- 1397078: fix python2/3 StringIO import

* Fri Nov 11 2016 Jiri Dostal <jdostal@redhat.com> 5.11.74-1
- [1260527] RHEL7 reboot loop

* Thu Sep 29 2016 Jiri Dostal <jdostal@redhat.com> 5.11.73-1
- Fix of verification of /etc/sysconfig/rhn/osad-auth.conf file

* Fri Sep 23 2016 Grant Gainey 5.11.72-1
- 1277448 - Link ssl-failure-log to associated solution-article

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 5.11.71-1
- updating copyright years

* Thu May 12 2016 Gennadii Altukhov <galt@redhat.com> 5.11.70-1
- change interpreter on python2 for osa-dispatcher

* Tue May 10 2016 Grant Gainey 5.11.69-1
- osad: fix permissions on directories

* Wed May 04 2016 Gennadii Altukhov <galt@redhat.com> 5.11.68-1
- 1332224 - service osad doesn't work with selinux

* Tue May 03 2016 Gennadii Altukhov <galt@redhat.com> 5.11.67-1
- Adapt osad to work  in python 2/3
- remove local ConfigParser which was used for Python 1.5

* Fri Apr 29 2016 Tomas Kasparek <tkasparek@redhat.com> 5.11.66-1
- fix typo in error message

* Tue Apr 26 2016 Tomas Kasparek <tkasparek@redhat.com> 5.11.65-1
- provide Knowledgebase article hint in case of connection fails

* Fri Feb 12 2016 Gennadii Altukhov <galt@redhat.com> 5.11.64-1
- 1306541 - Add possibility for OSAD to work in failover mode

* Thu Nov 19 2015 Tomas Kasparek <tkasparek@redhat.com> 5.11.63-1
- osad: re-send subscription stanzas after a while

* Tue Jun 23 2015 Tomas Kasparek <tkasparek@redhat.com> 5.11.62-1
- allow exexmem to osa-dispatcher

* Fri Jun 19 2015 Tomas Kasparek <tkasparek@redhat.com> 5.11.61-1
- auto-healing for duplicate jabber ids

* Fri Jun 05 2015 Tomas Kasparek <tkasparek@redhat.com> 5.11.60-1
- Add logging of error stanzas
- Add error logging to debug log
- Refactoring: inline method used only once
- Refactoring: remove modification to unused variable

* Thu May 14 2015 Stephen Herr <sherr@redhat.com> 5.11.59-1
- define the order of pending clients
- explain the new notify_threshold param
- introduce notify_threshold for osa-dispatcher (bsc#915581)

* Fri Apr 10 2015 Matej Kollar <mkollar@redhat.com> 5.11.58-1
- Improve osad's handling of the rhn_check process.

* Wed Mar 25 2015 Grant Gainey 5.11.57-1
- Move common files shared between osad and osa-dispatcher its own package.
  This allows osad and osa-dispatcher to coexist.

* Thu Mar 19 2015 Grant Gainey 5.11.56-1
- Updating copyright info for 2015

* Thu Mar 05 2015 Stephen Herr <sherr@redhat.com> 5.11.55-1
- osa-dispatcher: check for reboot type only

* Mon Feb 09 2015 Matej Kollar <mkollar@redhat.com> 5.11.54-1
- Updating function names

* Fri Jan 30 2015 Stephen Herr <sherr@redhat.com> 5.11.53-1
- Apply needed SElinux fix for RHEL7 and make use of systemd unit files

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 5.11.52-1
- move %%pre section down and eliminate an %%if

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 5.11.51-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Dec 05 2014 Stephen Herr <sherr@redhat.com> 5.11.50-1
- fix osad postun section

* Thu Nov 20 2014 Tomas Kasparek <tkasparek@redhat.com> 5.11.49-1
- Revert "autostart osad after package installation"

* Wed Nov 12 2014 Tomas Kasparek <tkasparek@redhat.com> 5.11.48-1
- autostart osad after package installation

* Tue Nov 04 2014 Stephen Herr <sherr@redhat.com> 5.11.47-1
- 1117343 - fix osad through unauthenticated proxy case

* Thu Sep 25 2014 Stephen Herr <sherr@redhat.com> 5.11.46-1
- 1125432 - self-heal jabberd connection to proxies if satellite restarts

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 5.11.45-1
- increasing osad version to be above builds in SPACEWALK-2.2

* Thu Jul 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.41-1
- osad: fix traceback if http proxy is not configured

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.40-1
- fix copyright years

* Tue Jul 08 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.39-1
- 1117343 - osad: support communication over proxy

* Fri Jun 20 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.38-1
- start osad after package installation on sysvinit systems

* Tue Jun 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.37-1
- RHEL-5 python doesn't support -s option

* Mon Jun 09 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.36-1
- don't add user site dir to sys.path

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.11.35-1
- spec file polish

* Mon Mar 31 2014 Stephen Herr <sherr@redhat.com> 5.11.34-1
- make reboot_in_progress a public function
- do not notify osad of a server which reboot is in progress

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

