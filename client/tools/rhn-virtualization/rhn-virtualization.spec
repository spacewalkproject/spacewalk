%define rhn_dir %{_datadir}/rhn
%define rhn_conf_dir %{_sysconfdir}/sysconfig/rhn
%define cron_dir %{_sysconfdir}/cron.d

Name:           rhn-virtualization 
Summary:        RHN/Spacewalk action support for virualization

Group:          System Environment/Base
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz

Version:        5.4.6
Release:        1%{?dist}
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  python

%description
rhn-virtualization provides various RHN/Spacewalk actions for manipulation 
virtual machine guest images.

%package common
Summary: Files needed by both rhn-virtualization-host and -guest
Group: System Environment/Base
Requires: rhn-client-tools
Requires: chkconfig

%description common
This package contains files that are needed by the rhn-virtualization-host
and rhn-virtualization-guest packages.

%package host
Summary: RHN/Spacewalk Virtualization support specific to the Host system
Group: System Environment/Base
Requires: libvirt-python
Requires: rhn-virtualization-common
Conflicts: rhn-virtualization-guest

%description host
This package contains code for RHN's and Spacewalk's Virtualization support 
that is specific to the Host system (a.k.a. Dom0).

%package guest
Summary: RHN/Spacewalk Virtualization support specific to Guest systems
Group: System Environment/Base
Requires: rhn-virtualization-common
Conflicts: rhn-virtualization-host

%description guest
This package contains code for RHN's and Spacewalk's Virtualization support 
that is specific to Guest systems (a.k.a. DomUs).


%prep
%setup -q


%build
make -f Makefile.rhn-virtualization


%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.rhn-virtualization DESTDIR=$RPM_BUILD_ROOT install

 
%clean
rm -rf $RPM_BUILD_ROOT


%post host
/sbin/chkconfig --add rhn-virtualization-host
/sbin/service crond restart

%preun host
/sbin/chkconfig --del rhn-virtualization-host

%postun host
/sbin/service crond restart

%post guest
/sbin/chkconfig --add rhn-virtualization-guest
/sbin/service rhn-virtualization-guest start

%preun guest
/sbin/chkconfig --del rhn-virtualization-guest

%files common
%defattr(-,root,root,-)
%dir %{rhn_dir}/virtualization
%{rhn_dir}/virtualization/__init__.py
%{rhn_dir}/virtualization/__init__.pyc
%{rhn_dir}/virtualization/__init__.pyo
%{rhn_dir}/virtualization/batching_log_notifier.py
%{rhn_dir}/virtualization/batching_log_notifier.pyc
%{rhn_dir}/virtualization/batching_log_notifier.pyo
%{rhn_dir}/virtualization/constants.py
%{rhn_dir}/virtualization/constants.pyc
%{rhn_dir}/virtualization/constants.pyo
%{rhn_dir}/virtualization/errors.py
%{rhn_dir}/virtualization/errors.pyc
%{rhn_dir}/virtualization/errors.pyo
%{rhn_dir}/virtualization/notification.py
%{rhn_dir}/virtualization/notification.pyc
%{rhn_dir}/virtualization/notification.pyo
%{rhn_dir}/virtualization/util.py
%{rhn_dir}/virtualization/util.pyc
%{rhn_dir}/virtualization/util.pyo
%doc LICENSE

%files host
%defattr(-,root,root,-)
%dir %{rhn_conf_dir}/virt
%dir %{rhn_conf_dir}/virt/auto
%{_initrddir}/rhn-virtualization-host
%config(noreplace) %attr(644,root,root) %{cron_dir}/rhn-virtualization.cron
%{rhn_dir}/virtualization/domain_config.py
%{rhn_dir}/virtualization/domain_config.pyc
%{rhn_dir}/virtualization/domain_control.py
%{rhn_dir}/virtualization/domain_control.pyc
%{rhn_dir}/virtualization/domain_directory.py
%{rhn_dir}/virtualization/domain_directory.pyc
%{rhn_dir}/virtualization/get_config_value.py
%{rhn_dir}/virtualization/get_config_value.pyc
%{rhn_dir}/virtualization/init_action.py
%{rhn_dir}/virtualization/init_action.pyc
%{rhn_dir}/virtualization/poller.py
%{rhn_dir}/virtualization/poller.pyc
%{rhn_dir}/virtualization/schedule_poller.py
%{rhn_dir}/virtualization/schedule_poller.pyc
%{rhn_dir}/virtualization/poller_state_cache.py
%{rhn_dir}/virtualization/poller_state_cache.pyc
%{rhn_dir}/virtualization/start_domain.py
%{rhn_dir}/virtualization/start_domain.pyc
%{rhn_dir}/virtualization/state.py
%{rhn_dir}/virtualization/state.pyc
%{rhn_dir}/virtualization/support.py
%{rhn_dir}/virtualization/support.pyc
%{rhn_dir}/actions/virt.py
%{rhn_dir}/actions/virt.pyc
%{rhn_dir}/virtualization/domain_config.pyo
%{rhn_dir}/virtualization/domain_control.pyo
%{rhn_dir}/virtualization/domain_directory.pyo
%{rhn_dir}/virtualization/get_config_value.pyo
%{rhn_dir}/virtualization/init_action.pyo
%{rhn_dir}/virtualization/poller.pyo
%{rhn_dir}/virtualization/schedule_poller.pyo
%{rhn_dir}/virtualization/poller_state_cache.pyo
%{rhn_dir}/virtualization/start_domain.pyo
%{rhn_dir}/virtualization/state.pyo
%{rhn_dir}/virtualization/support.pyo
%{rhn_dir}/virtualization/localvdsm.py
%{rhn_dir}/virtualization/localvdsm.pyc
%{rhn_dir}/virtualization/localvdsm.pyo
%{rhn_dir}/actions/virt.pyo
%doc LICENSE

