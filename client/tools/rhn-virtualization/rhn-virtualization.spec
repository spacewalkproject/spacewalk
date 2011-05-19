%define rhn_dir %{_datadir}/rhn
%define rhn_conf_dir %{_sysconfdir}/sysconfig/rhn
%define cron_dir %{_sysconfdir}/cron.d

Name:           rhn-virtualization 
Summary:        RHN/Spacewalk action support for virtualization

Group:          System Environment/Base
License:        GPLv2
URL:            https://fedorahosted.org/spacewalk
Source0:        https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz

Version:        5.4.23
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
%else
Requires: /usr/sbin/crond
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


%clean
rm -rf $RPM_BUILD_ROOT


%post host
/sbin/chkconfig --add rhn-virtualization-host
%if 0%{?suse_version}
/sbin/service cron try-restart ||:
%else
/sbin/service crond condrestart
%endif

%preun host
/sbin/chkconfig --del rhn-virtualization-host

%postun host
%if 0%{?suse_version}
/sbin/service cron try-restart ||:
%else
/sbin/service crond condrestart
%endif

%files common
%defattr(-,root,root,-)
%dir %{rhn_dir}/virtualization
%{rhn_dir}/virtualization/__init__.py*
%{rhn_dir}/virtualization/batching_log_notifier.py*
%{rhn_dir}/virtualization/constants.py*
%{rhn_dir}/virtualization/errors.py*
%{rhn_dir}/virtualization/notification.py*
%{rhn_dir}/virtualization/util.py*
%doc LICENSE

%files host
%defattr(-,root,root,-)
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
%{rhn_dir}/virtualization/localvdsm.py*
%doc LICENSE

%changelog
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

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.10-1
- updated copyrights

* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 5.4.9-1
- 548812 - include host info in the virt. guests refresh (mzazrivec@redhat.com)
- Methods __addElementValue and __addElementAttribute do not seem to be used anywhere, removing. (jpazdziora@redhat.com)
- 548812 - proper support for VDSM in rhn-virtualization (mzazrivec@redhat.com)

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 5.4.8-1
- 552271 - -host needs to require specific version of -common package
- 546676 - blocking and nostate are always just running
- 543980 - remove rhn-virtualization-guest script from Makefile
- 543980 - get rid of rhn-virtualization-guest package
- 543980 - remove scripts/rhn-virtualization-guest script
- 543980 - remove report_uuid.py
- 533283 - don't restart crond if it wasn't running before

* Wed Nov 25 2009 Miroslav Suchý <msuchy@redhat.com> 5.4.7-1
- 529688 - correctly detect Xen host
- 530583 - detect an installing config also with ks= parameter
- return back pieces still used by rhn-kickstart
- 529688 - correctly update virtualization profile for KVM guest
- missing commits from sat.git

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
