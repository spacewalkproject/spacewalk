%global rhnroot %{_datadir}/rhn
%global rhnconf %{_sysconfdir}/sysconfig/rhn
%global client_caps_dir %{rhnconf}/clientCaps.d

Name: rhncfg
Summary: Red Hat Network Configuration Client Libraries
Group:   Applications/System
License: GPLv2 and Python
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 5.9.53
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: docbook-utils
BuildRequires: python
Requires: python
Requires: rhnlib >= 2.5.32
Requires: rhn-client-tools
Requires: libselinux-python

%description 
The base libraries and functions needed by all rhncfg-* packages.

%package client
Summary: Red Hat Network Configuration Client
Group:   Applications/System
Requires: %{name} = %{version}-%{release}
Requires: spacewalk-backend-libs >= 1.3.32-1

%description client
A command line interface to the client features of the RHN Configuration
Management system. 

%package management
Summary: Red Hat Network Configuration Management Client
Group:   Applications/System
Requires: %{name} = %{version}-%{release}

%description management
A command line interface used to manage RHN configuration.

%package actions
Summary: Red Hat Network Configuration Client Actions
Group:   Applications/System
Requires: %{name} = %{version}-%{release}
Requires: %{name}-client

%description actions
The code required to run configuration actions scheduled via the RHN website or
RHN Satellite or Spacewalk.

%prep
%setup -q

%build
make -f Makefile.rhncfg all

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make -f Makefile.rhncfg install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir}
mkdir -p $RPM_BUILD_ROOT/%{_sharedstatedir}/rhncfg/backups

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{rhnroot}/config_common
%{_sharedstatedir}/rhncfg/backups
%doc LICENSE PYTHON-LICENSES.txt

%files client
%defattr(-,root,root,-)
%{rhnroot}/config_client
%{_bindir}/rhncfg-client
%attr(644,root,root) %config(noreplace) %{rhnconf}/rhncfg-client.conf
%{_mandir}/man8/rhncfg-client.8*

%files management
%defattr(-,root,root,-)
%{rhnroot}/config_management
%{_bindir}/rhncfg-manager
%attr(644,root,root) %config(noreplace) %{rhnconf}/rhncfg-manager.conf
%{_mandir}/man8/rhncfg-manager.8*

