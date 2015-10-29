%global rhnroot %{_datadir}/rhn
%global rhnconf %{_sysconfdir}/sysconfig/rhn
%global client_caps_dir %{rhnconf}/clientCaps.d

Name: rhncfg
Summary: Spacewalk Configuration Client Libraries
Group:   Applications/System
License: GPLv2
URL:     https://fedorahosted.org/spacewalk
Source0: https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
Version: 5.10.87
Release: 1%{?dist}
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
BuildRequires: docbook-utils
BuildRequires: python
Requires: python
Requires: rhnlib
%if 0%{?rhel} && 0%{?rhel} < 6
Requires: rhn-client-tools >= 0.4.20-86
%else
%if 0%{?el6}
Requires: rhn-client-tools >= 1.0.0-51
%else
# who knows what version we need? Let's just hope it's up to date enough.
Requires: rhn-client-tools
%endif
%endif
%if 0%{?rhel} && 0%{?rhel} <= 5
Requires: python-hashlib
%endif

%if 0%{?suse_version}
# provide rhn directories and no selinux on suse
BuildRequires: rhn-client-tools
%else
Requires: libselinux-python
%endif

%description
The base libraries and functions needed by all rhncfg-* packages.

%package client
Summary: Spacewalk Configuration Client
Group:   Applications/System
Requires: %{name} = %{version}-%{release}

%description client
A command line interface to the client features of the RHN Configuration
Management system.

%package management
Summary: Spacewalk Configuration Management Client
Group:   Applications/System
Requires: %{name} = %{version}-%{release}

%description management
A command line interface used to manage Spacewalk configuration.

%package actions
Summary: Spacewalk Configuration Client Actions
Group:   Applications/System
Requires: %{name} = %{version}-%{release}
Requires: %{name}-client

%description actions
The code required to run configuration actions scheduled via the RHN Classic website or Red Hat Satellite or Spacewalk.

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
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/spool/rhn
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/log
touch $RPM_BUILD_ROOT/%{_localstatedir}/log/rhncfg-actions

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ -f %{_localstatedir}/log/rhncfg-actions ]
then 
chown root %{_localstatedir}/log/rhncfg-actions
chmod 600 %{_localstatedir}/log/rhncfg-actions
fi

%files
%if 0%{?suse_version}
%dir %{_sharedstatedir}
%endif
%dir %{_sharedstatedir}/rhncfg
%dir %{_localstatedir}/spool/rhn
%{rhnroot}/config_common
%{_sharedstatedir}/rhncfg/backups
%doc LICENSE

%files client
%{rhnroot}/config_client
%{_bindir}/rhncfg-client
%attr(644,root,root) %config(noreplace) %{rhnconf}/rhncfg-client.conf
%{_mandir}/man8/rhncfg-client.8*

%files management
%{rhnroot}/config_management
%{_bindir}/rhncfg-manager
%attr(644,root,root) %config(noreplace) %{rhnconf}/rhncfg-manager.conf
%{_mandir}/man8/rhncfg-manager.8*

