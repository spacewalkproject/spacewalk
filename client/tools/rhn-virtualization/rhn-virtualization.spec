%define rhn_dir %{_datadir}/rhn
%define rhn_conf_dir %{_sysconfdir}/sysconfig/rhn
%define cron_dir %{_sysconfdir}/cron.d

%if 0%{?fedora}
%global build_py3   1
%global default_py3 1
%endif

%define pythonX %{?default_py3: python3}%{!?default_py3: python2}

Name:           rhn-virtualization 
Summary:        RHN/Spacewalk action support for virtualization
Version:        5.4.61
Release:        1%{?dist}

Group:          System Environment/Base
License:        GPLv2
URL:            https://github.com/spacewalkproject/spacewalk
Source0:        https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
%if 0%{?suse_version}
# make chkconfig work in OBS
BuildRequires: sysconfig syslog
%endif

%description
rhn-virtualization provides various RHN/Spacewalk actions for manipulation 
virtual machine guest images.

%package -n python2-%{name}-common
Summary: Files needed by rhn-virtualization-host
%{?python_provide:%python_provide python2-%{name}-common}
Obsoletes: %{name}-common < 5.4.62
Requires: python2-rhn-client-tools
Requires: spacewalk-usix
BuildRequires: python
%if 0%{?suse_version}
# aaa_base provide chkconfig
Requires: aaa_base
# provide directories for filelist check in obs
BuildRequires: rhn-client-tools rhn-check
%else
Requires: chkconfig
%endif
%description -n python2-%{name}-common
This package contains files that are needed by the rhn-virtualization-host
package.

%if 0%{?build_py3}
%package -n python3-%{name}-common
Summary: Files needed by rhn-virtualization-host
%{?python_provide:%python_provide python3-%{name}-common}
Obsoletes: %{name}-common < 5.4.62
Requires: python3-spacewalk-usix
Requires: python3-rhn-client-tools
BuildRequires: python3-devel
%description -n python3-%{name}-common
This package contains files that are needed by the rhn-virtualization-host
package.
%endif

%package host
Summary: RHN/Spacewalk Virtualization support specific to the Host system
Group: System Environment/Base
Requires: libvirt-python
Requires: rhn-virtualization-common = %{version}-%{release}
%if 0%{?suse_version}
Requires: cron
Requires: python-curl
%else
Requires: /usr/sbin/crond
Requires: python-pycurl
%endif
%if 0%{?rhel} && 0%{?rhel} < 6
# in RHEL5 we need libvirt, but in RHEV@RHEL5 there should not be libvirt
# as there is vdsm and bunch of other packages, but we have no clue how to
# distinguish those two scenarios
%else
Requires: libvirt
%endif

%description host
This package contains code for RHN's and Spacewalk's Virtualization support 
that is specific to the Host system (a.k.a. Dom0).


%prep
%setup -q
%if 0%{?suse_version}
cp scripts/rhn-virtualization-host.SUSE scripts/rhn-virtualization-host
%endif
%if 0%{?fedora} >= 23
%global __python /usr/bin/python3
%endif

%build
make -f Makefile.rhn-virtualization


%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.rhn-virtualization DESTDIR=$RPM_BUILD_ROOT PKGDIR0=%{_initrddir} install
%if 0%{?fedora} || (0%{?rhel} && 0%{?rhel} > 5)
find $RPM_BUILD_ROOT -name "localvdsm*" -exec rm -f '{}' ';'
%endif

%clean
rm -rf $RPM_BUILD_ROOT


%post host
/sbin/chkconfig --add rhn-virtualization-host
%if 0%{?suse_version}
/sbin/service cron try-restart ||:
%else
/sbin/service crond condrestart
%endif
if [ -d /proc/xen ]; then
    # xen kernel is running
    # change the default template to the xen version
    sed -i 's@^IMAGE_CFG_TEMPLATE=/etc/sysconfig/rhn/studio-kvm-template.xml@IMAGE_CFG_TEMPLATE=/etc/sysconfig/rhn/studio-xen-template.xml@' /etc/sysconfig/rhn/image.cfg
fi

%preun host
if [ $1 = 0 ]; then
  /sbin/chkconfig --del rhn-virtualization-host
fi

%postun host
%if 0%{?suse_version}
/sbin/service cron try-restart ||:
%else
/sbin/service crond condrestart
%endif

%files common
%dir %{rhn_dir}/virtualization
%{rhn_dir}/virtualization/__init__.py*
%{rhn_dir}/virtualization/batching_log_notifier.py*
%{rhn_dir}/virtualization/constants.py*
%{rhn_dir}/virtualization/errors.py*
%{rhn_dir}/virtualization/notification.py*
%{rhn_dir}/virtualization/util.py*
%doc LICENSE
%if 0%{?fedora} >= 23
%dir %{rhn_dir}/virtualization/__pycache__
%{rhn_dir}/virtualization/__pycache__/__init__.*
%{rhn_dir}/virtualization/__pycache__/batching_log_notifier.*
%{rhn_dir}/virtualization/__pycache__/constants.*
%{rhn_dir}/virtualization/__pycache__/errors.*
%{rhn_dir}/virtualization/__pycache__/notification.*
%{rhn_dir}/virtualization/__pycache__/util.*
%endif