%files guest
%defattr(-,root,root,-)
%{_initrddir}/rhn-virtualization-guest
%{rhn_dir}/virtualization/report_uuid.py
%{rhn_dir}/virtualization/report_uuid.pyc
%{rhn_dir}/virtualization/report_uuid.pyo
%doc LICENSE

%changelog
* Sat Oct 03 2009 Pradeep Kilambi <pkilambi@redhat.com> 5.4.6-1
- fixing typo for server initialization for non ssl case in rhev code.
  (pkilambi@redhat.com)
- cleaning up conflicts (pkilambi@redhat.com)
-  Feature support for rhn-virt-host to poll guests through VDSM. 
   libvirt is disabled in this case. if libvirt is disabled.
   So the guest registration does'nt consume an entitlement following 
   the xen/kvm business rules on server.(pkilambi@redhat.com)

* Fri Oct 02 2009 Pradeep Kilambi <pkilambi@redhat.com> 5.3.0-5
- 526371 - Feature support for rhn-virt-host to poll guests through VDSM instead of libvirt.So the guest registration does'nt consume an entitlement following the xen/kvm business rules on server


* Fri Jul 10 2009 Pradeep Kilambi <pkilambi@redhat.com> 5.4.3-1
- 510606 - Fix rhn-virtualization package to work with kvm guests. This commit
  includes fixes for > > - Guest start - We assume pygrub for any guest. This
  fails for kvm as it the emulates the BIOS loading the first sector of the
  boot disk and running from there. So we dont need to probe the kernel and
  ramdisk. (pkilambi@redhat.com)

* Thu Jul 09 2009 John Matthews <jmatthew@redhat.com> 5.4.2-1
- 509602 - Fixing the is_host_domain to check both xen or kvm by virt type on
  libvirt connection instead of ugly file checks. This should fix the guest
  polling for kvm case and guest registrations inturn should follow thw xen
  rules (pkilambi@redhat.com)

* Thu Jun 25 2009 Brad Buckingham <bbuckingham@redhat.com> 5.4.1-1
- 470335 - Fixing EOF error when poller tries to pickle dump the data to cache
  file. (pkilambi@redhat.com)

* Tue Jun 16 2009 Brad Buckingham <bbuckingham@redhat.com> 5.3.0-1
- bumping version (bbuckingham@redhat.com)
- 502902 - If xend is not running instead of returning an empty list return an
  empty dict and let the registration and profile sync warn instead of failing
  (pkilambi@redhat.com)

* Tue May 26 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- 470335 - Fixed the name error where the class was not called from cPickle
  (pkilambi@redhat.com)

* Fri May 01 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.0-1
- Bump version up for 0.6.

* Mon Apr 20 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.1-1
- wrap long description lines (msuchy@redhat.com)
- point URL to fedorahosted.org (msuchy@redhat.com)
- properly use macros (msuchy@redhat.com)
- cron file should be marked as config file (msuchy@redhat.com)
- summary should not end with dot. Adding note about Spacewalk to description
  as well (msuchy@redhat.com)
- add LICENSE file (msuchy@redhat.com)

* Mon Feb 23 2009 Miroslav Suchy <msuchy@redhat.com>
- add LICENSE file
- remove rpmlint warnings

* Fri Jan 23 2009 Dennis Gilmore <dennis@ausil.us> - 0.4.3-1
* Fri Oct 24 2008 Pradeep Kilambi <pkilambi@redhat.com> - 0.3.2-1
- new build

* Thu Sep  4 2008 Pradeep Kilambi <pkilambi@redhat.com> - 0.2.1-1
- new build

* Fri Oct 06 2006 James Bowes <jbowes@redhat.com> - 1.0.1-13
- Require rhn-client-tools rather than up2date.

* Tue Sep 26 2006 Peter Vetere <pvetere@redhat.com> - 1.0.1-12
- Added batching_log_notifier file to common.

* Fri Sep 15 2006 James Bowes <jbowes@redhat.com> - 1.0.1-11
- Stop ghosting pyo files.

* Wed Sep 13 2006 Peter Vetere <pvetere@redhat.com> 1.0.1-10
- made host- and guest- specific names for their respective init scripts
- added an init script so the guest can report its uuid when it boots

* Wed Aug 30 2006 John Wregglesworth <wregglej@redhat.com> 1.0.1-7
- split the everything into three subpackages: common, host, guest
- added report_uuid.

* Wed Aug 02 2006 James Bowes <jbowes@redhat.com> 1.0.1-2
- get_name was renamed to get_config_value
- rhn_xen was renamed to rhn-virtualization

* Fri Jul 07 2006 James Bowes <jbowes@redhat.com> 1.0.1-1
- New version.
- Remove unused macro.

* Fri Jul 07 2006 James Bowes <jbowes@redhat.com> 0.0.1-1
- Initial packaging outside of up2date
