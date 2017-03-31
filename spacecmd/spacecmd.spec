%if ! (0%{?fedora} || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

%if 0%{?fedora}
%{!?pylint_check: %global pylint_check 1}
%endif

Name:        spacecmd
Version:     2.7.8
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Red Hat Satellite servers

Group:       Applications/System
License:     GPLv3+
URL:         https://github.com/spacewalkproject/spacewalk/wiki/spacecmd
Source:      https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildRoot:   %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:   noarch

%if 0%{?pylint_check}
BuildRequires: spacewalk-pylint
%endif
BuildRequires: python
BuildRequires: python-devel
BuildRequires: python-simplejson
BuildRequires: rpm-python
%if 0%{?rhel} == 5
BuildRequires: python-json
%endif

%if 0%{?rhel} == 5
Requires:    python-simplejson
%endif
Requires:    python
Requires:    file

%if 0%{?suse_version}
BuildRequires: python-xml
Requires:      python-xml
Requires:      python-simplejson
%endif

%description
spacecmd is a command-line interface to Spacewalk and Red Hat Satellite servers

%prep
%setup -q

%build
# nothing to build

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}
%{__install} -p -m0755 src/bin/spacecmd %{buildroot}/%{_bindir}/

%{__mkdir_p} %{buildroot}/%{_sysconfdir}
touch %{buildroot}/%{_sysconfdir}/spacecmd.conf

%{__mkdir_p} %{buildroot}/%{_sysconfdir}/bash_completion.d
%{__install} -p -m0644 src/misc/spacecmd-bash-completion %{buildroot}/%{_sysconfdir}/bash_completion.d/spacecmd

