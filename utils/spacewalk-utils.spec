%define rhnroot %{_prefix}/share/rhn
%if 0%{?fedora} || 0%{?rhel} >= 7
%{!?pylint_check: %global pylint_check 1}
%endif

Name:		spacewalk-utils
Version:	2.9.2
Release:	1%{?dist}
Summary:	Utilities that may be run against a Spacewalk server.

License:	GPLv2
URL:		https://github.com/spacewalkproject/spacewalk
Source0:	https://github.com/spacewalkproject/spacewalk/archive/%{name}-%{version}.tar.gz
BuildArch:      noarch

%if 0%{?pylint_check}
BuildRequires:  spacewalk-python2-pylint
%endif
BuildRequires:  /usr/bin/docbook2man
BuildRequires:  docbook-utils
BuildRequires:  python
BuildRequires: /usr/bin/pod2man
%if 0%{?fedora} || 0%{?rhel} > 5
BuildRequires:  yum
BuildRequires:  spacewalk-config
BuildRequires:  spacewalk-backend >= 1.7.24
BuildRequires:  spacewalk-backend-libs >= 1.7.24
BuildRequires:  spacewalk-backend-tools >= 1.7.24
%endif

Requires:       bash
Requires:       cobbler20
Requires:       coreutils
Requires:       initscripts
Requires:       iproute
Requires:       net-tools
Requires:       /usr/bin/spacewalk-sql
Requires:       perl-Satcon
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       python, rpm-python
%if 0%{?rhel} == 6
Requires:       python-argparse
%endif
Requires:       rhnlib >= 2.5.20
Requires:       rpm
Requires:       setup
Requires:       spacewalk-admin
Requires:       spacewalk-certs-tools
Requires:       spacewalk-config
Requires:       spacewalk-setup
Requires:       spacewalk-backend
Requires:       spacewalk-backend-libs
Requires:       spacewalk-backend-tools >= 2.2.27
Requires:       spacewalk-reports
Requires:       yum-utils

%description
Generic utilities that may be run against a Spacewalk server.


%prep
%setup -q

%if  0%{?rhel} && 0%{?rhel} < 6
%define pod2man POD2MAN=pod2man
%endif

%build
make all %{?pod2man}

%install
install -d $RPM_BUILD_ROOT/%{rhnroot}
make install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir} %{?pod2man}


%clean

%check
%if 0%{?pylint_check}
# check coding style
spacewalk-python2-pylint $RPM_BUILD_ROOT%{rhnroot}
%endif