%files actions
%{rhnroot}/actions
%{_bindir}/rhn-actions-control
%config(noreplace) %{client_caps_dir}/*
%{_mandir}/man8/rhn-actions-control.8*
%ghost %attr(600,root,root) %{_localstatedir}/log/rhncfg-actions

%changelog
* Thu Oct 29 2015 Jan Dobes 5.10.87-1
- 518128 - python 2.4 compatibility

* Thu Oct 29 2015 Jan Dobes 5.10.86-1
- 518128 - remove temporary files when exception occurs

* Tue Aug 25 2015 Tomas Kasparek <tkasparek@redhat.com> 5.10.85-1
- specify that md5 is not used for security purposes

* Fri Jul 10 2015 Matej Kollar <mkollar@redhat.com> 5.10.84-1
- Unused code removal

* Thu Mar 19 2015 Grant Gainey 5.10.83-1
- Updating copyright info for 2015

* Thu Mar 05 2015 Matej Kollar <mkollar@redhat.com> 5.10.82-1
- 1199197 - Avoid addition of None and str

* Mon Jan 19 2015 Matej Kollar <mkollar@redhat.com> 5.10.81-1
- 1177656 - Normalize path sooner

* Tue Jan 13 2015 Matej Kollar <mkollar@redhat.com> 5.10.80-1
- 1177656 - Fix directory creation
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Oct 03 2014 Stephen Herr <sherr@redhat.com> 5.10.79-1
- 1148250 - errror in rhncfg if selinux off, rhel 5, and new libselinux-python

* Tue Sep 16 2014 Stephen Herr <sherr@redhat.com> 5.10.78-1
- 1142337 - rhncfg throws exception when verifying config files with macros

* Thu Sep 11 2014 Stephen Herr <sherr@redhat.com> 5.10.77-1
- 1133652 - make rhncfg support sha256 and use it by default

* Mon Aug 25 2014 Stephen Herr <sherr@redhat.com> 5.10.76-1
- 1133652 - validate the content of config files before deploying

* Thu Jul 31 2014 Stephen Herr <sherr@redhat.com> 5.10.75-1
- Avoid traceback with a configfiles upload action with no selinux context

* Tue Jul 22 2014 Stephen Herr <sherr@redhat.com> 5.10.74-1
- 1120802 - make webui config dir diff work
- bumping rhncfg version to avoid tag collision with 2.2

* Thu Jul 17 2014 Stephen Herr <sherr@redhat.com> 5.10.72-1
- 1120802 - remove debuging output and fix perm comparison from previous patch
- 1120802 - ensure webui config file diff looks at owner and permissions

* Wed Jul 16 2014 Stephen Herr <sherr@redhat.com> 5.10.71-1
- 1113848 - make sure webui doesn't say there are diffs if there aren't
- bz1113848 - Reverting changes of 1003459 and making GUI results compatible to
  rhncfg-client

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 5.10.70-1
- fix copyright years

* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 5.10.69-1
- list / elist: allow to specify list of files

* Thu Apr 24 2014 Stephen Herr <sherr@redhat.com> 5.10.68-1
- 1089729 - fix for assigning all groups user belongs to running process

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 5.10.67-1
- fixes bnc871549 uncaught exception config deploy

* Fri Mar 14 2014 Michael Mraka <michael.mraka@redhat.com> 5.10.66-1
- show server modified time with rhncfg-client diff

* Thu Oct 10 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.65-1
- cleaning up old svn Ids

* Fri Oct 04 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.64-1
- Adding fallback support for numeric UID/GID

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.63-1
- removed trailing whitespaces

* Mon Sep 23 2013 Grant Gainey <ggainey@redhat.com> 5.10.62-1
- 1006480 - Another problem was hidden by the previous one   - Have to lay down
  directories to where the rhncfg-actions logfile is set   - Make it clearer
  that the scripts-output should go to a different place     than where the
  rhncfg code logs itself to

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.61-1
- Grammar error occurred

* Wed Sep 11 2013 Grant Gainey <ggainey@redhat.com> 5.10.60-1
- 1006480 - os.write() is for file-descriptors, not *files*

* Mon Sep 09 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.59-1
- 918036 - update man page for rhncfg-manager

* Thu Sep 05 2013 Milan Zazrivec <mzazrivec@redhat.com> 5.10.58-1
- 1002880 - Selinux status check for diff function from cli

* Wed Sep 04 2013 Stephen Herr <sherr@redhat.com> 5.10.57-1
- 908011 - require correct rhn-client-tools for RHEL 5

* Wed Aug 28 2013 Stephen Herr <sherr@redhat.com> 5.10.56-1
- 1002193 - remove spacewalk-backend-libs dependency from rhncfg

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.55-1
- updating copyright years

* Wed Jun 26 2013 Dimitar Yordanov <dyordano@redhat.com> 5.10.54-1
- 918034 - rhncfg-* --server-name now overwrites rhncfg-*.conf

* Thu Jun 20 2013 Matej Kollar <mkollar@redhat.com> 5.10.53-1
- Fix and simplyfy deci_to_octal conversion

* Wed Jun 19 2013 Jan Dobes 5.10.52-1
- 957506 - unicode support for Remote Command scripts

* Tue Jun 18 2013 Dimitar Yordanov <dyordano@redhat.com> 5.10.51-1
- 918036 - RFE - rhncfg-manager supports --username and --password from CLI

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.50-1
- branding fixes in man pages
- more branding cleanup

* Mon Jun 17 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.49-1
- rebranding few more strings in client stuff

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.48-1
- rebranding RHN Satellite to Red Hat Satellite in client stuff

* Tue May 21 2013 Tomas Kasparek <tkasparek@redhat.com> 5.10.47-1
- branding clean-up of client tools

* Fri Apr 12 2013 Grant Gainey 5.10.46-1
- 951243 - Let remote-cmds log to the local machine in addition to sending
  results back to SW

* Tue Apr 09 2013 Stephen Herr <sherr@redhat.com> 5.10.45-1
- 947639 - make rhncfg less stupid

* Thu Apr 04 2013 Stephen Herr <sherr@redhat.com> 5.10.44-1
- 948605 - make diffs initiated from Satellite obey display_diff config option
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Tue Feb 12 2013 Michael Mraka <michael.mraka@redhat.com> 5.10.43-1
- cleanup old accidentaly commited eclipse project files

* Wed Feb 06 2013 Stephen Herr <sherr@redhat.com> 5.10.42-1
- 908011 - make rhncfg depend on correct version of rhn-client-tools for RHEL
- 908011 - make rhncfg depend on newer rhn-client-tools

* Mon Feb 04 2013 Jan Pazdziora 5.10.41-1
- 856608 - moved rhncfg dependency on spacewalk-backend-libs to base package
  All sub-packages now require it

* Mon Jan 28 2013 Stephen Herr <sherr@redhat.com> 5.10.40-1
- 903534 - Web UI config diff always shows 'binary files differ'

* Fri Nov 30 2012 Jan Pazdziora 5.10.39-1
- 879299 - statinfo needs to be defined even if file does not exist

* Tue Nov 20 2012 Stephen Herr <sherr@redhat.com> 5.10.38-1
- 878216 - fixing typo in manpage

* Tue Nov 20 2012 Stephen Herr <sherr@redhat.com> 5.10.37-1
- 878216 - make rhncfg diff output configurable

* Tue Oct 30 2012 Jan Pazdziora 5.10.36-1
- Update the copyright year.
- fix for bz#869626 use st_mode, st_uid of dst Signed-off-by: Paresh Mutha
  <pmutha@redhat.com>

* Mon Oct 22 2012 Jan Pazdziora 5.10.35-1
- Revert "Revert "Revert "get_server_capability() is defined twice in osad and
  rhncfg, merge and move to rhnlib and make it member of rpclib.Server"""

* Tue Aug 07 2012 Tomas Kasparek <tkasparek@redhat.com> 5.10.34-1
- 840250 - If there's symlink in file deployment path it will be created

* Mon Jul 09 2012 Michael Mraka <michael.mraka@redhat.com> 5.10.33-1
- check symlink not target file existence

* Thu Jun 28 2012 Michael Mraka <michael.mraka@redhat.com> 5.10.32-1
- 765816 - value of selinux context is important

* Mon Jun 04 2012 Stephen Herr <sherr@redhat.com> 5.10.31-1
- 824707 - make /var/log/rhncfg-actions have 600 permissions

* Fri Jun 01 2012 Stephen Herr <sherr@redhat.com> 5.10.30-1
- 824707 - rhncfg-actions should not log the diff of files that are not
  readable by all
- %%defattr is not needed since rpm 4.4

* Mon May 14 2012 Michael Mraka <michael.mraka@redhat.com> 5.10.29-1
- 820517 - fixed command synopsis
- 805449 - honor rhncfg-specific settings

* Thu Mar 08 2012 Miroslav Suchý 5.10.28-1
- accept server name without protocol

* Fri Mar 02 2012 Jan Pazdziora 5.10.27-1
- Update the copyright year info.

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 5.10.26-1
- we are now just GPL

* Sun Jan 15 2012 Aron Parsons <aronparsons@gmail.com> 5.10.25-1
- add a --disable-selinux option to 'rhncfg-manager upload-channel'
  (aronparsons@gmail.com)

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.10.24-1
- update copyright info

* Wed Dec 14 2011 Jan Pazdziora 5.10.23-1
- Fixing SyntaxError: ('invalid syntax', ...

* Tue Dec 13 2011 Miroslav Suchý 5.10.22-1
- 765816 - Added the option --selinux-context to rhncfg-manager which allows to
  overwrite the SELinux context from a file (mmello@redhat.com)

* Wed Nov 30 2011 Miroslav Suchý 5.10.21-1
- handle fs objects without selinux context correctly

* Mon Nov 21 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.20-1
- 627490 - fixed cross device symlink backup

* Mon Oct 24 2011 Jan Pazdziora 5.10.19-1
- 743121 - don't report differences containing invalid UTF-8
  (mzazrivec@redhat.com)

* Wed Oct 19 2011 Milan Zazrivec <mzazrivec@redhat.com> 5.10.18-1
- 743424 - rhncfg-client diff: do not fail when not a valid symlink

* Mon Oct 10 2011 Jan Pazdziora 5.10.17-1
- 743424 - rhncfg-client diff: don't traceback on missing symlink
  (mzazrivec@redhat.com)

* Thu Sep 29 2011 Miroslav Suchý 5.10.16-1
- add save_traceback even into this branch

* Fri Sep 23 2011 Martin Minar <mminar@redhat.com> 5.10.15-1
- Fix `rhncfg-client verify' traceback for missing symlinks
  (Joshua.Roys@gtri.gatech.edu)

* Thu Aug 18 2011 Michael Mraka <michael.mraka@redhat.com> 5.10.14-1
- 731284 - is_selinux_enabled is not defined on RHEL4

* Fri Aug 12 2011 Miroslav Suchý 5.10.13-1
- add proto, server_name and server_list to local_config overrides
- None has not iteritems() method

* Thu Aug 11 2011 Miroslav Suchý 5.10.12-1
- True and False constants are defined since python 2.4
- do not mask original error by raise in execption

* Thu Aug 04 2011 Jan Pazdziora 5.10.11-1
- 508936 - rhn-actions-control honor the allowed-actions/scripts/run for remote
  commands (mmello@redhat.com)

* Mon Aug 01 2011 Miroslav Suchý 5.10.10-1
- get server_name from config only if it was not set on command line
- remove rhn_rpc.py

* Fri Jul 15 2011 Miroslav Suchý 5.10.9-1
- optparse is here since python 2.3 - remove optik (msuchy@redhat.com)

* Thu Jun 16 2011 Jan Pazdziora 5.10.8-1
- Creating the /var/spool/rhn in %build.

* Thu Jun 16 2011 Jan Pazdziora 5.10.7-1
- temp script file customizable dedicated directory (matteo.sessa@dbmsrl.com)

* Tue May 31 2011 Jan Pazdziora 5.10.6-1
- Fix python import (matteo.sessa@dbmsrl.com)

* Tue May 10 2011 Jan Pazdziora 5.10.5-1
- remove unused import, fix indentation and a minor typo (iartarisi@suse.cz)
- fix usage documentation messages for topdir and dest-file (iartarisi@suse.cz)

* Fri May 06 2011 Jan Pazdziora 5.10.4-1
- 702524 - Fixed python traceback when deploying a file with permission set to
  000 (mmello@redhat.com)

* Fri Apr 29 2011 Jan Pazdziora 5.10.3-1
- 699966 - added --ignore-missing option in rhncfg-manager to ignore missing
  local files when adding or uploading files (mmello@redhat.com)

* Fri Apr 15 2011 Jan Pazdziora 5.10.2-1
- add missing directories to filelist (mc@suse.de)
- build rhncfg build on SUSE (mc@suse.de)
- 683200 - ca is now unicode, check for basestring, which is parent for both
  str and unicode type (msuchy@redhat.com)
- 683200 - set the protocol correctly (msuchy@redhat.com)
- 683200 - server_name and server_list should contain just hostname, not url
  (msuchy@redhat.com)
- 683200 - if value is int ConfigParser fails with interpolation
  (msuchy@redhat.com)
- 683200 - variable %proto is not used in up2date_cfg (msuchy@redhat.com)
- removing .rhncfgrc - it is not packed, probably forgotten for long time
  (msuchy@redhat.com)
- add () if you want to get result of function (msuchy@redhat.com)

* Wed Apr 13 2011 Miroslav Suchý 5.10.1-1
- bump up version (msuchy@redhat.com)

* Wed Apr 13 2011 Miroslav Suchý 5.9.55-1
- code cleanup
* Wed Apr 13 2011 Miroslav Suchý 5.9.54-1
- dead code - module up2date_config_parser is not used any more
- dead code - get_up2date_config() is not used any more
- 695723, 683200 - use up2date_client.config instead of own parser
  (utils.get_up2date_config)

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

