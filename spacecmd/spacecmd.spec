%if ! (0%{?fedora} || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif

%if 0%{?fedora} || 0%{?rhel} >= 7
%{!?pylint_check: %global pylint_check 1}
%endif

%if 0%{?fedora} || 0%{?suse_version} > 1320
%global build_py3   1
%global python_sitelib %{python3_sitelib}
%endif

Name:        spacecmd
Version:     2.9.0
Release:     1%{?dist}
Summary:     Command-line interface to Spacewalk and Red Hat Satellite servers

License:     GPLv3+
URL:         https://github.com/spacewalkproject/spacewalk/wiki/spacecmd
Source:      https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:   noarch

%if 0%{?pylint_check}
%if 0%{?build_py3}
BuildRequires: spacewalk-python3-pylint
%else
BuildRequires: spacewalk-python2-pylint
%endif
%endif
%if 0%{?build_py3}
BuildRequires: python3
BuildRequires: python3-devel
BuildRequires: python3-simplejson
BuildRequires: python3-rpm
Requires:      python3
%else
BuildRequires: python
BuildRequires: python-devel
BuildRequires: python-simplejson
BuildRequires: rpm-python
Requires:      python
%if 0%{?suse_version}
BuildRequires: python-xml
Requires:      python-xml
%endif
%endif
Requires:    file


%description
spacecmd is a command-line interface to Spacewalk and Red Hat Satellite servers

%prep
%setup -q

%build
# nothing to build

%install
%{__rm} -rf %{buildroot}

%{__mkdir_p} %{buildroot}/%{_bindir}

%if 0%{?build_py3}
    sed -i 's|#!/usr/bin/python|#!/usr/bin/python3|' ./src/bin/spacecmd
%endif
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

%if 0%{?suse_version}
%if 0%{?build_py3}
%py3_compile -O %{buildroot}/%{python_sitelib}
%else
%py_compile -O %{buildroot}/%{python_sitelib}
%endif
%endif

%check
%if 0%{?pylint_check}
%if 0%{?build_py3}
PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib} \
	  spacewalk-python3-pylint $RPM_BUILD_ROOT%{python_sitelib}/spacecmd
%else
PYTHONPATH=$RPM_BUILD_ROOT%{python_sitelib} \
	  spacewalk-python2-pylint $RPM_BUILD_ROOT%{python_sitelib}/spacecmd
%endif
%endif

%files
%{_bindir}/spacecmd
%{python_sitelib}/spacecmd/
%ghost %config %{_sysconfdir}/spacecmd.conf
%dir %{_sysconfdir}/bash_completion.d
%{_sysconfdir}/bash_completion.d/spacecmd
%doc src/doc/README src/doc/COPYING
%doc %{_mandir}/man1/spacecmd.1.gz

%changelog
* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.25-1
- Revert "1533052 - Add FQDN detection to setup and config utilities."

* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.24-1
- 1533052 - Add FQDN detection to setup and config utilities.

* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.23-1
- Fixing pylint

* Mon Mar 26 2018 Jiri Dostal <jdostal@redhat.com> 2.8.22-1
- BZ 1539878 - add save_cache to do_ssm_intersect
- [spacecmd] Fix softwarechannel_listsyncschedule

* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.21-1
- Updating copyright years for 2018

* Wed Feb 28 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.20-1
- 1536484 - Command spacecmd supports utf8 name of systems

* Wed Feb 28 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.19-1
- 1484056 - updatefile and addfile are basically same calls
- 1484056 - make configchannel_addfile fully non-interactive

* Mon Feb 26 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.18-1
- convert to int when getting int input
- 1445725 - display all checksum types, not just MD5

* Wed Feb 21 2018 Eric Herget <eherget@redhat.com> 2.8.17-1
- PR602 - more python3 support updates
- PR602 - Update to use newly separated spacewalk-python[2|3]-pylint packages
- PR602 - switch to argparse from optparse
- PR602 - fix fedora 26 build
- PR602 - lint fixes
- PR602 - use py_compile only on SUSE
- PR602 - make lambda call python3 compatible
- PR602 - make mkdir mode python3 compatible
- PR602 - make exec python3 compatible
- PR602 - make exceptions python3 compatible
- PR602 - make print python3 compatible
- PR602 - build with python3

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.16-1
- removed %%%%defattr from specfile
- removed Group from specfile

* Mon Jan 22 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.15-1
- search for actual package name

* Tue Jan 16 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.14-1
- 1429944 - return system id from search for distinguishable results

* Fri Jan 12 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.13-1
- support utf8 name

* Tue Jan 02 2018 Jiri Dostal <jdostal@redhat.com> 2.8.12-1
- 1528248 - add --config option to spacecmd.

* Thu Nov 16 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.11-1
- 1373378 - don't break on all whitespace characters

* Mon Oct 23 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.10-1
- pylint - fix intendation

* Fri Oct 20 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.9-1
- show list of arches for channel

* Mon Oct 09 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.8-1
- 1497216 - fix pylint

* Fri Oct 06 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.7-1
- allow softwarechannel_setsyncschedule to disable schedule

* Fri Oct 06 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- 1497216 - extend original PR to include all sync options
- bz1497216 - [RFE] Add softwarechannel_setsyncschedule --latest

* Wed Oct 04 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.5-1
- 1373378 - don't break multi-word arguments passed to spacecmd

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- purged changelog entries for Spacewalk 2.0 and older

* Tue Sep 05 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- 1487684 - spacecmd ERROR: SpacewalkShell instance has no attribute
  'org_confirm'

* Mon Sep 04 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- removed unnecessary BuildRoot tag

* Tue Aug 22 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.1-1
- 1429944 - in case of system named by id, let id take precedence
- Bumping package versions for 2.8.

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.15-1
- update copyright year

* Thu Jul 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.14-1
- pylint fixes

* Wed Jun 14 2017 Grant Gainey 2.7.13-1
- pylint: disable 'too many returns' for src/lib/softwarechannel.py
- Fix pylint (bad-continuation)
- Add softwarechannel_setdetails

* Mon Jun 12 2017 Jiri Dostal <jdostal@redhat.com> 2.7.12-1
- 1434037 - Make spacecmd prompt for password when overriding config file user

* Mon Jun 05 2017 Ondrej Gajdusek <ogajduse@redhat.com> 2.7.11-1
- 1367562 - show less output of common packages in selected channels
- Revert "1367562 - spacecmd: Added output to logging.debug from
  softwarechannel_sync func"

* Fri Apr 21 2017 Jan Dobes 2.7.10-1
- 1414454 - work with list of manageable channels in org-access actions
- 1414454 - adding softwarechannel_listmanageablechannels

* Fri Apr 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.9-1
- 1436644 - provide more info in error message

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

