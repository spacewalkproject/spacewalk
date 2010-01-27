%define rhnroot /usr/share/rhn

Summary: Support scripts for auto-kickstarting systems
Name: rhn-kickstart
Group: System Environment/Kernel
License: GPLv2
Source0: %{name}-%{version}.tar.gz
Version: 5.4.1
Release: 1%{?dist}
BuildArch: noarch
BuildRequires: python
URL: http://rhn.redhat.com/
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

Requires: %{name}-common = %{version}-%{release}
Provides: rhn.kickstart.boot_image
Conflicts: auto-kickstart

# If this is rhel 4 or less we need up2date.
%if 0%{?rhel} && "%rhel" < "5"
Requires: up2date
%else
Requires: rhn-check
%endif

%description
Support scripts for auto-kickstarting systems
 

%package common
Summary: Common support scripts for auto-kickstarting systems
Group: System Environment/Kernel

# If this is rhel 4 or less we need up2date.
%if 0%{?rhel} && "%rhel" < "5"
Requires: up2date
%else
Requires: rhn-client-tools
%endif


%description common
Common support scripts for auto-kickstarting systems.


%if 0%{?rhel} == 0 || "%rhel" >= "5"
%package virtualization
Summary: Support scripts for auto-kickstarting virtual systems
Group: System Environment/Kernel
Requires: %{name}-common = %{version}-%{release}
Requires: rhn-virtualization-host
Requires: rhn-check
Requires: libvirt >= 0.2.3

%description virtualization
Support scripts for auto-kickstarting virtual systems.

%endif

%prep
%setup -q

%build
make -f Makefile.rhn-kickstart

%install
rm -rf $RPM_BUILD_ROOT

# Don't build virt stuff on rhel 4 and under.
%if 0%{?rhel} && "%rhel" < "5"
make -f Makefile.rhn-kickstart install PREFIX=$RPM_BUILD_ROOT NOVIRT=1
%else
make -f Makefile.rhn-kickstart install PREFIX=$RPM_BUILD_ROOT
%endif


