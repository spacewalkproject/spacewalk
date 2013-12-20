Summary: Support package for spacewalk koan interaction
Name: spacewalk-koan
Group: System Environment/Kernel
License: GPLv2
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 2.1.4
Release: 1%{?dist}
BuildArch : noarch
URL:            https://fedorahosted.org/spacewalk
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch:      noarch
BuildRequires:  python
Requires:       python >= 1.5
Requires:       koan >= 1.4.3
Requires:       xz
%if 0%{?suse_version}
# provide directories for filelist check in OBS
BuildRequires: rhn-client-tools
%endif
Conflicts: rhn-kickstart
Conflicts: rhn-kickstart-common
Conflicts: rhn-kickstart-virtualization

Requires: rhn-check

%description
Support package for spacewalk koan interaction.

%prep
%setup -q

%build
make -f Makefile.spacewalk-koan all

%install
rm -rf $RPM_BUILD_ROOT
make -f Makefile.spacewalk-koan install PREFIX=$RPM_BUILD_ROOT ROOT=%{_datadir}/rhn/ \
    MANDIR=%{_mandir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%config(noreplace)  %{_sysconfdir}/sysconfig/rhn/clientCaps.d/kickstart
%{_sbindir}/*
%{_datadir}/rhn/spacewalkkoan/
%{_datadir}/rhn/actions/

%changelog
* Fri Dec 20 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.4-1
- 967503 - use new Koan attribute

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.3-1
- cleaning up old svn Ids

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.2-1
- removed trailing whitespaces

* Thu Jul 25 2013 Stephen Herr <sherr@redhat.com> 2.1.1-1
- 988428 - Mark spacewalk-koan as correctly requiring the xz package
- Bumping package versions for 2.1.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- more branding cleanup

* Wed Mar 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.1-1
- do not call not existing function
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.2-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Mon Dec 17 2012 Jan Pazdziora 1.9.1-1
- properly specify device for 'ip route' command
- typo fix
- use ip instead of route to determine default gateway
- use ip instead of ifconfig to get networking info

* Tue Oct 30 2012 Jan Pazdziora 1.8.3-1
- Update the copyright year.

* Thu Aug 02 2012 Stephen Herr <sherr@redhat.com> 1.8.2-1
- 845326 - Show pretty error if customer specifies a MAC address already in use
- %%defattr is not needed since rpm 4.4

* Mon Mar 19 2012 Jan Pazdziora 1.8.1-1
- 803320 - support for xz packed ramdisk (mzazrivec@redhat.com)

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.1-1
- we are now just GPL

* Tue Dec 06 2011 Miroslav Suchý 1.6.3-1
- fix a rookie mistake (mzazrivec@redhat.com)
- IPv6: reprovisioning with static network interface (mzazrivec@redhat.com)
- fix TB during re-provisioning with static nic (mzazrivec@redhat.com)
- IPv6: routines to determine IPv6 address/netmask (mzazrivec@redhat.com)
- IPv6: don't include ::1 as a valid nameserver addr (mzazrivec@redhat.com)

* Wed Sep 07 2011 Martin Minar <mminar@redhat.com> 1.6.2-1
- 736066 - parse ifconfig output in POSIX locale only (mzazrivec@redhat.com)

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- We only support version 5 and newer of RHEL, removing conditions for old
  versions.

* Mon Jul 11 2011 Jan Pazdziora 0.2.20-1
- 691417 - allow extra whitespace behing nameserver IP in resolv.conf
  (tlestach@redhat.com)

* Fri May 27 2011 Jan Pazdziora 0.2.19-1
- 687850 - guest provisioning: correct block device detection
  (mzazrivec@redhat.com)

* Fri Apr 15 2011 Jan Pazdziora 0.2.18-1
- build spacewalk-koan on SUSE (mc@suse.de)

* Fri Apr 08 2011 Miroslav Suchý 0.2.17-1
- update copyright years (msuchy@redhat.com)

* Wed Feb 02 2011 Tomas Lestach <tlestach@redhat.com> 0.2.16-1
- Fixed typo in import subprocess (mmello@redhat.com)

* Tue Nov 02 2010 Jan Pazdziora 0.2.15-1
- Update copyright years in the rest of the repo.

* Fri Oct 29 2010 Michael Mraka <michael.mraka@redhat.com> 0.2.14-1
- spacewalk-koan should conflict with all rhn-kickstart subpackages

* Mon Oct 25 2010 Jan Pazdziora 0.2.13-1
- 645795 - changing spaceawlk-koan to use subproccess only if it is available
  and to fall back to popen2 if its not, this enables RHEL 4 support again
  (jsherril@redhat.com)

* Wed Oct 20 2010 Michael Mraka <michael.mraka@redhat.com> 0.2.12-1
- must not provide & conflict with same (unversioned) package

* Mon Oct 18 2010 Jan Pazdziora 0.2.11-1
- spacewalk-koan conflicts with any version of rhn-kickstart
  (michael.mraka@redhat.com)

* Mon Oct 18 2010 Jan Pazdziora 0.2.10-1
- 642629 - Disabling the defualt grubby copying behaviour in koan for args
  (paji@redhat.com)

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.2.9-1
- replaced local copy of compile.py with standard compileall module

* Fri Sep 24 2010 Justin Sherrill <jsherril@redhat.com> 0.2.8-1
- 637273 - fixing error with reprovisiong (unexpected keyword argument
  cache_only) (jsherril@redhat.com)

* Tue Jul 20 2010 Miroslav Suchý <msuchy@redhat.com> 0.2.7-1
- add parameter cache_only to all client actions (msuchy@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 0.2.6-1
- initializing variable within koan that is not initialized
  (jsherril@redhat.com)