%{__mkdir_p} %{buildroot}/%{python_sitelib}/spacecmd
%{__install} -p -m0644 src/lib/*.py %{buildroot}/%{python_sitelib}/spacecmd/

%{__mkdir_p} %{buildroot}/%{_mandir}/man1
%{__gzip} -c src/doc/spacecmd.1 > %{buildroot}/%{_mandir}/man1/spacecmd.1.gz

touch %{buildroot}/%{python_sitelib}/spacecmd/__init__.py
%{__chmod} 0644 %{buildroot}/%{python_sitelib}/spacecmd/__init__.py

%clean
%{__rm} -rf %{buildroot}

%check
%if 0%{?pylint_check}
PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib} \
	spacewalk-pylint $RPM_BUILD_ROOT%{python_sitelib}/spacecmd
%endif

%files
%defattr(-,root,root)
%{_bindir}/spacecmd
%{python_sitelib}/spacecmd/
%ghost %config %{_sysconfdir}/spacecmd.conf
%dir %{_sysconfdir}/bash_completion.d
%{_sysconfdir}/bash_completion.d/spacecmd
%doc src/doc/README src/doc/COPYING
%doc %{_mandir}/man1/spacecmd.1.gz

%changelog
* Mon Mar 27 2017 Gennadii Altukhov <galt@redhat.com> 2.7.8-1
- 1428862 - fix syntax error added by e21ab42fd175da7b32949acbbf360c335f3f3745

* Fri Mar 24 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.7-1
- 1428862 - make sure to know if we get into default function and exit
  accordingly

* Fri Mar 03 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.6-1
- 1202684 - exit with 1 with incorrect command, wrong server, etc.
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub
- 1189291 - call enumerate instead of list
- 1399151 - print also systemdid with system name
- 1427888 - return list of strings only

* Thu Mar 02 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.5-1
- 1428384 - print profile_name instead of string we're searching for
- 1427905 - there may be a system with name equal to systemid
- 1427938 - expect name as string

* Fri Feb 24 2017 Jan Dobes 2.7.4-1
- Fix interactive mode
- Add a type parameter to repo_create

* Tue Dec 20 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.3-1
- fixing pylint: spacecmd: consider-iterating-dictionary

* Thu Dec 15 2016 Jiri Dostal <jdostal@redhat.com> 2.7.2-1
- 1404276 - spacecmd has hardcoded architectures - there is solaris

* Tue Dec 06 2016 Jiri Dostal <jdostal@redhat.com> 2.7.1-1
- 1250572 - Text description missing for remote command by Spacecmd
- Bumping package versions for 2.7.

* Wed Oct 12 2016 Grant Gainey 2.6.16-1
- Update Satellite to Red Hat Satellite (trademark)

* Wed Sep 28 2016 Eric Herget <eherget@redhat.com> 2.6.15-1
- 1368397 - spacecmd should generate caches for the server+user combination

* Thu Sep 22 2016 Jiri Dostal <jdostal@redhat.com> 2.6.14-1
- spacecmd: catch all exceptions in do_login()
- Revert presious commit - spacewalk-pylint does not accept exception without
  type
- spacecmd: catch all exceptions in do_login()

* Thu Sep 15 2016 Jan Dobes 2.6.13-1
- fixing pylint: wrong-import-order

* Thu Sep 15 2016 Jan Dobes 2.6.12-1
- fixing pylint: too-many-nested-blocks
- fixing pylint: wrong-import-order
- building of spacecmd package fails in i686 buildroot because of this

* Thu Sep 08 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.11-1
- Revert "1251949 - spacecmd: Repaired compiling regexps to avoid error:
  multiple repeat"

* Tue Sep 06 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.10-1
- 1251949 - spacecmd: Repaired compiling regexps to avoid error: multiple
  repeat

* Wed Aug 31 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.9-1
- 1209646 - spacecmd: Added systemID to report_inactivesystems output
- 1367562 - spacecmd: Added output to logging.debug from softwarechannel_sync
  func
- 1179333 - spacecmd: Modified IF statement in due to fails according BZ

* Wed Aug 31 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.8-1
- Added seconds to HELP_TIME_OPTS

* Tue Aug 30 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.7-1
- Fix summary displayed when applying multiple errata

* Mon Aug 22 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.6-1
- Add start time to system_applyerrata
- Accept -s option in errata_apply
- Add start time to errata_apply
- spacecmd: Add system_reboot examples to man page
- spacecmd: Skip time prompt when running with --yes
- spacecmd: Add start time to system_schedulepackagerefresh
- spacecmd: Add start time to system_schedulehardwarerefresh
- spacecmd: Add start time to system_syncpackages
- spacecmd: Add start time to system_deployconfigfiles
- spacecmd: Add start time to system_upgradepackage
- spacecmd: Add start time to system_removepackage
- spacecmd: Add start time to system_installpackage
- spacecmd: Add start time to system_reboot

* Thu Aug 18 2016 Ondrej Gajdusek <ogajduse@redhat.com> 2.6.5-1
- Repaired package listing.
- Added seconds to timeparse func.

* Tue Aug 09 2016 Tomas Lestach <tlestach@redhat.com> 2.6.4-1
- addressing pylint issues

* Tue Aug 09 2016 Tomas Lestach <tlestach@redhat.com> 2.6.3-1
- 1309710 - Adding kickstart_setsoftwaredetails feature.
- Fixing kickstart_getsoftware autocompletion.

* Thu Jul 21 2016 Tomas Lestach <tlestach@redhat.com> 2.6.2-1
- spacecmd: Check number of arguments in system_show_packageversion
- Fix help/usage messages
- spacecmd: user: allow more than one group at a time

* Mon Jun 27 2016 Tomas Lestach <tlestach@redhat.com> 2.6.1-1
- simplyfication of comparison
- simplify if statements
- replacing 'expr == None' with 'expr is None'
- fix import order in spacecmd
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.8-1
- updating copyright years

* Tue May 10 2016 Grant Gainey 2.5.7-1
- spacecmd: build on openSUSE
- 1274484 - changed name of key in ConfigRevision structure + updated API doc +
  configchannel.py

* Thu Mar 24 2016 Jan Dobes 2.5.6-1
- 1277994 - Add option to softwarechannel_setorgaccess for protected sharing of
  channels.

* Tue Feb 02 2016 Grant Gainey 2.5.5-1
- unused variable
- mimetype detection to set the binary flag requires 'file' tool
- fix export/cloning: always base64
- default is binary
- Always base64 encode to avoid trim() bugs in the XML-RPC library.

* Tue Feb 02 2016 Jiri Dostal <jdostal@redhat.com> 2.5.4-1
- 1250572 fix pylint

* Tue Feb 02 2016 Jiri Dostal <jdostal@redhat.com> 2.5.3-1
- 1250572 - Text description missing for remote command by Spacecmd

* Tue Jan 19 2016 Gennadii Altukhov <galt@redhat.com> 2.5.2-1
- 1287246 - spacecmd: repo_details show 'None' if repository doesn't have SSL
  Certtificate
- 1287246 - spacecmd: Added functions to add/edit SSL certificates for
  repositories

* Tue Nov 24 2015 Jan Dobes 2.5.1-1
- spacecmd: remove listsystementitlements command
- spacecmd: remove virtualization host platform entitlement references
- spacecmd: remove references to provisioning entitlements
- spacecmd: remove entitlements example from documentation
- spacecmd: remove softwarechannel_getentitlements
- spacecmd: remove report_entitlements; uses removed API
- spacecmd: not use dropped satellite.listEntitlements api
- spacecmd: remove org_listsoftwareentitlements and org_setsoftwareentitlements
- Bumping package versions for 2.5.

* Fri Sep 18 2015 Jan Dobes 2.4.11-1
- Removed monitoring stuff from the spacecmd

* Sun Aug 30 2015 Jan Dobes <jdobes@redhat.com> 2.4.10-1
- Added softwarechannel_listsyncschedule to spacecmd to list all active
  software channel sync schedules.

* Wed Aug 19 2015 Jan Dobes 2.4.9-1
- 1229427 - use default value as in WebUI
- 1229427 - do not forget checksum
- 1229427 - offer more checksum types

* Mon Aug 10 2015 Jan Dobes 2.4.8-1
- softwarechannel_listlatestpackages help message

* Fri Aug 07 2015 Jan Dobes 2.4.7-1
- check for existence of device description in spacecmd system_listhardware
  (bsc#932288)

* Fri Aug 07 2015 Jan Dobes 2.4.6-1
- use hostname instead of localhost for https connections

* Mon Aug 03 2015 Tomas Lestach <tlestach@redhat.com> 2.4.5-1
- 1244099 - fix spacecmd do_configchannel_sync for directories
- Fix typo in softwarechannel.py

* Wed Jul 29 2015 Aron Parsons <aronparsons@gmail.com> 2.4.4-1
- spacecmd: add missing CHECKSUM list

* Wed May 13 2015 Stephen Herr <sherr@redhat.com> 2.4.3-1
- See pull request 247, always base64 encode config files to prevent whitespace
  stripping

* Mon May 11 2015 Tomas Lestach <tlestach@redhat.com> 2.4.2-1
- do not escape spacecmd command arguments

* Thu Apr 02 2015 Tomas Lestach <tlestach@redhat.com> 2.4.1-1
- 1207606 - do not return one package multiple times
- Bumping package versions for 2.4.

* Mon Mar 23 2015 Grant Gainey 2.3.20-1
- Standardize pylint-check to only happen on Fedora

* Thu Mar 19 2015 Grant Gainey 2.3.19-1
- Updating copyright info for 2015
- Added a bit more documentation to softwarechannel_setsyncschedule to make it
  more obvious what the schedule format is.

* Fri Mar 13 2015 Tomas Lestach <tlestach@redhat.com> 2.3.18-1
- Added softwarechannel_removesyncschedule to remove a sync schedule from a
  channel.
- Fix cli config option nossl. Before using it triggered the following error:

* Tue Feb 24 2015 Grant Gainey 2.3.17-1
- Make pylint happy

* Thu Feb 19 2015 Grant Gainey 2.3.16-1
- Fixed typo
- add ability to specify gpg bits from spacecmd when creating software channels

* Thu Feb 19 2015 Matej Kollar <mkollar@redhat.com> 2.3.15-1
- 1191418 - sanitize data from export

* Wed Jan 28 2015 Matej Kollar <mkollar@redhat.com> 2.3.14-1
- Setting ts=4 is wrong

* Mon Jan 26 2015 Matej Kollar <mkollar@redhat.com> 2.3.13-1
- Forgotten substitution?
- Fix Pylint on Fedora 21: manual fixes
- Fix Pylint on Fedora 21: autopep8
- 1180233 - More corner cases for errata summary printing
- Let pep8 do its thing to clean up some code
- spacecmd: added softwarechannel_errata functions
- spacecmd: cleanup string handling
- spacecmd: add defattr

* Wed Jan 21 2015 Matej Kollar <mkollar@redhat.com> 2.3.12-1
- Pylint fix for Fedora 21

* Fri Jan 16 2015 Grant Gainey 2.3.11-1
- fix configchannel export - do not create 'contents' key for directories

* Fri Jan 16 2015 Grant Gainey 2.3.10-1
- First custom_opts has no 'arguments' - protect against it
- fix call of setCustomOptions()

* Fri Jan 16 2015 Grant Gainey 2.3.9-1
- Fix spacecmd schedule listing for negative deltas

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.8-1
- spacecmd: fix listupgrades

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.7-1
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Fri Dec 05 2014 Stephen Herr <sherr@redhat.com> 2.3.6-1
- Consider all kickstartable tree channels when listing distributions

* Fri Nov 28 2014 Tomas Lestach <tlestach@redhat.com> 2.3.5-1
- address pylint complains

* Fri Nov 28 2014 Tomas Lestach <tlestach@redhat.com> 2.3.4-1
- add new function kickstart_getsoftwaredetails
- Added feature to get installed packageversion of a system or systems managed
  by ssm to spacecmd. Usage: spacecmd system_show_packageversion <SYSTEM>
  <PACKAGE>

* Mon Nov 03 2014 Grant Gainey 2.3.3-1
- 1111680 - Teach spacecmd report_errata to process all-errata in the absence
  of further args

* Mon Nov 03 2014 Miroslav Suchý <msuchy@redhat.com> 2.3.2-1
- add BR: python

* Sun Sep 28 2014 Aron Parsons <aronparsons@gmail.com> 2.3.1-1
- spacecmd: fix -p argument in distribution_update help

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.11-1
- fix copyright years

* Tue Jun 24 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.10-1
- 1083519 - make spacecmd funtion correctly in multi-nevra environments
- make print_result a static method of SpacewalkShell

* Fri Jun 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.9-1
- allow bare-except (W0702) in the outer block as well

* Fri Jun 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.8-1
- spacecmd: new build requires needed by pylint checking
- pylint fixes: comma and operator to be followed / preceded by space

* Fri Jun 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- system: don't use python built-ins for identifiers
- set PYTHONPATH for pylint

* Thu Jun 05 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.6-1
- add spacewalk-pylint checks to spacecmd build
- pylint fixes
* Thu May 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.5-1
- added option for downloading only latest package version with
  softwarechannel_mirrorpackages
- improofed error handling of softwarechannel_mirrorpackages
- Added option to spacecmd for force a deployment of a config channel to all
  subscribed systems

* Mon May 26 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.4-1
- added last boot message in system_details func.

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.3-1
- Added option to mirror a softwarechannel with spacecmd

* Fri Apr 04 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.2-1
- 893368 - set output encoding when stdout is not a tty

* Fri Feb 28 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.1-1
- 1066109 - add script name argument when calling kickstart.profile.addScript()
- fix string expansion
- adjusted the output of package_listdependencies

* Fri Feb 21 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.25-1
- 1060746 - make file_needs_b64_enc work for both str and unicode inputs

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.24-1
- Automatic commit of package [spacecmd] release [2.1.23-1].

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.23-1
- Updating the copyright years info

* Mon Jan 06 2014 Tomas Lestach <tlestach@redhat.com> 2.1.22-1
- 1048090 - fix spacecmd, so it does not expect package id within the
  system.listPackages API call

* Fri Dec 20 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.21-1
- 1014765 - fix binary file detection
- added function package_listdependencies

* Fri Dec 13 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.20-1
- 1009841 - don't attempt to write out 'None'

* Fri Dec 13 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.19-1
- 960984 - fix system listing when identified by system id

* Thu Dec 05 2013 Aron Parsons <aronparsons@gmail.com> 2.1.18-1
- spacecmd: print repos in softwarechannel_getdetails
- spacecmd: add softwarechannel_listrepos
- spacecmd: add softwarechannel_removerepo
- spacecmd: add softwarechannel_addrepo
- spacecmd: fix tab completion for repo_addfilters

* Thu Dec 05 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.17-1
- package search: make sure the lucene search syntax works

* Sun Dec 01 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.16-1
- 835979 - don't double convert start time 'now'

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.15-1
- Making code more "pythonic"

* Thu Nov 21 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.14-1
- system_deletecrashes, system_getcrashfiles, system_listcrashesbysystem

* Fri Nov 08 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.13-1
- 835979 - system_runscript: convert date/time to iso-8601

* Mon Oct 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.12-1
- fix typo in a comment

* Wed Oct 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.11-1
- spacecmd: Fix session validation

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.10-1
- removed trailing whitespaces

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.9-1
- Fix typo, the decoded output need to be printed...

* Mon Sep 23 2013 Aron Parsons <aronparsons@gmail.com> 2.1.8-1
- spacecmd: use a non-privileged API call to check session validity
- spacecmd: handle base64-encoded output in schedule_getoutput
- spacecmd: add softwarechannel_setsyncschedule function
- spacecmd: make globbing optional in parse_arguments()

* Mon Sep 02 2013 Aron Parsons <aronparsons@gmail.com> 2.1.7-1
- spacecmd: try to use a cached session even if the username is passed on the
  command line
- spacecmd: added function activationkey_setdescription
- spacecmd: fix invalid call to user_confirm in
  activationkey_setconfigchannelorder

* Sun Aug 25 2013 Aron Parsons <aronparsons@gmail.com> 2.1.6-1
- spacecmd: remove duplicate packages in system_listupgrades output
- spacecmd: make the keys used in latest_pkg() configurable

* Wed Aug 21 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.5-1
- Add new function system_listcrashedsystems

* Tue Aug 13 2013 Gregor Gruener <ggruner@redhat.com> 2.1.4-1
- add new function kickstart_getupdatetype
- add new function kickstart_setupdatetype

* Tue Aug 06 2013 Gregor Gruener <ggruner@redhat.com> 2.1.3-1
- add new function scap_listxccdfscans
- add new function scap_getxccdfscandetails
- add new function scap_getxccdfscanruleresults
- add new function scap_schedulexccdfscan

* Mon Aug 05 2013 Gregor Gruener <ggruner@redhat.com> 2.1.2-1
- add new function is_monitoringenabled
- add new function list_proxies

* Mon Jul 22 2013 Gregor Gruener <ggruner@redhat.com> 2.1.1-1
- add new function custominfo_updatekey

* Thu Jul 18 2013 Miroslav Suchý <msuchy@redhat.com> 2.0.2-1
- 985530 - require python and python-simplejson

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Thu Jul 11 2013 Stephen Herr <sherr@redhat.com> 1.10.6-1
- 983400 - fixing spacecmd ssm 'list' has no attribute 'keys' error

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.5-1
- rebrading RHN Satellite to Red Hat Satellite

* Sun Apr 28 2013 Aron Parsons <aronparsons@gmail.com> 1.10.4-1
- 947829 - spacecmd errors out when trying to add script to kickstart

* Fri Apr 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.3-1
- provide support for user.setDetails()

* Tue Apr 16 2013 Stephen Herr <sherr@redhat.com> 1.10.2-1
- Make spacecmd able to specify config channel label

* Wed Mar 13 2013 Aron Parsons <aronparsons@gmail.com> 1.10.1-1
- fix directory export in configchannel_export
- use 755 as default permissions for directories in
  configfile_getinfo
- fix directory creation in configchannel_addfile

* Sun Mar 03 2013 Aron Parsons <aronparsons@gmail.com> 1.9.4-1
- spacecmd: allow globbing in activationkey_{en,dis}able
- spacecmd: add functions to disable/enable activation keys

* Sun Mar 03 2013 Aron Parsons <aronparsons@gmail.com> 1.9.3-1
- update email addresses in copyright notices
- update copyright years
- add new function softwarechannel_syncrepos
- add new function repo_updateurl
- add new function repo_rename
- add new function repo_create
- add new function repo_delete
- remove some commented out code
- print the list of systems in system_runscript
- print the list of systems in system_reboot
- return a unique set from expand_systems
- print a clearer error message when duplicate system names are found
- standardize the behavior for when a system ID is not returned
- add a delay before regenerating the system cache after a delete
- handle binary files correctly in configfile_getinfo
- print the name in the confirmation message of snippet_create
- don't exit when invalid arguments are passed to a function
- don't reuse variable names in parse_arguments
- print the function's help message when -h in the argument list
- print file path in package_details

* Thu Feb 28 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.2-1
- fixing broken export of configchannels with symlinks

* Mon Feb 18 2013 Tomas Lestach <tlestach@redhat.com> 1.9.1-1
- sort export_kickstart_getdetails right after fetching
- Bumping package versions for 1.9.

* Sat Sep 29 2012 Aron Parsons <aronparsons@gmail.com> 1.8.15-1
- spacecmd: add functions to manage repo filters

* Wed Aug 29 2012 Aron Parsons <aronparsons@gmail.com> 1.8.14-1
- spacecmd: prevent outputting escape sequences to non-terminals

* Sun Aug 12 2012 Aron Parsons <aronparsons@gmail.com> 1.8.13-1
- spacecmd: add system_schedule{hardware,package}refresh functions Signed-off-
  by: Aron Parsons <aronparsons@gmail.com>

* Fri Aug 10 2012 Jan Pazdziora 1.8.12-1
- Fixed small typo in spacecmd/src/lib/kickstart.py

* Mon Jul 09 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.11-1
- spacecmd : Fix kickstart_export with old API versions

* Fri Jun 22 2012 Jan Pazdziora 1.8.10-1
- spacecmd : enhancement add configchannel_sync
- spacecmd : enhancement add softwarechannel_sync

* Thu May 31 2012 Stephen Herr <sherr@redhat.com> 1.8.9-1
- 809905 - fixing chroot option for addscript, is now possible to not chroot in
  non-interactive mode

* Thu May 24 2012 Steven Hardy <shardy@redhat.com> 1.8.8-1
- spacecmd bugfix : kickstart_getcontents fix character encoding error
- spacecmd bugfix: activationkey_import don't add empty package/group lists
- spacecmd bugfix : fix activationkey_import when no base-channel specified
- spacecmd bugfix : Fix reference to non-existent variable
- spacecmd bugfix : improve configchannel_export operation on old API versions
- spacecmd bugfix : *diff functions allow python 2.4 compatibility

* Tue May 15 2012 Aron Parsons <aronparsons@gmail.com> 1.8.7-1
- changed get_string_diff_dicts to better fitting replacement method
- bugfix and comment clarification
- bugfix: remove reference to stage function
- add do_SPACEWALKCOMPONENT_diff functions
- print return values

* Tue May 15 2012 Steven Hardy <shardy@redhat.com> 1.8.6-1
- spacecmd bugfix : system_comparewithchannel filter system packagelist
- spacecmd bugfix : argument validation needed for configchannel_addfile
- spacecmd bugfix : configchannel_addfile don't display b64 file contents

* Fri Apr 27 2012 Steven Hardy <shardy@redhat.com> 1.8.5-1
- spacecmd : enhancement add system_addconfigfile (shardy@redhat.com)
- spacecmd : move file_needs_b64_enc into utils (shardy@redhat.com)
- spacecmd : Fix usage for configchannel_addfile (shardy@redhat.com)
- spacecmd : enhancement Add system_listconfigfiles (shardy@redhat.com)

* Sat Apr 14 2012 Aron Parsons <aronparsons@gmail.com> 1.8.4-1
- spacecmd: pretty-print JSON output
- spacecmd: cosmetics

* Thu Apr 05 2012 Stephen Herr <sherr@redhat.com> 1.8.3-1
- 809905 - add option to allow templating for spacecmd kickstarting
  (sherr@redhat.com)

* Thu Mar 29 2012 Steven Hardy <shardy@redhat.com> 1.8.2-1
- spacecmd : softwarechannel_clone avoid ISE on duplicate name
  (shardy@redhat.com)
- spacecmd bugfix : softwarechannel_adderrata mergeErrata should be
  cloneErrataAsOriginal (shardy@redhat.com)
- spacecmd enhancement : Add globbing support to distribution_details
  (shardy@redhat.com)
- spacecmd enhancement : Add globbing support to distribution_delete
  (shardy@redhat.com)
- spacecmd : Cleanup some typos in comments (shardy@redhat.com)
- spacecmd enhancement : custominfo_details add support for globbing key names
  (shardy@redhat.com)
- spacecmd enhancement : custominfo_deletekey add support for globbing key
  names (shardy@redhat.com)
- spacecmd enhancement : Add cryptokey_details globbing support
  (shardy@redhat.com)
- spacecmd enhancement : cryptokey_delete add support for globbing
  (shardy@redhat.com)
- spacecmd : Workaround missing date key in recent spacewalk listErrata
  (shardy@redhat.com)
- spacecmd : Add validation to softwarechannel_adderrata channel args
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_adderrata add --skip mode
  (shardy@redhat.com)
- spacecmd enhancement : Add --quick mode to softwarechannel_adderrata
  (shardy@redhat.com)
- spacecmd enhancement : Allow config-channel export of b64 encoded files
  (shardy@redhat.com)

* Mon Mar 12 2012 Jan Pazdziora 1.8.1-1
- Update the spacecmd copyright years for Red Hat contributions.

* Mon Feb 27 2012 Steven Hardy <shardy@redhat.com> 1.7.7-1
- spacecmd : activationkey_details print child channels and packages sorted
  (joerg.steffens@dass-it.de)
- spacecmd bugfix : softwarechannel_adderrata use cloneAsOriginal
  (shardy@redhat.com)
- spacecmd enhancement : Add errata_findbycve function (shardy@redhat.com)
- spacecmd enhancement : configchannel_delete add support for globbing
  (shardy@redhat.com)
- spacecmd : Fix error in do_activationkey_export comment (shardy@redhat.com)
- spacecmd enhancement : activationkey_delete add support for globbing
  (shardy@redhat.com)
- spacecmd bugfix : softwarechannel_addpackages validate channel arg
  (shardy@redhat.com)

* Mon Feb 27 2012 Jan Pazdziora 1.7.6-1
- 769430 - avoid using the quoted string, parse it first.

* Sun Feb 19 2012 Steven Hardy <shardy@redhat.com> 1.7.5-1
- spacecmd bugfix : bz766887 - user_create fix broken --pam option
  (shardy@redhat.com)
- spacecmd bugfix: recover when partial cache files occur (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_adderratabydate add publish option
  (shardy@redhat.com)
- spacecmd : Add usage help on date format for softwarechannel_adderratabydate
  (shardy@redhat.com)
- spacecmd enhancement : Add softwarechanel_listerratabydate command
  (shardy@redhat.com)
- spacecmd : Add warning to kickstart_import if JSON filename is passed
  (shardy@redhat.com)
- spacecmd enhancement: Add kickstart_importjson (shardy@redhat.com)
- spacecmd enhancement: Add kickstart_export command (shardy@redhat.com)
- spacecmd enhancement: Add system_comparewithchannel command
  (shardy@redhat.com)
- spacecmd bugfix: Don't display password in debug mode (shardy@redhat.com)

* Tue Feb 14 2012 Aron Parsons <aronparsons@gmail.com> 1.7.4-1
- spacecmd: handle server connection failures more gracefully
  (aronparsons@gmail.com)

* Mon Jan 23 2012 Aron Parsons <aronparsons@gmail.com> 1.7.3-1
- spacecmd bugfix: configchannel_addfile fail nicely when no channel arg
  (shardy@redhat.com)
- spacecmd enhancement: Align configchannel_addfile usage (shardy@redhat.com)
- spacecmd enhancement: Add softwarechannel_listlatestpackages command
  (shardy@redhat.com)
- spacecmd bugfix: configchannel_import detect trailing newlines
  (shardy@redhat.com)
- spacecmd bugfix: configchannel_import flag error when binary file can't be
  imported (shardy@redhat.com)
- spacecmd bugfix: system_runscript fix type when passing timeout argument
  (shardy@redhat.com)
- spacecmd enhancement : configchannel_addfile automatically detect trailing
  newlines (shardy@redhat.com)
- spacecmd enhancement : make configchannel_addfile handle binary files
  (shardy@redhat.com)

* Mon Jan 16 2012 Aron Parsons <aronparsons@gmail.com> 1.7.2-1
- spacecmd enhancement : multiple delete for kickstart_delete
  (shardy@redhat.com)
- spacecmd bugfix : filter_results don't match substrings without wildcard
  (shardy@redhat.com)

* Sun Jan 15 2012 Aron Parsons <aronparsons@gmail.com> 1.7.1-1
- spacecmd enhancement : Add activationkey_setusagelimit (shardy@redhat.com)
- spacecmd bugfix : activationkey_setuniversaldefault zeros unlimited usage
  (shardy@redhat.com)
- spacecmd bugfix : activationkey_setbasechannel zeros unlimited usage
  (shardy@redhat.com)
- spacecmd enhancement: activationkey_details add usage_limit
  (shardy@redhat.com)
- spacecmd enhancement : Add softwarechannel_clonetree command
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_clone add regex mode
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_clone add option to copy gpg details
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_listchildchannels add verbose mode
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_listbasechannels add verbose mode
  (shardy@redhat.com)
- spacecmd documentation : Fix manpage help for a particular command
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_listchildchannels list specific
  children (shardy@redhat.com)
- spacecmd enhancement : Modify activationkey_clone to allow globbing
  (shardy@redhat.com)
- spacecmd bugfix : configchannel_clone fix some variable names
  (shardy@redhat.com)
- Bumping package versions for 1.7. (mzazrivec@redhat.com)

* Fri Dec 16 2011 Aron Parsons <aparsons@redhat.com> 1.6.11-1
- fix login for clear_caches to avoid error (shardy@redhat.com)

* Sun Dec 11 2011 Aron Parsons <aronparsons@gmail.com> 1.6.10-1
- spacecmd: fix typo in activationkey_export help (shardy@redhat.com)
- spacecmd: add configchannel_clone command (shardy@redhat.com)
- spacecmd: add configchannel_import command (shardy@redhat.com)
- spacecmd: add configchannel_export command (shardy@redhat.com)

* Wed Nov 23 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.9-1
- spacecmd: fix some errors in system_runscript (parsonsa@bit-sys.com)
- spacecmd: changed some non-critical errors to warnings (parsonsa@bit-sys.com)
- spacecmd: cleaned up error messages (parsonsa@bit-sys.com)
- spacecmd: activationkey_clone cleanup (parsonsa@bit-sys.com)
- spacecmd enhancement : Add activationkey_clone command (shardy@redhat.com)
- spacecmd enhancement : Add activationkey_import command (shardy@redhat.com)
- spacecmd enhancement : Add activationkey_export command (shardy@redhat.com)

* Wed Nov 23 2011 Aron Parsons <parsonsa@bit-sys.com>
- spacecmd: fix some errors in system_runscript (parsonsa@bit-sys.com)
- spacecmd: changed some non-critical errors to warnings (parsonsa@bit-sys.com)
- spacecmd: cleaned up error messages (parsonsa@bit-sys.com)
- spacecmd: activationkey_clone cleanup (parsonsa@bit-sys.com)
- spacecmd enhancement : Add activationkey_clone command (shardy@redhat.com)
- spacecmd enhancement : Add activationkey_import command (shardy@redhat.com)
- spacecmd enhancement : Add activationkey_export command (shardy@redhat.com)

* Wed Nov 16 2011 Aron Parsons <aparsons@redhat.com> 1.6.7-1
- spacecmd: remove comma from softwarechannel_setorgaccess output
  (aparsons@redhat.com)
- spacecmd: add tab completion to softwarechannel_{get,set}orgaccess
  (aparsons@redhat.com)
- spacecmd enhancement : add softwarechannel_getorgaccess command
  (shardy@redhat.com)
- spacecmd enhancement : add softwarechannel_setorgaccess command
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_list add tree pretty print option
  (shardy@redhat.com)
- spacecmd enhancement : softwarechannel_list add verbose mode
  (shardy@redhat.com)

* Mon Oct 24 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.6-1
- spacecmd: use correct variable in system_reboot (parsonsa@bit-sys.com)

* Wed Sep 28 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.5-1
- spacecmd: wrong argument in distribution_create help message (parsonsa@bit-
  sys.com)
- Automatic commit of package [spacecmd] release [1.6.4-1]. (parsonsa@bit-
  sys.com)
- spacecmd: added softwarechannel_regenerateyumcache (parsonsa@bit-sys.com)

* Fri Sep 23 2011 Aron Parsons <parsonsa@bit-sys.com> 1.6.4-1
- spacecmd: added softwarechannel_regenerateyumcache (parsonsa@bit-sys.com)

* Thu Aug 11 2011 Miroslav Suchý 1.6.3-1
- do not mask original error by raise in execption

* Thu Aug 04 2011 Aron Parsons <aparsons@redhat.com> 1.6.2-1
- Enable new 'api' module (satoru.satoh@gmail.com)
- add utility routines for new 'api' module (satoru.satoh@gmail.com)
- add api module to spacecmd (satoru.satoh@gmail.com)

* Fri Jul 22 2011 Jan Pazdziora 1.6.1-1
- We only support version 14 and newer of Fedora, removing conditions for old
  versions.

* Mon Jun 06 2011 Aron Parsons <aparsons@redhat.com> 1.5.3-1
- spacecmd: remove stray debug statement (aparsons@redhat.com)

* Mon Jun 06 2011 Aron Parsons <aparsons@redhat.com> 1.5.2-1
- spacecmd: cosmetics (aparsons@redhat.com)
- spacecmd: parse arguments the standard way in softwarechannel_list
  (aparsons@redhat.com)
- spacecmd: allow filtering of channels based on arguments in
  softwarechannel_list (aparsons@redhat.com)
- spacecmd: quote all arguments before passing them to precmd() when running a
  single command (aparsons@redhat.com)
- spacecmd: respect quoted arguments when looking at the line in precmd()
  (aparsons@redhat.com)
- spacecmd: be more precise when looking for '--help' in precmd()
  (aparsons@redhat.com)
- spacecmd: updated comment for precmd() (aparsons@redhat.com)

* Mon Apr 18 2011 Aron Parsons <aparsons@redhat.com> 1.5.1-1
- 696681 - fix spaces in system names in system_updatecustomvalue and
  system_addcustomvalue (aparsons@redhat.com)
- 696681 - allow special characters in server names
- whitespace cleanup (aparsons@redhat.com)
- fix handling of group names with spaces when expanding with
  'group:' (aparsons@redhat.com)
- added kickstart_clone (aparsons@redhat.com)
- Bumping package versions for 1.5 (msuchy@redhat.com)

* Mon Mar 28 2011 Aron Parsons <aparsons@redhat.com> 1.4.5-1
- added 'repo' module into shell (aparsons@redhat.com)
- added repo_list and repo_details (tljohnsn@oreillyschool.com)

* Fri Mar 11 2011 Aron Parsons <aparsons@redhat.com> 1.4.4-1
- added configchannel_verifyfile (aparsons@redhat.com)

* Fri Mar 11 2011 Aron Parsons <aparsons@redhat.com> 1.4.3-1
- fix invalid key name in errata_search (aparsons@redhat.com)

* Tue Mar 08 2011 Aron Parsons <aparsons@redhat.com> 1.4.2-1
- added group_backup and group_restore functions (john@vanzantvoort.org)
- don't get the UUID on older API versions (aparsons@redhat.com)

* Thu Mar 03 2011 Aron Parsons <aparsons@redhat.com> 1.4.1-1
- spacecmd: log channel access issues in debug mode only (aparsons@redhat.com)
- spacecmd: ignore channel failures introduced by organizations when caching
  packages (aparsons@redhat.com)
- spacecmd: print a summary list of all errata (name, synopsis, date)
  (aparsons@redhat.com)
- spacecmd: ignore channel failures introduced by organizations when caching
  errata (aparsons@redhat.com)
- spacecmd: delete child channels first in softwarechannel_delete
  (aparsons@redhat.com)
- Bumping package versions for 1.4 (tlestach@redhat.com)

* Thu Jan 27 2011 Aron Parsons <aparsons@redhat.com> 1.3.8-1
- added configchannel_backup function (john@vanzantvoort.org)

* Thu Dec 23 2010 Aron Parsons <aparsons@redhat.com> 1.3.7-1
- added system_syncpackages function

* Wed Dec 22 2010 Aron Parsons <aparsons@redhat.com> 1.3.6-1
- added organization functions

* Tue Dec 21 2010 Aron Parsons <aparsons@redhat.com> 1.3.5-1
- discard the password variable once we use it
- attempt to re-login as the same user if the cached credentials are invalid
- fix logic regarding which configuration files to load
- don't try to load non-existent config sections

* Tue Dec 21 2010 Aron Parsons <aparsons@redhat.com> 1.3.4-1
- support server-specific configuration sections in the configuration file
- added support for a system-wide configuration file
- added support for server-specific sections in the configuration file

* Fri Dec 10 2010 Aron Parsons <aparsons@redhat.com> 1.3.3-1
- add support for server UUIDs

* Tue Nov 30 2010 Aron Parsons <aparsons@redhat.com> 1.3.2-1
- don't use a cached session if username and password are passed as arguments
- added get_session function

* Mon Nov 22 2010 Aron Parsons <aparsons@redhat.com> 1.3.1-1
- fix uninitialized variable in snippet_create
- 655055 - honor the quiet flag when generating caches in spacecmd
* Fri Nov 05 2010 Aron Parsons <aparsons@redhat.com> 1.2.2-1
- spacecmd: fixed exception in kickstart_create due to typo
  (aparsons@redhat.com)

* Fri Oct 29 2010 Aron Parsons <aparsons@redhat.com> 1.2.1-1
- renamed system_addchildchannel to system_addchildchannels and
  system_removechildchannel to system_removechildchannels for consistency
- added help topics for time and system options
- print the system ID and last checkin in report_duplicates
- print help messages for functions if the user passes --help
- exit the shell if the initial login attempt fails
- version bump to 1.2 to stay in sync with other Spacewalk packages
* Thu Oct 07 2010 Aron Parsons <aparsons@redhat.com> 0.7.5-1
- fix unhandled exception in activationkey_create
  (aparsons@redhat.com)

* Wed Oct 06 2010 Aron Parsons <aparsons@redhat.com> 0.7.4-1
- fix compatability with Satellite 5.3 in configchannel_addfile
  (aparsons@redhat.com)
- fix man page formatting (aparsons@redhat.com)

* Tue Sep 28 2010 Aron Parsons <aparsons@redhat.com> 0.7.3-1
- forgot to add the actual option for revision in
  configchannel_addfile (aparsons@redhat.com)
* Tue Sep 28 2010 Aron Parsons <aparsons@redhat.com> 0.7.2-1
- allow the user to provide a revision number in
  configchannel_addfile (aparsons@redhat.com)
- force the user to enter a valid channel name in
  configchannel_addfile (aparsons@redhat.com)
- allow configchannel_addfile to be run non-interactively
  (aparsons@redhat.com)
- don't use mergeErrataWithPackages API (aparsons@redhat.com)

* Thu Sep 23 2010 Aron Parsons <aparsons@redhat.com> 0.7.1-1
- allow configchannel_create to be called non-interactively
  (aparsons@redhat.com)
- updated man page to explain how to run non-interactive commands
  (aparsons@redhat.com)
- allow softwarechannel_* functions to be called non-interactively
  (aparsons@redhat.com)
- allow system_* functions to be called non-interactively
  (aparsons@redhat.com)
- more fixes for ignorning the '-y' command-line option when it's not
  applicable (aparsons@redhat.com)
- allow user_* functions to be called non-interactively
  (aparsons@redhat.com)
- don't honor the '-y' command-line option when user_confirm isn't
  used as a confirmation (aparsons@redhat.com)
- allow snippet_* functions to be called non-interactively
  (aparsons@redhat.com)
- remove a comment about a fix that was committed ages ago
  (aparsons@redhat.com)
- allow kickstart_* functions to be called non-interactively
  (aparsons@redhat.com)
- allow distribution_* functions to be called non-interactively
  (aparsons@redhat.com)
- allow cryptokey_* functions to be called non-interactively
  (aparsons@redhat.com)
- added a function to read files (aparsons@redhat.com)
- allow activationkey_* functions to be called non-interactively
  (aparsons@redhat.com)
- added function to test if the called function is interactive
  (aparsons@redhat.com)
- support for named arguments in utils.parse_arguments()
  (aparsons@redhat.com)

* Tue Sep 21 2010 Aron Parsons <aparsons@redhat.com> 0.6.2-1
- added new function softwarechannel_removeerrata
  (aparsons@redhat.com)
- update softwarechannel_adderrata to use the new
  mergeErratawithPackages API call (aparsons@redhat.com)
* Mon Sep 20 2010 Aron Parsons <aparsons@redhat.com> 0.6.1-1
- support symlinks, selinux contexts and revisions in configchannel_*
  (aparsons@redhat.com)
- added new function softwarechannel_listallpackages
  (aparsons@redhat.com)
- avoid proxy timeouts when cloning errata by doing them individually
  (aparsons@redhat.com)
- allow --debug to be passed multiple times (aparsons@redhat.com)
- revert to the old-style of errata merging due to bugzilla 591291
  (aparsons@redhat.com)
- cleanup column headers in report_outofdatesystems
  (aparsons@redhat.com)
- show the last checkin time in report_inactivesystems
  (aparsons@redhat.com)
- clarify what 'Original State' means when cloning a software channel
  (aparsons@redhat.com)
- remove prompts for summary/description when creating software
  channels and just use the name (aparsons@redhat.com)

* Fri Aug 20 2010 Aron Parsons <aparsons@redhat.com> 0.5.7-1
- simplify checks for debug mode (aparsons@redhat.com)
- enable verbose mode for xmlrpclib when debugging is enabled
  (aparsons@redhat.com)

* Thu Aug 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.6-1
- updated documentation to point bug reports at Bugzilla
  (aparsons@redhat.com)
- added new function user_create (aparsons@redhat.com)
- added a parameter to return integers from user_confirm()
  (aparsons@redhat.com)
- add parameter to not print a blank line on user confirmations
  (aparsons@redhat.com)

* Thu Aug 05 2010 Milan Zazrivec <mzazrivec@redhat.com> 0.5.5-1
- added a missing hyphen in the spacecmd man page

* Wed Jul 28 2010 Aron Parsons <aparsons@redhat.com> 0.5.4-1
- simplified softwarechannel_adderrata (aparsons@redhat.com)
- added new function errata_publish (aparsons@redhat.com)
- support quoting of package profile names in tab completion
  (aparsons@redhat.com)
- remove old instance of system_createpackageprofile (aparsons@redhat.com)
- only call the system.listDuplicates* functions if the API supports it
  (aparsons@redhat.com)
- support quoting of group names (aparsons@redhat.com)
- support quoting of arguments (aparsons@redhat.com)
- change the log level for warning that cached credentials are invalid
  (aparsons@redhat.com)
- added new functions system_deletepackageprofile and
  system_listpackageprofiles (aparsons@redhat.com)
- added new functions to create and compare package profiles
  (aparsons@redhat.com)
- added new function system_listduplicates (aparsons@redhat.com)
- regenerate the errata cache after cloning errata (aparsons@redhat.com)
- added new function errata_delete (aparsons@redhat.com)
- list CVEs in errata_details (aparsons@redhat.com)
- added new function errata_listcves (aparsons@redhat.com)
- make system_installpackage use the new API system.listLatestAvailablePackage
  (aparsons@redhat.com)
- don't include archived actions in the default call of schedule_list
  (aparsons@redhat.com)
- significant improvement to the performance of schedule_list* functions
  (aparsons@redhat.com)
- changed where an empty list is checked for in schedule_reschedule
  (aparsons@redhat.com)
- fixed tab completion in schedule_cancel (aparsons@redhat.com)
- added function schedule_reschedule (aparsons@redhat.com)
- allow filtering in report_errata (aparsons@redhat.com)

* Mon Jul 26 2010 Miroslav Suchý <msuchy@redhat.com> 0.5.3-1
- 616120 - remove python requires (msuchy@redhat.com)
- 616120 - add -p to install, to preserve timestamps (msuchy@redhat.com)

* Thu Jul 22 2010 Aron Parsons <aparsons@redhat.com> 0.5.2-1
- move python files in site-packages (aparsons@redhat.com)
- fixes to spacecmd.spec per Fedora package review (aparsons@redhat.com)
- fixed report_kernels not grabbing the correct value for each system (thanks
  to James Tanner) (aparsons@redhat.com)
- don't print an empty line if there are no results from package_search
  (aparsons@redhat.com)
- temporarily update the command prompt to tell the user when caches are being
  generated (aparsons@redhat.com)
- rename kickstart_getfile to kickstart_getcontents (aron@redhat.com)
- remove a false statement (aron@redhat.com)
- remove references to closed Bugzillas (aron@redhat.com)
- remove unused binary file support from configchannel_addfile
  (aron@redhat.com)
- update kickstart_getfile to use the new
  kickstart.profile.downloadRenderedKickstart method (aron@redhat.com)
- remove reference to 584860 since it has been fixed in spacewalk
  (aron@redhat.com)
- implemented configchannel_listsystems (aron@redhat.com)
- moved global variables out of shell.py and into more appropriate locations
  (aron@redhat.com)
- session_file didn't need to be global (aron@redhat.com)
- make sure ~/.spacecmd/<server> exists before writing the session cache
  (aron@redhat.com)
- only store one session in the cache (aron@redhat.com)

* Mon Jul 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.1-1
- new package built with tito

* Mon Jul 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.0-1
- new package built with tito
* Mon Jul 19 2010 Aron Parsons <aparsons@redhat.com> 0.5.0-1
- version bump
- update the URL to point at fedorahosted.org
- fixes from rpmlint

* Fri Jul 09 2010 Aron Parsons <aparsons@redhat.com> 0.4.2-1
- fixed an unhandled exception when doing a history lookup (aparsons@redhat.com)
- cleaned up system_upgradepackage and system_listupgrades (aparsons@redhat.com)
- added calls to generate_package_cache in get_package_name and get_package_id
  (aparsons@redhat.com)
- use macros for commands where possible (aparsons@redhat.com)
- use existing file details (owner, group, mode) when updating a config file
  (aparsons@redhat.com)
- cleanup the bash completion file (aparsons@redhat.com)
- Automatic commit of package [spacecmd] release [0.4.2-1]. (aparsons@redhat.com)
- system_applyerrata now just calls errata_apply() with the correct arguments
  (aparsons@redhat.com)
- reworked errata_apply() to schedule all errata for each system via one API
  call.  this also only schedules currently unscheduled errata, which
  eliminates error messages when an errata is already scheduled
  (aparsons@redhat.com)
- removed print_action_output() (aparsons@redhat.com)
- cleaned up schedule_getoutput (aparsons@redhat.com)
- removed an unnecessary sort (aparsons@redhat.com)
- changed the cancel prompt to be consistent with other prompts fixed the tab
  completion for schedule_cancel (aparsons@redhat.com)
- removed format_time() (aparsons@redhat.com)
- use the action name instead of type to be more verbose (aparsons@redhat.com)
- rewrote schedule_list* so be more concise and greppable (aparsons@redhat.com)
- added an explanation of valid date strings (aparsons@redhat.com)
- fix the handling of YYYYMMDD dates (aparsons@redhat.com)
- remove limit option from system_listevents (aparsons@redhat.com)
- minor tweaks to some output (aparsons@redhat.com)
- cleanup of system_installpackage (aparsons@redhat.com)
- added package_listerrata (aparsons@redhat.com)
- removed an unnecessary call to generate_package_cache (aparsons@redhat.com)
- fixed the exception handling in get_package_{name,id} (aparsons@redhat.com)
- changed the global separator to use # instead of - (aparsons@redhat.com)
- print the number of installed systems in package_details allow globbing in
  package_details (aparsons@redhat.com)
- added package_listinstalledsystems (aparsons@redhat.com)
- cache the reverse dictionary of (package_id, package_name) renamed the global
  variables that hold all package names (aparsons@redhat.com)
- allow timestamps of YYYYMMDDHHMM (aparsons@redhat.com)
- don't prompt the user in softwarechannel_removepackages if there are no
  packages to remove (aparsons@redhat.com)
- print a newline before the debug messages when generating the caches
  (aparsons@redhat.com)
- added toggle_confirmations (aparsons@redhat.com)
- reworked errata_apply to speed it up (some more stuff is coming)
  (aparsons@redhat.com)
- package_search wasn't returning an empty list if no results were found
  (aparsons@redhat.com)
- tweaked the format of the output (replaced trailing colons with underlines to
  separate sections) (aparsons@redhat.com)
- sort the package list in softwarechannel_adderrata and added some debug
  statements (aparsons@redhat.com)
- move the call to generate the errata cache up a little bit (aparsons@redhat.com)
- added softwarechannel_adderrata and changed softwarechannel_mergeerrata to
  softwarechannel_adderratabydate (aparsons@redhat.com)
- compile and re-use patterns in filter_results (aparsons@redhat.com)
- remove the seemingly unnecessary report_activesystems (aparsons@redhat.com)
- fix displaying file contents in configchannel_filedetails (aparsons@redhat.com)
- added functions to list only base and child channels (aparsons@redhat.com)
- fixed tab completion for system_addchildchannel and system_removechildchannel
  (aparsons@redhat.com)
- tweaked the shell intro (aparsons@redhat.com)
- added a confirmation and status to system_deployconfigfiles (aparsons@redhat.com)
- fixed exception handling regarding limits in schedule.py (aparsons@redhat.com)
- when merging errata, only add packages that exist in the source channel
  (aparsons@redhat.com)
- - add a message for user interrupts on single commands (aparsons@redhat.com)
- - show the number of affected systems in errata_details (aparsons@redhat.com)
- - handle user interrupts better in errata_apply - be more diligent about
  finding the errata ID in errata_apply (aparsons@redhat.com)

* Tue Jul 06 2010 Paul Morgan <pmorgan@redhat.com> - 0.4.1-1
- ADD: support for builds via tito
- CHANGE: x.y.z versioning (better for tito)
- tagged man page as doc

* Thu Jul 01 2010 Aron Parsons <aparsons@redhat.com> - 0.4-1
- version bump
- added a man page

* Fri Jun 25 2010 Aron Parsons <aparsons@redhat.com> - 0.3-1
- version bump
- added bash-completion support

* Mon Jun 21 2010 Aron Parsons <aparsons@redhat.com> - 0.2-1
- version bump

* Mon Jun 21 2010 Aron Parsons <aparsons@redhat.com> - 0.1-4
- added distribution headings
- added a copy of the GPL

* Thu Apr 29 2010 Aron Parsons <aparsons@redhat.com> - 0.1-3
- just touch __init__.py, no reason to version control an empty file

* Wed Apr 28 2010 Aron Parsons <aparsons@redhat.com> - 0.1-2
- moved SpacewalkShell.py to /usr/share/rhn/spacecmd

* Tue Apr 27 2010 Paul Morgan <pmorgan@redhat.com> - 0.1-1
- initial packaging