%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/sbin/*
%config(noreplace)  /etc/sysconfig/rhn/clientCaps.d/kickstart

%{rhnroot}/actions/kickstart.py*

%{rhnroot}/rhnkickstart/lilo.py*
%{rhnroot}/rhnkickstart/kickstart.py*


%files common
%dir %{rhnroot}/rhnkickstart
%{rhnroot}/rhnkickstart/__init__.py*
%{rhnroot}/rhnkickstart/kickstart_exceptions.py*
%{rhnroot}/rhnkickstart/common.py*
%{rhnroot}/rhnkickstart/config.py*


%if 0%{?rhel} == 0 || "%rhel" >= "5"
%files virtualization

%{rhnroot}/actions/kickstart_guest.py*

%{rhnroot}/rhnkickstart/virtualization_kickstart_exceptions.py*
%{rhnroot}/rhnkickstart/kickstart_guest.py*

%endif

%changelog
* Wed Jan 27 2010 Miroslav Suchy <msuchy@redhat.com> 5.4.1-1
- replaced popen2 with subprocess in client (michael.mraka@redhat.com)

* Tue Jun 16 2009 Brad Buckingham <bbuckingham@redhat.com> 5.4.0-1
- bumping version (bbuckingham@redhat.com)

* Thu Jan 22 2009 Dennis Gilmore <dennis@ausil.us> 0.2.2-1
- BuildRequires python

* Thu Sep  4 2008 Pradeep Kilambi <pkilambi@redhat.com>  - 0.2.1-1
- rev build

* Tue Jun  3 2008 Brandon Perkins <bperkins@redhat.com> - 2.0.10-15
- Add support for provisioning s390x RHEL5.2 and greater systems.

* Tue Jan 08 2008 Devan Goodwin <dgoodwin@redhat.com> - 2.0.10-10
- Removed guest console monitoring code for stability.

* Tue Oct 09 2007 Pradeep Kilambi <pkilambi@redhat.com> - 2.0.10-5
- rev build

* Wed Mar 07 2007 Pradeep Kilambi <pkilambi@redhat.com> - 2.0.10-2
- rev build

* Tue Feb 27 2007 James Bowes <jbowes@redhat.com> - 2.0.10-1
- install in /usr/share/rhn/rhnkickstart to avoid namespace collisions

* Tue Feb 21 2007 James Bowes <jbowes@redhat.com> - 2.0.9-1
- Fix some tabbing issues.

* Mon Feb 20 2007 James Bowes <jbowes@redhat.com> - 2.0.8-1
- Install in kickstart rather than kickstart_libs, to avoid
  collisions with auto-kickstart.
- Have rhn-kickstart conflict with auto-kickstart

* Mon Feb 19 2007 James Bowes <jbowes@redhat.com> - 2.0.7-1
- Get rhn-kickstart running on rhel2.1 and rhel3

* Wed Feb 14 2007 James Bowes <jbowes@redhat.com> - 2.0.6-7
- Add provides for rhn.kickstart.boot_image

* Wed Nov 15 2006 James Bowes <jbowes@redhat.com> - 2.0.6-1
- Support for building without the virt code.

* Tue Nov 14 2006 James Bowes <jbowes@redhat.com> - 2.0.5-14
- Get the conditional depends on up2date to actually work.

* Tue Nov 14 2006 James Bowes <jbowes@redhat.com> - 2.0.5-13
- Put the requires and conflicts on the common package.

* Tue Nov 14 2006 James Bowes <jbowes@redhat.com> - 2.0.5-12
- Use the dist flag
- Require up2date on rhel4 and down; rhn-client-tools otherwise

* Thu Sep 14 2006 James Bowes <jbowes@redhat.com> - 2.0.5-5
- Stop ghosting pyo files.
- Conflict auto-kickstart.
- Require up2date so we can work on pre-rhel5.

* Mon Aug 07 2006 James Bowes <jbowes@redhat.com> - 2.0.5-1
- Have the consumer of the common API download the kickstart
  file itself. Needed for static IP address booting.

* Mon Jul 24 2006 James Bowes <jbowes@redhat.com> - 2.0.4-1
- Renamed to rhn-kickstart so that up2date will be able to
  install this rather than the old arch-specific version.

* Fri Jul 21 2006 James Bowes <jbowes@redhat.com> - 2.0.3-2
- auto-kickstart-virtualization requires rhn-virtualization

* Fri Jul 21 2006 James Bowes <jbowes@redhat.com> - 2.0.3-1
- New version.
- Make seperate packages for virtualization code.

* Tue Apr 04 2006 James Bowes <jbowes@redhat.com>
- Fix up local_network_install function

* Fri Mar 31 2006 James Bowes <jbowes@redhat.com>
- Removed everything for generating kernel rpms
- added provides boot image to auto-kickstart

* Thu Feb 23 2006 Bret McMillan <bretm@redhat.com>
- added rhel 4 U3

* Tue Oct 04 2005 Nick Hansen <nhansen@redhat.com>
- added rhel 4 U2
- cleaned up ordering in the spec a little more

* Thu Sep 22 2005 Nick Hansen <nhansen@redhat.com>
- added rhel 3 U6
- partitioned spec file for easier reading

* Wed Jun 15 2005 Jason Connor <jconnor@redhat.com>
- added rhel 4 u1

* Wed May 24 2005 Jason Connor <jconnor@redhat.con>
- added rhel 3 U5

* Tue Feb 11 2005 Jason Connor <jconnor@redhat.com>
- changed ia64,IPF path to /boot/efi insted of /boot

* Tue Feb 1 2005 Jason Connor <jconnor@redhat.com>
- add ia64 as,es,ws for rhel3u4 and rhel4

* Wed Jan 26 2005 Jason Connor <jconnor@redhat.com>
- add rhel 4 RC

* Wed Jan 19 2005 Jason Connor <jconnor@redhat.com>
- add rhel 4 for i386 and x86_64 from RHEL4-RC-re0107.0

* Mon Jan 17 2005 Jason Connor <jconnor@redhat.com>
- add rhel 2.1 U6
- add rhel 3 U4

* Wed Sep 15 2004 Chris MacLeod <cmacleod@redhat.com>  
- add rhel 2.1 U5
- add rhel 3 U3

* Wed Sep 15 2004 Chris MacLeod <cmacleod@redhat.com>  
- add rhel 2.1 U5
- add rhel 3 U3

* Wed Sep 15 2004 Chris MacLeod <cmacleod@redhat.com>  
- add rhel 2.1 U5
- add rhel 3 U3

* Tue Jun 15 2004 Mihai Ibanescu <misa@redhat.com> 1.4-1
- Bumped version to 1.4

* Tue May 18 2004 Chip Turner <cturner@redhat.com>
- add RHEL 2.1 U4

* Wed Jan 21 2004 Chip Turner <cturner@redhat.com>
- add RHEL3 U1

* Thu Jan 15 2004 Chip Turner <cturner@redhat.com> 1.1-1
- move to QU2 and QU3 of RHEL 2.1

* Tue Nov 25 2003 Mihai Ibanescu <misa@redhat.com>
- Added es and ws (2.1)

* Mon Nov 24 2003 Mihai Ibanescu <misa@redhat.com>
- Added capability for the action

* Fri Nov 21 2003 Mihai Ibanescu <misa@redhat.com>
- Added Red Hat Linux 9 images
- Taking ownership of directories

* Tue Sep 30 2003 Chip Turner <cturner@redhat.com>
- Initial build.