%files
%config %{_sysconfdir}/rhn/spacewalk-common-channels.ini
%attr(755,root,root) %{_bindir}/*
%dir %{rhnroot}/utils
%{rhnroot}/utils/__init__.py*
%{rhnroot}/utils/systemSnapshot.py*
%{rhnroot}/utils/migrateSystemProfile.py*
%{rhnroot}/utils/cloneByDate.py*
%{rhnroot}/utils/depsolver.py*
%{_mandir}/man8/*


%changelog
* Thu Apr 26 2018 Jiri Dostal <jdostal@redhat.com> 2.9.2-1
- reflect copr.fedorainfracloud.org packages moving for spacewalk-2.8

* Wed Apr 25 2018 Grant Gainey 2.9.1-1
- 1554307 - make purge-loop work off static timestamp
- Bumping package versions for 2.9.

* Thu Mar 29 2018 Jiri Dostal <jdostal@redhat.com> 2.8.17-1
- Update gpgs in database
- Update common channels with latest releases

* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.16-1
- Revert "1533052 - Add FQDN detection to setup and config utilities."

* Tue Mar 27 2018 Jiri Dostal <jdostal@redhat.com> 2.8.15-1
- 1533052 - Add FQDN detection to setup and config utilities.

* Thu Mar 22 2018 Grant Gainey 2.8.14-1
- 1537766 - make sure to send output to log and stdout
- 1537766 - reject negative numbers for batch/interval/age
- Two tiny typos in the spacewalk-manage-snapshots man-page

* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 2.8.13-1
- run pylint on rhel 7 builds

* Tue Feb 13 2018 Eric Herget <eherget@redhat.com> 2.8.12-1
- Update to use newly separated spacewalk-python[2|3]-pylint packages

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.11-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Tue Feb 06 2018 Grant Gainey 2.8.10-1
- 1537766 - Fix broken DELETE in postgresql

* Tue Jan 23 2018 Grant Gainey 2.8.9-1
- 1537766 - Add spacewalk-manage-snapshots, to give sw-admin a snapshot-mgt
  tool

* Fri Dec 01 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.8-1
- add nightly-server repository for Fedora 27
- add nightly-client repository for Fedora 27
- add Fedora 27 repositories
- remove Fedora 24 as it is EOL now

* Mon Oct 16 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.7-1
- Fix to promote a child channel as child channel

* Thu Oct 05 2017 Eric Herget <eherget@redhat.com> 2.8.6-1
- 1001613 - man-page for spacewalk-sync-setup

* Mon Sep 11 2017 Grant Gainey 2.8.5-1
- 1458440 - Reset to use https, make xmlrpc-cnx debuggable

* Mon Sep 11 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.4-1
- remove unused macro
- updated spacewalk nightly url

* Fri Sep 08 2017 Grant Gainey 2.8.3-1
- 1458440 - Fixed processing in the absence of input           Also fixed
  'xmlrpclib ssl no longer likes self-signed sat-certs' - match examples, use
  HTTP

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.2-1
- purged changelog entries for Spacewalk 2.0 and older
- use standard brp-python-bytecompile

* Thu Aug 24 2017 Ondrej Gajdusek <ogajduse@redhat.com>
- PR 566 - Add spacewalk client and server repos for Fedora 25 and 26
- Bumping package versions for 2.8.

* Wed Aug 16 2017 Eric Herget <eherget@redhat.com> 2.7.23-1
- SW 2.7 Release prep - update copyright year (3rd pass)

* Wed Aug 16 2017 Jiri Dostal <jdostal@redhat.com> 2.7.22-1
- 1458440 - The command "spacewalk-sync-setup" without any parameters return
  traceback

* Mon Aug 07 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.21-1
- don't link old perl manpage in man

* Fri Aug 04 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.20-1
- rewrite spacewalk-api utility into python

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.19-1
- update copyright year

* Thu Jul 27 2017 Jan Dobes 2.7.18-1
- Add Spacewalk 2.7 release for util
- Add new Fedora 26 channels for util
- 1321196 - centos6-addons is not available
- Bug 1321210 - repository for Centos 7 i386 is not available

* Thu Jul 20 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.17-1
- pylint fixes

* Mon Jul 17 2017 Grant Gainey 2.7.16-1
- add opensuse_leap42_3 and remove opensuse13_2
- 1007526 - minor tweak to archive-audits manpage

* Thu May 11 2017 Eric Herget <eherget@redhat.com> 2.7.15-1
- 1449529 - taskotop retrieve list of each task by end date, not start date
- Remove unused imports.

* Wed Apr 26 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.14-1
- update CentOS7 addon repos
- removed definitions of EOLed products

* Tue Apr 25 2017 Eric Herget <eherget@redhat.com> 2.7.13-1
- 1434564 - RFE: taskotop enhancements continued - fix on Oracle

* Fri Apr 21 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.12-1
- add new channels Fedora 25 and Spacewalk 2.6
- Adding and updating Oracle channels.

* Wed Apr 19 2017 Eric Herget <eherget@redhat.com> 2.7.11-1
- 1442238 - taskotop various fixes to command line arg processing and logging

* Wed Mar 29 2017 Gennadii Altukhov <galt@redhat.com> 2.7.10-1
- 1305744 - add UTF-8 encoding before output on stdout

* Tue Mar 28 2017 Eric Herget <eherget@redhat.com> 2.7.9-1
- 1434564 - Update taskotop man page
- 1434564 - Add command line argument to optionally specify the number of times
  taskotop should iterate before exiting.
- 1434564 - Modify output columns to include task run end time and optional
  task run start time.  Drop the status column because its redundant.
- 1434564 - Add new 'each task' display mode
- docbook manpage for delete-old-systems-interactive
- rewrite delete-old-systems-interactive into python

* Wed Mar 15 2017 Eric Herget <eherget@redhat.com> 2.7.8-1
- 1432629 - add taskomaticd process info in optional header to taskotop
- remove system currency generation script

* Mon Mar 13 2017 Eric Herget <eherget@redhat.com> 2.7.7-1
- 1430901 - taskotop enhancements
- Updated links to github in spec files
- Migrating Fedorahosted to GitHub

* Wed Feb 15 2017 Gennadii Altukhov <galt@redhat.com> 2.7.6-1
- 1414855 - add exception processing in taskotop

* Tue Feb 14 2017 Grant Gainey 2.7.5-1
- 1404692 - tweaked manpage a bit

* Mon Feb 13 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.4-1
- 1404692 - fix sgml errors

* Fri Feb 10 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- 1404692 - add additional info about taskotop

* Thu Feb 09 2017 Jan Dobes 2.7.2-1
- 1404692 - add basic help for taskotop
- 1403961 - add Fedora 25 repositories

* Mon Jan 23 2017 Jan Dobes 2.7.1-1
- use spacewalk 2.6 for openSUSE Leap 42.2
- add channels for openSUSE Leap 42.2
- 1402781 - solaris architecture was removed
- Bumping package versions for 2.7.

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 2.6.16-1
- Added repo urls and gpg keys for Fedora 24

* Fri Oct 21 2016 Gennadii Altukhov <galt@redhat.com> 2.6.15-1
- pylint fix: Too many nested blocks (6/5) (too-many-nested-blocks)

* Thu Oct 20 2016 Grant Gainey 2.6.14-1
- 1369888 - log synopsis with advisory
- 1382272 - Change last RPM to package

* Thu Oct 06 2016 Grant Gainey 2.6.13-1
- Fix tagging issue

* Thu Oct 06 2016 Grant Gainey
- 1382272 - Fix typos in/general cleanup of CBD manpage

* Thu Oct 06 2016 Grant Gainey 2.6.12-1
- 1382272 - Fix typos in/general cleanup of CBD manpage

* Wed Oct 05 2016 Grant Gainey 2.6.11-1
- 1369185 - Alphabetize c-b-d switches in help/manpage
- 1369185 - Add RPMs from 'discovered' dependencies to depsolv list in
  cloneByDate Add new switch, --skip-errata-depsolv, allowing one to choose to
  not do that. Added --skip-errata-depsolv to manpage

* Thu Sep 22 2016 Grant Gainey 2.6.10-1
- 1369888 - Added more summary-info to cbd, sorted various outputs

* Thu Sep 15 2016 Jan Dobes 2.6.9-1
- fixing pylint in spacewalk-utils

* Tue Sep 13 2016 Jan Dobes 2.6.8-1
- fixing pylint: unused import

* Mon Sep 12 2016 Jan Dobes 2.6.7-1
- Revert "don't add newer errata when processing dependencies"

* Thu Aug 18 2016 Grant Gainey 2.6.6-1
- 1366343 - correct typo in name of errata-clone.log file

* Wed Aug 17 2016 Grant Gainey 2.6.5-1
- 1367911 - fix recursion by removing *all* copies of a 'visited' rpm when
  doing dep-checking

* Fri Aug 12 2016 Grant Gainey 2.6.4-1
- 1366343 - clean up style warnings

* Thu Aug 11 2016 Grant Gainey 2.6.3-1
- 1366343 - Clean up logging, add CLI output summary, clean up manpage

* Mon Jul 18 2016 Tomas Lestach <tlestach@redhat.com> 2.6.2-1
- fix typo in spacwalk-clone-by-date man page

* Fri May 27 2016 Jan Dobes 2.6.1-1
- talk about spacewalk
- adding postgresql systemd path
- Bumping package versions for 2.6.

* Thu May 26 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.11-1
- updating spacewalk-common-channels with Spacewalk 2.5

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.10-1
- updating copyright years

* Wed May 04 2016 Gennadii Altukhov <galt@redhat.com> 2.5.9-1
- Add Fedora 23 repositories into spacewalk-common-channels config
- taskotop: a utility to monitor what Taskomatic is doing

* Thu Apr 14 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.8-1
- 1103960 - removed escape of regular expressions, updated man page

* Fri Apr 01 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.7-1
- 1103960 - spacewalk-clone-by-date - package names may contain special regexp
  chars now

* Mon Jan 25 2016 Grant Gainey 2.5.6-1
- Extended allowed delimiters to include '.'
- Add delimiter option for spacewalk-manage-channel-lifecycle

* Thu Jan 21 2016 Tomas Lestach <tlestach@redhat.com> 2.5.5-1
- add openSUSE Leap 42.1
- remove outdated openSUSE distribution 13.1
- Added UEK4 channels for Oracle Linux 6 and 7.

* Thu Jan 14 2016 Jan Dobes 2.5.4-1
- fixing typo in 'archs'

* Wed Dec 09 2015 Jan Dobes 2.5.3-1
- Updated Oracle yum repo URLs and added new repositories for OL6 and OL7.

* Thu Nov 26 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.2-1
- make clone-by-date python 2.4 compatible

* Mon Oct 12 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- 1262348 - disable spacewalk-dump-schema functionality when rhn-upgrade
  package is found
- Bumping package versions for 2.5.

* Tue Sep 29 2015 Jan Dobes 2.4.19-1
- adding Spacewalk 2.4 entries
- adding F22
- update spacewalk nightly entries
- no nightly for all F20 and EL5 server

* Fri Sep 25 2015 Jan Dobes 2.4.18-1
- have version in name
- updating gpg
- Spacewalk 2.3 is not for el5 but is for el7
- removing Spacewalk 2.1 entries

* Thu Sep 24 2015 Jan Dobes 2.4.17-1
- Bumping copyright year.

* Mon Sep 21 2015 Jan Dobes 2.4.16-1
- fixing interactive run

* Tue Aug 18 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.15-1
- list[] vs list() - list[] is bad

* Fri Aug 07 2015 Jan Dobes 2.4.14-1
- use hostname instead of localhost for https connections

* Wed Aug 05 2015 Jan Dobes 2.4.13-1
- regenerate CA cert too

* Wed Aug 05 2015 Jan Dobes 2.4.12-1
- trust spacewalk CA certificate

* Thu Jul 30 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.11-1
- disable pylint warnings
- simplify expression
- remove unused variable

* Tue Jul 28 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.10-1
- prevent infinte recursion cycles in spacewalk-clone-by-date
- remove unused variable

* Fri Jul 24 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.9-1
- require cobbler20 - Spacewalk is not working with upstream cobbler anyway


* Tue Jul 14 2015 Jiri Dostal <jdostal@redhat.com> 2.4.8-1
- Bug 1077770 - Added error messages and fixed error codes

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.7-1
- satisfy pylint

* Tue Jul 14 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.6-1
- remove Except KeyboardInterrupt from imports
- don't add newer errata when processing dependencies

* Fri Jun 26 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.5-1
- Recommend cobbler20 with all packages requiring cobbler on Fedora 22

* Wed May 27 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.4-1
- fix pylint warning on Fedora 22

* Fri Apr 24 2015 Matej Kollar <mkollar@redhat.com> 2.4.3-1
- remove whitespace from .sgml files

* Wed Apr 08 2015 Jan Dobes 2.4.2-1
- RHEL 7 and recent Fedoras don't have hostname in /etc/sysconfig/network

* Wed Apr 01 2015 Stephen Herr <sherr@redhat.com> 2.4.1-1
- 1207846 - clone-by-date no longer can asynchronously clone errata
- Bumping package versions for 2.4.

* Wed Mar 25 2015 Grant Gainey 2.3.36-1
- Remove references to fedora18/19 and spacewalk20

* Mon Mar 23 2015 Grant Gainey 2.3.35-1
- Standardize pylint-check to only happen on Fedora

* Thu Mar 19 2015 Grant Gainey 2.3.34-1
- Spacewalk 2.3 repos for spacewalk-common-channels
- Updating copyright info for 2015

* Wed Mar 18 2015 Tomas Lestach <tlestach@redhat.com> 2.3.33-1
- Fix automatic assumption of first phase

* Fri Mar 13 2015 Tomas Lestach <tlestach@redhat.com> 2.3.32-1
- Added new public Oracle Linux channels and fix up channel names to match ULN
  /public-yum naming.

* Tue Feb 24 2015 Jan Dobes 2.3.31-1
- 1095841 - improve dumping script

* Mon Feb 16 2015 Stephen Herr <sherr@redhat.com> 2.3.30-1
- remove last references to monitoring code from hostname-rename script

* Tue Feb 03 2015 Grant Gainey 2.3.29-1
- spacewalk-final-archive manpage
- spacewalk-final-archive fixes and cleanup
- Archiving spacewalk data, first draft
- Setting ts=4 is wrong

* Tue Jan 27 2015 Grant Gainey 2.3.28-1
- 1177089 - Don't try to use 'createrepo --no-database' if createrepo doesn't
  know it
- 1162160 - Teach spacewalk-export to notice errors, teach spacewalk-export-
  channels to stop throwing them

* Mon Jan 26 2015 Matej Kollar <mkollar@redhat.com> 2.3.27-1
- Fix Pylint on Fedora 21: autopep8

* Fri Jan 16 2015 Tomas Lestach <tlestach@redhat.com> 2.3.26-1
- Fix wrong package dependency using yum without priorities

* Mon Jan 12 2015 Matej Kollar <mkollar@redhat.com> 2.3.25-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of trailing spaces in Perl

* Fri Dec 19 2014 Tomas Lestach <tlestach@redhat.com> 2.3.24-1
- 1175637 - make the sql Oracle 10g compatible

* Wed Dec 17 2014 Jan Dobes 2.3.23-1
- 1175398 - introduce --host and --port parameter for external PostgreSQL

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.22-1
- drop monitoring code and monitoring schema

* Mon Dec 15 2014 Jan Dobes 2.3.21-1
- 1171675 - we do not support postgresql to upgrade from

* Wed Dec 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.20-1
- added Fedora 21 channels

* Wed Dec 03 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.19-1
- remove unnecessary brackets

* Fri Nov 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.18-1
- Updated spacewalk-common-channels.ini to include Oracle Linux 7
- remove openSUSE 12.3 from spacewalk-common-channels
- Add openSUSE 13.2 repositories to spacewalk-common-channels

* Thu Nov 06 2014 Stephen Herr <sherr@redhat.com> 2.3.17-1
- 1161040 - prevent empty dir creation by scbd

* Wed Oct 29 2014 Stephen Herr <sherr@redhat.com> 2.3.16-1
- 1158655 - fix error if blacklist / removelist not in scbd config file
- 1015963 - improve error messaging in scbd about optinos that don't make sense

* Thu Oct 23 2014 Tomas Lestach <tlestach@redhat.com> 2.3.15-1
- 1028933 - extending spacewalk-api man page with usage of boolean values

* Wed Oct 22 2014 Tomas Lestach <tlestach@redhat.com> 2.3.14-1
- 1028933 - detect invalid boolean/integer entries
- 1150697 - teach spacewalk-export that system-profiles org is organization_id

* Sun Sep 28 2014 Aron Parsons <aronparsons@gmail.com> 2.3.13-1
- spacewalk-manage-channel-lifecycle: put default phases in help output

* Fri Sep 12 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.12-1
- Allow use of "-" symbol in phase names, e.g. "foo-test" instead of "foo_test"
- python2.4 compatibility

* Thu Sep 11 2014 Tomas Lestach <tlestach@redhat.com> 2.3.11-1
- 1140593 - use python2.4 compatible construct

* Thu Sep 04 2014 Jan Dobes 2.3.10-1
- export sequences from PostgreSQL properly

* Thu Aug 21 2014 Jan Dobes 2.3.9-1
- Oracle SQLPlus fixes
- cannot use hex characters in Oracle
- do not use substitution characters
- insert binaries in procedure due to Oracle SQLPlus limits
- print insert statement at once
- update documentation
- insert into Oracle tables - binaries
- insert into Oracle tables - sequences
- insert into Oracle tables - custom types
- insert into Oracle tables - timestamps
- insert into Oracle tables - insert statement
- disable and enable triggers and logging in Oracle
- disable and enable indexes in Oracle, set time format and control parameters
- add PostgreSQL binary type
- create array from custom types fetched from PostgreSQL
- support getting sequence names from PostgreSQL
- support getting table names from PostgreSQL
- support connection to PostgreSQL backend
- add new parameters for specify source and target database backend

* Tue Aug 12 2014 Stephen Herr <sherr@redhat.com> 2.3.8-1
- 1079263 - man page update: clone-by-date doesn't support 3rd party repos

* Mon Aug 11 2014 Tomas Lestach <tlestach@redhat.com> 2.3.7-1
- 1128680 - add spacewalk-reports dependency for spacewalk-utils

* Thu Aug 07 2014 Grant Gainey 2.3.6-1
- 1126928 - add sys-prof and kickstart-scripts to spacewalk-export
- 1114602 - Teach spacewalk-export that files in final tar should be owned by
  apache

* Thu Jul 31 2014 Grant Gainey 2.3.5-1
- Fix spacewalk-export to use config-files-latest not config-files
- 1123437 - Replace .format with %% to run on python2.4

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- 1122706 - Add config-files to list spacewalk-export knows

* Fri Jul 25 2014 Stephen Herr <sherr@redhat.com> 2.3.3-1
- 1123468 - improve clone-by-date dependency resolution

* Tue Jul 15 2014 Stephen Herr <sherr@redhat.com> 2.3.2-1
- 1119405 - Check if dest parent is cloned
- 1119405 - sw-clone-by-date man page update

* Mon Jul 14 2014 Stephen Herr <sherr@redhat.com> 2.3.1-1
- 1119411 - add dry-run to config file
- 1119411 - [RFE] sw-clone-by-date --dry-run
- 1119406 - make clone-by-date able to specify --parents from config file
- 1119405 - you should not have to specify both parent channels for clone-by-
  date
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.26-1
- Spacewalk 2.2 repos for spacewalk-common-channels
- fix copyright years

* Wed Jul 09 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.25-1
- CentOS 7 + EPEL 7 channels

* Mon Jun 23 2014 Tomas Lestach <tlestach@redhat.com> 2.2.24-1
- let spacewalk-utils require a specific version of spacewalk-backend-tools

* Fri Jun 20 2014 Tomas Lestach <tlestach@redhat.com> 2.2.23-1
- minor fixes to spacewalk-export-channels man page

* Thu Jun 19 2014 Grant Gainey 2.2.22-1
- Added man-pg for spacewalk-export-channels Minor cleanup of spacewalk-export
  man-pg
- manpage for spacewalk-export
- Some PEP8 suggestions
- Restored spacewalk-report channels to export

* Thu Jun 12 2014 Grant Gainey 2.2.21-1
- Add spacewalk-export-channels to Makefile too
- Calling sudo inside may be problematic

* Wed Jun 11 2014 Tomas Lestach <tlestach@redhat.com> 2.2.20-1
- 1108138 - detect repositories with inaccessible metadata

* Mon Jun 09 2014 Tomas Lestach <tlestach@redhat.com> 2.2.19-1
- 1105904 - do not check size of missing files

* Fri Jun 06 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.18-1
- fixed spacewalk-hostname-rename to work with postgresql backend

* Fri May 30 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.17-1
- 1101545 - Added limitation of spacewlak-clone-by-date for RHEL4 and earlier
- new report: spacewalk-export-channels

* Fri May 23 2014 Stephen Herr <sherr@redhat.com> 2.2.16-1
- Adding spacewalk-manage-channel-lifecycle to spacewalk-utils
- spacewalk-manage-channel-lifecycle: Removed the whitespace
- spacewalk-manage-channel-lifecycle: Added better channel tree printing.
- spacewalk-manage-channel-lifecycle: Added multiple workflows.
- spacewalk-manage-channel-lifecycle: Removed dead variable.
- spacewalk-manage-channel-lifecycle: Fixing None-channel. Added real checks
  instead of blind try/except.
- spacewalk-manage-channel-lifecycle: Organizing imports

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.15-1
- spec file polish

* Tue May 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.14-1
- Assume raw mode if the directory with definition files doesn't exist

* Thu May 01 2014 Stephen Herr <sherr@redhat.com> 2.2.13-1
- Fixes from PR discussion
- Add spacewalk-export to utils

* Mon Apr 14 2014 Stephen Herr <sherr@redhat.com> 2.2.12-1
- 1073543 - checkstyle fix

* Mon Apr 14 2014 Stephen Herr <sherr@redhat.com> 2.2.11-1
- 1073543 - sw-clone-by-date validation update

* Thu Apr 03 2014 Stephen Herr <sherr@redhat.com> 2.2.10-1
- 1073543 - fix problem where --channels=src_label dst_label threw an error

* Fri Mar 21 2014 Stephen Herr <sherr@redhat.com> 2.2.9-1
- 1073543 - make it possible to specify description from clone-be-date

* Tue Mar 11 2014 Stephen Herr <sherr@redhat.com> 2.2.8-1
- 1073632 - fixing possible nonetype error

* Tue Mar 11 2014 Tomas Lestach <tlestach@redhat.com> 2.2.7-1
- 1058154 - let spacewalk-api send username and password as strings

* Fri Mar 07 2014 Stephen Herr <sherr@redhat.com> 2.2.6-1
- 1073632 - another pylint error

* Fri Mar 07 2014 Stephen Herr <sherr@redhat.com> 2.2.5-1
- 1015963 - fixing long lines in clone-by-date

* Thu Mar 06 2014 Stephen Herr <sherr@redhat.com> 2.2.4-1
- 1073632 - add option to clone-by-date to only clone specified errata
- 1073543 - Allow user to specify channel name through clone-by-date

* Fri Feb 28 2014 Tomas Lestach <tlestach@redhat.com> 2.2.3-1
- 1028933 - allow spacewalk-api to force integer and string values
- 1028933 - allow spacewalk-api to use boolean values

* Tue Feb 25 2014 Stephen Herr <sherr@redhat.com> 2.2.2-1
- 1069879 - spacwalk-repo-sync prints the same message for every channel.

* Tue Feb 25 2014 Tomas Lestach <tlestach@redhat.com> 2.2.1-1
- removing spacewalk18 and spacewalk19 channel repo configurations
- remove fc18 channel repo configurations
- Bumping package versions for 2.2.

* Thu Jan 30 2014 Stephen Herr <sherr@redhat.com> 2.1.27-1
- 1059910 - create api for channel errata syncing, have clone-by-date call it

* Wed Jan 29 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.26-1
- adding postgresql92-postgresql to possible db service names

* Thu Jan 16 2014 Matej Kollar <mkollar@redhat.com> 2.1.25-1
- Changed gpg keys so they match reality.
- Removing unsupported Fedora 17
- Adding Fedora 20 to spacewalk-common-channels
- adding 2.1 repositories to spacewalk-common-channels
- remove openSUSE 12.2 and add openSUSE 13.1 channels

* Tue Jan 14 2014 Matej Kollar <mkollar@redhat.com> 2.1.24-1
- Updating the copyright years info

* Wed Jan 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.23-1
- fixed man page encoding

* Tue Nov 12 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.22-1
- Added Oracle Linux channels for UEKR3, as well as Spacewalk 2.0 Server/Client
  for OL6 and Client for OL5

* Wed Oct 09 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.21-1
- cleaning up old svn Ids

* Tue Oct 01 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.20-1
- fixed pylint warning

* Mon Sep 30 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.19-1
- removed trailing whitespaces

* Fri Sep 27 2013 Grant Gainey <ggainey@redhat.com> 2.1.18-1
- 1012963 - Don't use :table as a param-name in Oracle prepared stmts
- 1012934 - Oracle prepared-stmt cannot have semicolons

* Fri Sep 20 2013 Grant Gainey <ggainey@redhat.com> 2.1.17-1
- 1009657 - fixes spacewalk-hostname-rename issue when postgres and oracle are
  installed

* Thu Sep 12 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.16-1
- shortened default yum repo label

* Wed Sep 11 2013 Grant Gainey <ggainey@redhat.com> 2.1.15-1
- 984611 - Fixed a number of spacewalk-archive-audit bugs found by QE

* Tue Sep 10 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.14-1
- 1006305 - increase LongReadLen to 20M

* Mon Sep 09 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.13-1
- 966644 - update the sw-clone-by-date man page

* Fri Aug 30 2013 Tomas Lestach <tlestach@redhat.com> 2.1.12-1
- removing, to be implemented in spacecmd
- 1002232 - remove extraneous error-log invoke

* Fri Aug 23 2013 Tomas Lestach <tlestach@redhat.com> 2.1.11-1
- 993047 - ignore, if activation key already exists

* Thu Aug 22 2013 Grant Gainey <ggainey@redhat.com> 2.1.10-1
- 999583 - Fixes to allow scripts to work on older versions of Python and
  Postgres
- adding i386 nightly channels
- adding nightly repositories for fedora19
- removing unused DEFAULT_USER and DEFAULT_PASSWORD

* Tue Aug 20 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.9-1
- sw abrt manage tool

* Mon Aug 19 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.8-1
- removing a LOT of trailing whitespaces

* Thu Aug 08 2013 Grant Gainey <ggainey@redhat.com> 2.1.7-1
- Get new scripts added to spacewalk-utils RPM

* Thu Aug 08 2013 Jan Dobes 2.1.6-1
- 972626 - just call waiting function
- Change detault username and password.

* Tue Aug 06 2013 Jan Dobes 2.1.5-1
- 972626 - simplier and more readable solution

* Tue Aug 06 2013 Jan Dobes 2.1.4-1
- 972626 - multiple tries if db will not start quick enough

* Mon Aug 05 2013 Grant Gainey <ggainey@redhat.com> 2.1.3-1
- 993254 - Script to enable us to purge audit-log tables

* Wed Jul 31 2013 Tomas Kasparek <tkasparek@redhat.com> 2.1.2-1
- adding 2.0 repositories to spacewalk-common-channels

* Tue Jul 30 2013 Dimitar Yordanov <dyordano@redhat.com> 2.1.1-1
- New simple tool for managing custom repositories.
- Bumping package versions for 2.1.