%files host
%if 0%{?suse_version}
%dir %{rhn_conf_dir}
%endif
%dir %{rhn_conf_dir}/virt
%dir %{rhn_conf_dir}/virt/auto
%{_initrddir}/rhn-virtualization-host
%config(noreplace) %attr(644,root,root) %{cron_dir}/rhn-virtualization.cron
%{rhn_dir}/virtualization/domain_config.py*
%{rhn_dir}/virtualization/domain_control.py*
%{rhn_dir}/virtualization/domain_directory.py*
%{rhn_dir}/virtualization/get_config_value.py*
%{rhn_dir}/virtualization/init_action.py*
%{rhn_dir}/virtualization/poller.py*
%{rhn_dir}/virtualization/schedule_poller.py*
%{rhn_dir}/virtualization/poller_state_cache.py*
%{rhn_dir}/virtualization/start_domain.py*
%{rhn_dir}/virtualization/state.py*
%{rhn_dir}/virtualization/support.py*
%{rhn_dir}/actions/virt.py*
%{rhn_dir}/actions/image.py*
%if 0%{?suse_version} || (0%{?rhel} && 0%{?rhel} < 6)
%{rhn_dir}/virtualization/localvdsm.py*
%endif
%{rhn_conf_dir}/studio-*-template.xml
%config(noreplace) %{rhn_conf_dir}/image.cfg
%doc LICENSE
%if 0%{?fedora} >= 23
%{rhn_dir}/virtualization/__pycache__/domain_config.*
%{rhn_dir}/virtualization/__pycache__/domain_control.*
%{rhn_dir}/virtualization/__pycache__/domain_directory.*
%{rhn_dir}/virtualization/__pycache__/get_config_value.*
%{rhn_dir}/virtualization/__pycache__/init_action.*
%{rhn_dir}/virtualization/__pycache__/poller.*
%{rhn_dir}/virtualization/__pycache__/schedule_poller.*
%{rhn_dir}/virtualization/__pycache__/poller_state_cache.*
%{rhn_dir}/virtualization/__pycache__/start_domain.*
%{rhn_dir}/virtualization/__pycache__/state.*
%{rhn_dir}/virtualization/__pycache__/support.*
%dir %{rhn_dir}/actions/__pycache__
%{rhn_dir}/actions/__pycache__/virt.*
%{rhn_dir}/actions/__pycache__/image.*
%endif

%changelog
* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.61-1
- purged changelog entries for Spacewalk 2.0 and older

* Wed Aug 09 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.60-1
- precompile py3 bytecode on Fedora 23+
- use standard brp-python-bytecompile

* Tue Jul 18 2017 Michael Mraka <michael.mraka@redhat.com> 5.4.59-1
- move version and release before sources

* Mon Jul 17 2017 Jan Dobes 5.4.58-1
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Wed Feb 15 2017 Tomas Kasparek <tkasparek@redhat.com> 5.4.57-1
- require spacewalk-usix indead of spacewalk-backend-usix

* Wed Oct 19 2016 Gennadii Altukhov <galt@redhat.com> 5.4.56-1
- 1379891 - make rhn-virtualization code compatible with Python 2/3

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 5.4.55-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.4.54-1
- fix copyright years

* Wed Apr 23 2014 Stephen Herr <sherr@redhat.com> 5.4.53-1
- 1089715 - some systems to not have /sbin in path

* Tue Apr 22 2014 Stephen Herr <sherr@redhat.com> 5.4.52-1
- 1089715 - service location is not platform independent

* Mon Apr 21 2014 Stephen Herr <sherr@redhat.com> 5.4.51-1
- 1089715 - rhn-virt-host should not spam root if libvirtd is stopped

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.4.50-1
- removed trailing whitespaces

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.4.49-1
- Grammar error occurred

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.4.48-1
- updating copyright years

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 5.4.47-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Fri May 03 2013 Tomas Lestach <tlestach@redhat.com> 5.4.46-1
- 915287 - python 2.4 does not know 'exit'
- 915287 - define a utf8_encode wrapper

* Thu Mar 28 2013 Jan Pazdziora 5.4.45-1
- isInstallerConfig should check for autoyast in commandline
- catch libvirtError to return meaningfull error messages

* Thu Feb 07 2013 Stephen Herr <sherr@redhat.com> 5.4.44-1
- 908899 - rhn-virtualization-host needs to consistantly use the new function
  definition

* Wed Feb 06 2013 Jan Pazdziora 5.4.43-1
- support studio KVM image type

