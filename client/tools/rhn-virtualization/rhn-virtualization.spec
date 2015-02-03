%define rhn_dir %{_datadir}/rhn
%define rhn_conf_dir %{_sysconfdir}/sysconfig/rhn
%define cron_dir %{_sysconfdir}/cron.d

Name:           rhn-virtualization 
Summary:        RHN/Spacewalk action support for virtualization

Group:          System Environment/Base
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz

Version:        5.4.55
Release:        1%{?dist}
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  python
%if 0%{?suse_version}
# make chkconfig work in OBS
BuildRequires: sysconfig syslog
%endif

%description
rhn-virtualization provides various RHN/Spacewalk actions for manipulation 
virtual machine guest images.

%package common
Summary: Files needed by rhn-virtualization-host
Group: System Environment/Base
Requires: rhn-client-tools
%if 0%{?suse_version}
# aaa_base provide chkconfig
Requires: aaa_base
# provide directories for filelist check in obs
BuildRequires: rhn-client-tools rhn-check
%else
Requires: chkconfig
%endif

%description common
This package contains files that are needed by the rhn-virtualization-host
package.

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

%changelog
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

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 5.4.42-1
- no use of /var/lock/subsys/ anymore

* Fri Aug 10 2012 Milan Zazrivec <mzazrivec@redhat.com> 5.4.41-1
- don't include localvdsm.py on fedora

* Fri Aug 10 2012 Milan Zazrivec <mzazrivec@redhat.com> 5.4.40-1
- fix file inclusion on a fedora build

* Fri Aug 10 2012 Jan Pazdziora 5.4.39-1
- 820862 - fix traceback on a fat rhev-3 host

* Fri Jul 13 2012 Stephen Herr <sherr@redhat.com> 5.4.38-1
- Automatic commit of package [rhn-virtualization] release [5.4.37-1].
- 839776 - rhn-profile-sync exits with status 1 if libvirtd is not running

* Thu Jul 12 2012 Stephen Herr <sherr@redhat.com> 5.4.37-1
- 839776 - rhn-profile-sync exits with status 1 if libvirtd is not running

* Mon Jun 04 2012 Miroslav Suchý <msuchy@redhat.com> 5.4.36-1
- Add support for studio image deployments (client) (jrenner@suse.de)
- %%defattr is not needed since rpm 4.4 (msuchy@redhat.com)

* Tue Mar 27 2012 Stephen Herr <sherr@redhat.com> 5.4.35-1
- 807028 - rhn-virtualization-host should not delete chkconfig settings on
  upgrade (sherr@redhat.com)

* Fri Mar 02 2012 Jan Pazdziora 5.4.34-1
- Update the copyright year info.

* Mon Feb 27 2012 Jan Pazdziora 5.4.33-1
- 796658 - we need R/W connection to do domain operations
  (mzazrivec@redhat.com)

* Thu Jan 26 2012 Jan Pazdziora 5.4.32-1
- 781421 - sys.stderr.write could not handle decoded unicode
  (msuchy@redhat.com)

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.4.31-1
- update copyright info

* Mon Oct 31 2011 Miroslav Suchý 5.4.30-1
- fix vm-state poller (ug@suse.de)

* Thu Oct 27 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.4.29-1
- 742811 - domain_directory: R/O access to libvirtd is sufficient

* Wed Oct 26 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.4.28-1
- 742811 - don't open RW connection to libvirt unless necessary

* Wed Oct 26 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.4.27-1
- 742811 - RHEV: handle no-guests situation correctly

* Wed Oct 05 2011 Martin Minar <mminar@redhat.com> 5.4.26-1
- 742811 - check for running vdsm only (colin.coe@gmail.com)

* Fri Aug 12 2011 Miroslav Suchý 5.4.25-1
- fix syntax errors

* Thu Aug 11 2011 Miroslav Suchý 5.4.24-1
- do not mask original error by raise in execption

* Thu May 19 2011 Miroslav Suchý 5.4.23-1
- simplify spec
- rhn-virtualization-host.noarch: E: incoherent-subsys /etc/rc.d/init.d/rhn-
  virtualization-host rhn-virtualization
- fix spelling error

* Fri Apr 15 2011 Jan Pazdziora 5.4.22-1
- build rhn-virtualization on SUSE (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 5.4.21-1
- update copyright years (msuchy@redhat.com)

* Thu Mar 10 2011 Miroslav Suchý <msuchy@redhat.com> 5.4.20-1
- 683546 - optparse isn't friendly to translations in unicode

* Wed Jan 05 2011 Miroslav Suchý <msuchy@redhat.com> 5.4.19-1
- 656241 - require libvirt
- Updating the copyright years to include 2010. (jpazdziora@redhat.com)

* Mon Dec 20 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.18-1
- 657516 - print nice warning if libvirtd is not running

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.17-1
- removed unused imports

* Sat Nov 20 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.16-1
- If libvirtd is not running do not throw traceback (msuchy@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 5.4.15-1
- Update copyright years in the rest of the repo.

* Tue Jul 20 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.14-1
- add parameter cache_only to all client actions (msuchy@redhat.com)

* Fri Jul 16 2010 Milan Zazrivec <mzazrivec@redhat.com> 5.4.13-1
- 591609 - 'Unknown' is not a valid virt. guest state

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.12-1
- Removing usused imports from rhn-virtualization/actions/virt.