%files actions
%defattr(-,root,root,-)
%{rhnroot}/actions/*
%{_bindir}/rhn-actions-control
%config(noreplace) %{client_caps_dir}/*
%{_mandir}/man8/rhn-actions-control.8*

# $Id$
%changelog
* Mon Apr 11 2011 Michael Mraka <michael.mraka@redhat.com> 5.9.53-1
- fixed moved imports
- don't make link target absolute
- 683264 - fixed extraneous directory creation via rhncfg-manager

* Fri Apr 08 2011 Michael Mraka <michael.mraka@redhat.com> 5.9.52-1
- fixed symlink deployment via rhn_check
- 683264 - rootdir is / when called from rhn_check

* Fri Apr 08 2011 Michael Mraka <michael.mraka@redhat.com> 5.9.51-1
- don't rollback transaction if symlink already exists
- fixed traceback during rollback
- don't fail if link points to directory

* Thu Mar 24 2011 Jan Pazdziora 5.9.50-1
- 688461 - try/except is workaround of BZ 690238 (msuchy@redhat.com)
- 688461 - fixed python exception when comparing files using web UI and SELinux
  disabled in RHEL6 (mmello@redhat.com)

* Tue Feb 15 2011 Miroslav Suchý <msuchy@redhat.com> 5.9.49-1
- 675164 - do not traceback if file do not differ (msuchy@redhat.com)
- 676317 - handle fs objects without selinux context correctly
  (mzazrivec@redhat.com)
- 628920 - older Satellites do not send selinux_ctx (msuchy@redhat.com)
- 675164 - do not traceback if file do not differ (msuchy@redhat.com)
- Revert "Revert "get_server_capability() is defined twice in osad and rhncfg,
  merge and move to rhnlib and make it member of rpclib.Server""
  (msuchy@redhat.com)

* Tue Feb 01 2011 Tomas Lestach <tlestach@redhat.com> 5.9.48-1
- Revert "get_server_capability() is defined twice in osad and rhncfg, merge
  and move to rhnlib and make it member of rpclib.Server" (tlestach@redhat.com)

* Fri Jan 28 2011 Miroslav Suchý <msuchy@redhat.com> 5.9.47-1
- get_server_capability() is defined twice in osad and rhncfg, merge and move
  to rhnlib and make it member of rpclib.Server

* Thu Jan 20 2011 Tomas Lestach <tlestach@redhat.com> 5.9.46-1
- updating Copyright years for year 2011 (tlestach@redhat.com)
- 628920 - rhel4 does not support selinux (msuchy@redhat.com)

* Fri Jan 07 2011 Michael Mraka <michael.mraka@redhat.com> 5.9.45-1
- fixed TypeError: unsupported operand type(s) for +: 'NoneType' and 'str'

* Fri Jan 07 2011 Michael Mraka <michael.mraka@redhat.com> 5.9.44-1
- fixed NameError: global name 'os' is not defined
- 634963 - satellites <= 5.4 do not send modified value

* Thu Jan 06 2011 Michael Mraka <michael.mraka@redhat.com> 5.9.43-1
- 637833 - reused shared file deploy code
- 637833 - moved file deploy code into shared module

* Mon Jan 03 2011 Tomas Lestach <tlestach@redhat.com> 5.9.42-1
- 634963 - adding extra colon (tlestach@redhat.com)

* Mon Jan 03 2011 Miroslav Suchý <msuchy@redhat.com> 5.9.41-1
- 634963 - indicate change in selinux, ownership or file mode (even if diff is
  empty)
- do not fail if diff do not differ
- do diff directly in memory
- Updating the copyright years to include 2010. (jpazdziora@redhat.com)

* Thu Dec 23 2010 Jan Pazdziora 5.9.40-1
- make _make_stat_info public method (msuchy@redhat.com)
- create new function get_raw_file_info for case, when we do not need file on
  disk (msuchy@redhat.com)

* Wed Dec 22 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.39-1
- if file is excluded skip also deploy preparation
- use difflib instead of external diff command
- made exception block more readable
- 664677 - fixed directory deployment under --topdir
- 664677 - fixed symlink deployment under --topdir 

* Mon Dec 20 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.38-1
- 628846 - fixed symlink info

* Wed Dec 08 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.37-1
- import Fault, ResponseError and ProtocolError directly from xmlrpclib

* Wed Dec 01 2010 Lukas Zapletal 5.9.36-1
- 644985 - SELinux context cleared from RHEL4 rhncfg-client
- Correcting indentation for rhn_main.py

* Fri Nov 26 2010 Jan Pazdziora 5.9.35-1
- 656895 - fixing other instances of two-parameter utils.startswith.
- 656895 - Need to call startswith on string.

* Wed Nov 24 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.34-1
- removed unused imports

* Tue Nov 02 2010 Jan Pazdziora 5.9.33-1
- Update copyright years in the rest of the repo.

* Fri Oct 29 2010 Jan Pazdziora 5.9.32-1
- removed unused class RepoPlainFile (michael.mraka@redhat.com)
- removed unused class RepoAlreadyExists (michael.mraka@redhat.com)
- removed unused class PathNotPresent (michael.mraka@redhat.com)
- removed unused class MalformedRepository (michael.mraka@redhat.com)
- removed unused class FileNotInRepo (michael.mraka@redhat.com)
- after ClientTemplatedDocument removal rhncfg_template.py is empty; removing
  (michael.mraka@redhat.com)
- removed unused class ClientTemplatedDocument (michael.mraka@redhat.com)
- removed unused class BackupFileMissing (michael.mraka@redhat.com)

* Mon Oct 25 2010 Jan Pazdziora 5.9.31-1
- 645795 - making script actions (within rhncfg) work with RHEL 4 by using
  popen2 if subprocess is not available (jsherril@redhat.com)

* Fri Oct 22 2010 Jan Pazdziora 5.9.30-1
- 628920 - Fixed an rhcfg-manager-diff  issue where files were not being
  properly checked (paji@redhat.com)
- startswith(), endswith() are builtin functions since RHEL4
  (michael.mraka@redhat.com)

* Mon Oct 18 2010 Jan Pazdziora 5.9.29-1
- 643157 - fix for the prev commit on RHEL 4 clients the method has to return a
  value... (paji@redhat.com)
- 643157 - Fix to get symlinks work with rhel 4 clients (paji@redhat.com)

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.28-1
- replaced local copy of compile.py with standard compileall module

* Wed Aug 04 2010 Milan Zazrivec <mzazrivec@redhat.com> 5.9.27-1
- 604615 - don't traceback if server does not send selinux_ctx

* Tue Aug 03 2010 Partha Aji <paji@redhat.com> 5.9.26-1
- Made the upload_channel and download_channel calls deal with symlinks
  (paji@redhat.com)

* Mon Aug 02 2010 Partha Aji <paji@redhat.com> 5.9.25-1
- Added diff and get functionaliity for rhncfg-manager (paji@redhat.com)
- Changes to rhncfg verify and diff to get symlinks working (paji@redhat.com)

* Thu Jul 29 2010 Partha Aji <paji@redhat.com> 5.9.24-1
- Made the diff in operation rhncfg client work with symlinks (paji@redhat.com)
- Config Management schema update + ui + symlinks (paji@redhat.com)
- Config Client changes to get symlinks to work (paji@redhat.com)
- code style - whitespace expansion (msuchy@redhat.com)
- code style - expand tabs to space (msuchy@redhat.com)
- let declare that we own directory where rhncfg put backup files
  (msuchy@redhat.com)

* Tue Jul 20 2010 Miroslav Suchý <msuchy@redhat.com> 5.9.23-1
- add parameter cache_only to all client actions (msuchy@redhat.com)

* Wed May 19 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.22-1
- 593563 - fixed debug rutines according to checksum changes

* Tue May 18 2010 Miroslav Suchý <msuchy@redhat.com> 5.9.21-1
- 515637 - add newline at the end so solaris will not strip last line
- 515637 - add newline at the end of file
- Add new rhncfg-client verify --only option to manpage
  (joshua.roys@gtri.gatech.edu)
- 587285 - provide a useful error message when lsetfilecon fails
  (joshua.roys@gtri.gatech.edu)
- Add an 'only' mode of operation to rhncfg-client verify
  (joshua.roys@gtri.gatech.edu)
- Make rhncfg-client verify use lstat (joshua.roys@gtri.gatech.edu)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.20-1
- More support for symlinks in rhncfg tools
- Add selinux output to rhncfg-client verify
- 566664 - handle null SELinux contexts in config uploads

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.18-1
- updated copyrights

* Fri Jan 29 2010 Michael Mraka <michael.mraka@redhat.com> 5.9.17-1
- fixed the sha module is deprecated

* Wed Jan 27 2010 Miroslav Suchy <msuchy@redhat.com> 5.9.16-1
- replaced popen2 with subprocess in client (michael.mraka@redhat.com)

* Thu Jan 14 2010 Tomas Lestach <tlestach@redhat.com> 5.9.15-1
- 552757 - temp file creation changed (tlestach@redhat.com)

* Wed Nov 18 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.14-1
- 491088 - Polish the spec according Fedora Packaging Guidelines

* Tue Nov 17 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.13-1
- 491088 - Polish the spec according Fedora Packaging Guidelines

* Tue Oct 27 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.11-1
- Diff SELinux contexts (joshua.roys@gtri.gatech.edu)

* Wed Sep 02 2009 Michael Mraka <michael.mraka@redhat.com> 5.9.10-1
- Add symlink capability to config management (joshua.roys@gtri.gatech.edu)
- 519195 - fix typos in rhncfg-manager manual page

* Thu Aug 20 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.9-1
- fix an ISE relating to config management w/selinux

* Tue Aug 11 2009 Pradeep Kilambi <pkilambi@redhat.com> 5.9.8-1
- 516889 - adding rhncfgcli_elist module to makefile

* Wed Aug 05 2009 Pradeep Kilambi <pkilambi@redhat.com> 5.9.7-1
- bugfix patch on selinux config file deploy (joshua.roys@gtri.gatech.edu)
- Patch: Selinux Context support for config files (joshua.roys@gtri.gatech.edu)

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 5.9.6-1
- handle orphaned GID's the same way as orphaned UID's (maxim@wzzrd.com)
- update copyright and licenses (jesusr@redhat.com)

* Thu Mar 26 2009 jesus m. rodriguez <jesusr@redhat.com> 5.9.5-1
- 430885 - gracefuly ignore dir diffs instead of treating them as missing files

* Tue Mar 17 2009 Miroslav Suchy <msuchy@redhat.com> 5.9.4-1
- Polish the spec according Fedora Packaging Guidelines

* Wed Feb 18 2009 Pradeep Kilambi <pkilambi@redhat.com> 5.9.3-1
- Applying patch for exclude files for rhncfg get call

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 5.9.2-1
- replace "!#/usr/bin/env python" with "!#/usr/bin/python"

* Thu Jan 22 2009 Michael Mraka <michael.mraka@redhat.com> 5.9.1-1
- resolved #428721 - bumped version

* Thu Jan 15 2009 Pradeep Kilambi <pkilambi@redhat.com> - 0.4.2-1
- BZ#476562 Extended list(elist) option for rhncfg

* Thu Oct 16 2008 Michael Mraka <michael.mraka@redhat.com> 0.3.1-1
- BZ#428721 - fixes filemode and ownership

* Tue Sep  2 2008 Milan Zazrivec 0.2.1-1
- Renamed Makefile to Makefile.rhncfg

* Mon Oct 01 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-2
- BZ#240513: fixes wrong umask issue

* Tue Sep 25 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.1.0-1
- rev build

* Wed Mar 07 2007 Pradeep Kilambi <pkilambi@redhat.com> - 5.0.2-2
- rev build
* Tue Feb 20 2007 James Bowes <jbowes@redhat.com> - 5.0.1-1
- Add dist tag.

* Tue Dec 19 2006 James Bowes <jbowes@redhat.com>
- Drastically reduce memory usage for configfiles.mtime_upload
  (and probably others).

* Thu Jun 23 2005 Nick Hansen <nhansen@redhat.com>: 4.0.0-18
- BZ#154746: make rhncfg-client diff work on solaris boxes
  BZ#160559:  Changed the way repositories are instantiated so 
  that the networking stuff won't get set up if --help is used with a mode.

* Wed Jun 15 2005 Nick Hansen <nhansen@redhat.com>: 4.0-16
- BZ#140501: catch outage mode message and report it nicely. 

* Fri May 20 2005 John Wregglesworth <wregglej@redhat.com>: 4.0-9
- Fixing True/False to work on AS 2.1

* Fri May 13 2005 Nick Hansen <nhansen@redhat.com>: 4.0-8
- BZ#156618: fix client capabilities list that is sent to the server

* Fri Apr 29 2005 Nick Hansen <nhansen@redhat.com>
- adding rhn-actions-control script to actions package

* Fri Jun 04 2004 Bret McMillan <bretm@redhat.com>
- many bug fixes
- removed dependencies on rhns-config-libs

* Mon Jan 20 2004 Todd Warner <taw@redhat.com>
- rhncfg-{client,manager} man pages added

* Mon Nov 24 2003 Mihai Ibanescu <misa@redhat.com>
- Added virtual provides
- Added client capabilities for actions

* Fri Nov 14 2003 Mihai Ibanescu <misa@redhat.com>
- Added default config files

* Fri Sep 12 2003 Mihai Ibanescu <misa@redhat.com>
- Requires rhnlib

* Mon Sep  8 2003 Mihai Ibanescu <misa@redhat.com>
- Initial build
