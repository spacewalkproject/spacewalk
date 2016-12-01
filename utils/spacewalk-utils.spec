%define rhnroot %{_prefix}/share/rhn
%if 0%{?fedora}
%{!?pylint_check: %global pylint_check 1}
%endif

Name:		spacewalk-utils
Version:	2.7.0
Release:	1%{?dist}
Summary:	Utilities that may be run against a Spacewalk server.

Group:		Applications/Internet
License:	GPLv2
URL:		https://fedorahosted.org/spacewalk
Source0:	https://fedorahosted.org/releases/s/p/spacewalk/%{name}-%{version}.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch

%if 0%{?pylint_check}
BuildRequires:  spacewalk-pylint >= 2.2
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
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/%{rhnroot}
make install PREFIX=$RPM_BUILD_ROOT ROOT=%{rhnroot} \
    MANDIR=%{_mandir} %{?pod2man}


%clean
rm -rf $RPM_BUILD_ROOT

%check
%if 0%{?pylint_check}
# check coding style
spacewalk-pylint $RPM_BUILD_ROOT%{rhnroot}
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

* Thu Jul 18 2013 Jiri Mikulka <jmikulka@redhat.com> 2.0.2-1
- dropping support for Fedora 17 in Spacewalk nightly

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 2.0.1-1
- Bumping package versions for 2.0.

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.19-1
- removing spacewalk18-client-fedora16 from spacewalk-common-channels
- removing spacewalk18-server-fedora16 from spacewalk-common-channels

* Wed Jul 17 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.18-1
- adding Fedora 19 to spacewalk-common-channel
- removing spacewalk-client-nightly-fedora16 from spacewalk-common-channels
- removing spacewalk-nightly on fedora16 from spacewalk-common-channels

* Tue Jul 16 2013 Grant Gainey <ggainey@redhat.com> 1.10.17-1
- 985136 - Clarify spacewalk-clone-by-date man page

* Tue Jul 09 2013 Grant Gainey <ggainey@redhat.com> 1.10.16-1
- 977878 - Set default-template-filenames for sync-setup

* Tue Jul 09 2013 Grant Gainey <ggainey@redhat.com> 1.10.15-1
- 977878 - Teach sync-setup about default-master and cacert

* Tue Jul 02 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.14-1
- oracle -> postgresql: properly quote commas in evr_t constructor
- oracle -> pg migrations: filter plan_table_9i out

* Mon Jul 01 2013 Grant Gainey <ggainey@redhat.com> 1.10.13-1
- 977878 - spacewalk-sync-setup: Fix create-template to do the right then when re-run, and make
  --dry-run work
- 977878 - spacewalk-sync-setup: Move sync_setup to somewhere package-able, rename and add license
  stmt
- oracle -> pg migrations: filter plan_table_9i out

* Mon Jun 17 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.12-1
- removed old CVS/SVN version ids
- branding fixes in man pages
- more branding cleanup

* Wed Jun 12 2013 Tomas Kasparek <tkasparek@redhat.com> 1.10.11-1
- rebrading RHN Satellite to Red Hat Satellite

* Wed May 22 2013 Tomas Lestach <tlestach@redhat.com> 1.10.10-1
- check to see if the key exists before initializing parent channel key

* Tue May 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.9-1
- fixed promote phase naming errors

* Thu May 09 2013 Milan Zazrivec <mzazrivec@redhat.com> 1.10.8-1
- correctly quote the database name

* Tue May 07 2013 Jan Pazdziora 1.10.7-1
- disable, enable & rebuild indexes for migrations

* Tue Apr 30 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.6-1
- EL4 is EOL'ed for a long time
- Fedora 16 is EOL'ed
- Spacewalk 1.7 is EOL'ed
- Added Oracle Linux 5 and 6 public channels

* Fri Apr 26 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.5-1
- 956684 - don't print traceback on invalid date

* Mon Apr 08 2013 Stephen Herr <sherr@redhat.com> 1.10.4-1
- 948605 - fixing pylint error

* Fri Apr 05 2013 Stephen Herr <sherr@redhat.com> 1.10.3-1
- 947942 - Updating spacewalk-clone-by-date config file parsing and man page
- 947942 - add spacewalk-clone-by-date --use-update-date

* Wed Mar 27 2013 Michael Mraka <michael.mraka@redhat.com> 1.10.2-1
- add openSUSE 12.3 to spacewalk-common-channels config

* Thu Mar 14 2013 Jan Pazdziora 1.10.1-1
- 920514 - correcting spacewalk-common-channels.ini

* Fri Mar 01 2013 Stephen Herr <sherr@redhat.com> 1.9.17-1
- adding Spacewalk 1.9 channels to spacewalk-common-channels.ini
- Purging %%changelog entries preceding Spacewalk 1.0, in active packages.

* Thu Feb 28 2013 Jan Pazdziora 1.9.16-1
- Removing the dsn parameter from initDB, removing support for --db option.

* Thu Feb 21 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.15-1
- fixed koji build

* Mon Feb 18 2013 Miroslav Suchý <msuchy@redhat.com> 1.9.14-1
- Buildrequire pod2man

* Wed Feb 13 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.13-1
- fixed pylint warnings

* Wed Feb 13 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.12-1
- removed Fedora 15 channels
- added Fedora 18 channel definitions

* Fri Jan 18 2013 Michael Mraka <michael.mraka@redhat.com> 1.9.11-1
- silence pylint warning

* Tue Jan 15 2013 Tomas Lestach <tlestach@redhat.com> 1.9.10-1
- 889317 - Removing now redundant validation check from spacewalk-clone-by-date
- 889317 - Add more thorough arg validation to spacewalk-clone-by-date
- 866930 - fixing exception if no date given and adding documentation
- 889317 - username check needs to happen after channel args length check
- Checkstyle fixes to make s390 buildhosts happy

* Mon Jan 07 2013 Stephen Herr <sherr@redhat.com> 1.9.9-1
- 892789 - add --parents option to spacewalk-clone-by-date

* Fri Dec 21 2012 Jan Pazdziora 1.9.8-1
- Silencing pylint warnings.

* Fri Dec 21 2012 Jan Pazdziora 1.9.7-1
- We cannot have except and finally in the same try block for python 2.4.

* Fri Dec 21 2012 Jan Pazdziora 1.9.6-1
- 889317 - fix short-sighted problem in previous patch
- 889317 - make sure the user passes two channels to spacewalk-clone-by-date
- Revert "889317 - migrate spacewalk-clone-by-date to argparse to avoid
  optparse bug"
- 889317 - migrate spacewalk-clone-by-date to argparse to avoid optparse bug
- 885782 - strip whitespace from spacewalk-clone-by-date conf file
- 870794 - don't create the clone channel if we're gonna error out due to lack
  of repodata

* Wed Dec 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.5-1
- 866930 - do not traceback when called without --to_date

* Wed Nov 21 2012 Michael Mraka <michael.mraka@redhat.com> 1.9.4-1
- updated according to modified distchannel API

* Sun Nov 11 2012 Michael Calmer <mc@suse.de> 1.9.3-1
- add openSUSE 12.2 to common channels

* Tue Nov 06 2012 Tomas Lestach <tlestach@redhat.com> 1.9.2-1
- spacewalk-setup-cobbler does not use --enable-tftp option

* Wed Oct 31 2012 Jan Pazdziora 1.9.1-1
- fixed spacing in man page

* Wed Oct 31 2012 Jan Pazdziora 1.8.33-1
- Advertise the yum.spacewalkproject.org.

* Tue Oct 30 2012 Jan Pazdziora 1.8.32-1
- Adding Spacewalk 1.8 to spacewalk-common-channels.
- Update the copyright year.

* Mon Oct 22 2012 Jan Pazdziora 1.8.31-1
- Add support for schema transformations.

* Mon Oct 22 2012 Jan Pazdziora 1.8.30-1
- 822907 - spacewalk-hostname-rename knows to start postgresql

* Wed Sep 26 2012 Jan Pazdziora 1.8.29-1
- 860467 - note about packages not having erratas.

* Fri Sep 07 2012 Jan Pazdziora 1.8.28-1
- Format the timestamps as well.

* Fri Aug 31 2012 Jan Pazdziora 1.8.27-1
- 853025 - make sure the regular expressions actually match.

* Wed Aug 22 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.26-1
- 812886 - the Enhancement Advisory is actually Product Enhancement Advisory.

* Fri Aug 10 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.25-1
- added channel definitions for Fedora17

* Thu Aug 09 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.24-1
- 817484 - fixed typo

* Mon Aug 06 2012 Tomas Lestach <tlestach@redhat.com> 1.8.23-1
- 843466 - prevent spacewalk-hostname-rename to fail with an IPv6 address

* Mon Aug 06 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.22-1
- 817484 - strip non-number chars from date format

* Fri Jul 06 2012 Stephen Herr <sherr@redhat.com> 1.8.21-1
- 838131 - spacewalk-clone-by-date can clone only security errata

* Thu Jun 14 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.20-1
- system.list_user_systems() now returns localtime

* Thu Jun 07 2012 Stephen Herr <sherr@redhat.com> 1.8.19-1
- 829485 - fixed type

* Thu Jun 07 2012 Stephen Herr <sherr@redhat.com> 1.8.18-1
- 829204 - updated man page for spacewalk-clone-by-date

* Wed Jun 06 2012 Stephen Herr <sherr@redhat.com> 1.8.17-1
- 829485 - Created new asyncronous api methods for cloning errata

* Wed May 23 2012 Stephen Herr <sherr@redhat.com> 1.8.16-1
- 824583 - spacewalk-clone-by-date failes with TypeError when on Postgres
  database.

* Mon May 21 2012 Jan Pazdziora 1.8.15-1
- Fix refsection build error.
- %%defattr is not needed since rpm 4.4

* Fri May 18 2012 Tomas Lestach <tlestach@redhat.com> 1.8.14-1
- use spacewalk-setup-cobbler instead of outdated cobbler-setup
- Revert "set localhost instead of hostname to tnsnames.ora and listener.ora"

* Wed May 16 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.13-1
- added version for scientific linux default channel mapping

* Thu May 10 2012 Jan Pazdziora 1.8.12-1
- The plan_table is not part of our schema, do not dump it.

* Fri May 04 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.11-1
- added dist_map_release for automatic OS->base channel mapping
- set dist release map via setDefaultMap
- removed fedora12/13/14 which are long time EOL

* Tue Apr 24 2012 Stephen Herr <sherr@redhat.com> 1.8.10-1
- 812810 - Better regex for getting system_id in apply_errata

* Mon Apr 23 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.9-1
- 812886 - determine the advisory type by parsing "advisory_type"

* Mon Apr 23 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.8-1
- 813281 - fix indetation

* Mon Apr 23 2012 Miroslav Suchý <msuchy@redhat.com> 1.8.7-1
- 813281 - implement -n for apply_errata

* Mon Apr 16 2012 Tomas Lestach <tlestach@redhat.com> 1.8.6-1
- 812812 - make generated SSL certificate publicly available
  (tlestach@redhat.com)

* Fri Apr 13 2012 Jan Pazdziora 1.8.5-1
- 810313 - new option to list snapshot details (mzazrivec@redhat.com)

* Thu Apr 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.4-1
- made new pylint on Fedora 16 happy

* Tue Apr 03 2012 Jan Pazdziora 1.8.3-1
- 809444 - support for psql syntax (mzazrivec@redhat.com)

* Sun Mar 18 2012 Aron Parsons <aronparsons@gmail.com> 1.8.2-1
- added spacewalk-manage-channel-lifecycle script (aronparsons@gmail.com)
- spacewalk-clone-by-date manpage bugfixes/cleanups (shardy@redhat.com)

* Mon Mar 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.8.1-1
- reused function from spacewalk.common.cli
- login(), logout() moved to spacewalk.common.cli
- use getUsernamePassword() from spacewalk.common.cli

* Fri Mar 02 2012 Jan Pazdziora 1.7.15-1
- We no longer build Spacewalk nightly on Fedora 14.
- Spacewalk 1.7 instead of 1.4 and 1.5.
- Update the copyright year info.

* Fri Feb 24 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.14-1
- fixed pylint errors
- use spacewalk-pylint for coding style check

* Thu Feb 23 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.13-1
- we are now just GPL

* Wed Feb 22 2012 Miroslav Suchý 1.7.12-1
- 788083 - IPv6 support in spacewalk-hostname-rename (mzazrivec@redhat.com)
- errata date clone - adding --skip-depsolve option, and fixing some man page
  errors (jsherril@redhat.com)
- errata date clone - fixing issue where repoclosure was not being passed all
  needed arguments (jsherril@redhat.com)
- errata date clone - fixing issue where raise was not called on an exception
  (jsherril@redhat.com)
- errata date clone - removing packages from remove list even if no errata are
  cloned (jsherril@redhat.com)
- errata date clone - better error message when repodata is missing
  (jsherril@redhat.com)
- errata date clone - man page fix, and catching if config file does not exist
  (jsherril@redhat.com)
- errata date clone - making regular expression syntax more apparent in docs
  (jsherril@redhat.com)
- errata date clone - pylint fixes (jsherril@redhat.com)
- errata date clone - do not dep solve if no packages were added
  (jsherril@redhat.com)
- errata date clone - adding ability to specify per-channel blacklists
  (jsherril@redhat.com)
- errata date clone - fixing issue where old metadata could be reused if the
  previous run did not complete (jsherril@redhat.com)
- errata date clone - improving user feedback in some cases
  (jsherril@redhat.com)
- errata date clone - adding regular expression support for package exclusion
  lists (jsherril@redhat.com)
- errata date clone - adding auth check to make sure that login is refreshed
  before session timeout (jsherril@redhat.com)
- errata date clone - changing meaning of blacklist to only remove packages
  based on delta, and adding removelist to remove packages based on full
  channel contents (jsherril@redhat.com)
- fixing some man page spelling errors (jsherril@redhat.com)

* Mon Feb 13 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.11-1
- fixed spacewalk-common-channel glob matching

* Mon Feb 13 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.10-1
- 591156 - fix for clone by date to use repodata dir for dep resolution

* Tue Feb 07 2012 Jan Pazdziora 1.7.9-1
- The COBBLER_SETTINGS_FILE is not used, we call cobbler-setup to do the work.
- errata date clone - fixing a few more issues with man page and adding a bit
  more user output (jsherril@redhat.com)
- errata date clone - another man page fix (jsherril@redhat.com)
- errata date clone - man page fix (jsherril@redhat.com)
- errata date clone - fixing man page formatting (jsherril@redhat.com)

* Thu Feb 02 2012 Justin Sherrill <jsherril@redhat.com> 1.7.8-1
- errata date clone - fixing imports (jsherril@redhat.com)

* Thu Feb 02 2012 Justin Sherrill <jsherril@redhat.com> 1.7.7-1
- errata date clone - fixing packaging to clone properly (jsherril@redhat.com)
- errata date clone - adding validate to man page (jsherril@redhat.com)

* Thu Feb 02 2012 Justin Sherrill <jsherril@redhat.com> 1.7.6-1
- errata date clone - fixing a few errors from pylint fixes
  (jsherril@redhat.com)

* Wed Feb 01 2012 Justin Sherrill <jsherril@redhat.com> 1.7.5-1
- pylint fixes (jsherril@redhat.com)

* Wed Feb 01 2012 Justin Sherrill <jsherril@redhat.com> 1.7.4-1
- adding initial spacewalk-clone-by-date (jsherril@redhat.com)

* Thu Jan 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.3-1
- removed map and filter from bad-function list

* Thu Jan 05 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.2-1
- pylint is required for coding style check

* Wed Jan 04 2012 Michael Mraka <michael.mraka@redhat.com> 1.7.1-1
- fixed coding style and pylint warnings
- added spacewalk-nightly-*-fedora16 definitions

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.6-1
- Channel definitions for Spacewalk 1.6

* Wed Dec 21 2011 Milan Zazrivec <mzazrivec@redhat.com> 1.6.5-1
- update copyright info

* Wed Nov 23 2011 Jan Pazdziora 1.6.4-1
- Prevent Malformed UTF-8 character error upon dump.

* Fri Sep 09 2011 Michael Mraka <michael.mraka@redhat.com> 1.6.3-1
- updated spacewalk repos
- added scientific linux 6 repo
- added epel6 repos

* Thu Aug 11 2011 Miroslav Suchý 1.6.2-1
- do not mask original error by raise in execption

* Thu Jul 21 2011 Jan Pazdziora 1.6.1-1
- Adding centos6 and fedora15 repos. (jonathan.hoser@helmholtz-muenchen.de)

* Wed Jul 13 2011 Jan Pazdziora 1.5.4-1
- We get either undefined value or BLOB for the blob columns type.

* Fri May 20 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.3-1
- fix broken (non-utf8) changelog entries

* Fri Apr 29 2011 Michael Mraka <michael.mraka@redhat.com> 1.5.2-1
- fixed base channel for spacewalk on F14
- added spacewalk nightly entries
- added spacewalk 1.4 entries

* Mon Apr 18 2011 Jan Pazdziora 1.5.1-1
- fix pattern bash matching (mzazrivec@redhat.com)

* Thu Mar 24 2011 Jan Pazdziora 1.4.3-1
- In spacewalk-dump-schema, use the default Oracle connect information from
  config file.

* Thu Mar 10 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.2-1
- made spacewalk-hostname-rename working on postgresql


* Thu Feb 03 2011 Michael Mraka <michael.mraka@redhat.com> 1.4.1-1
- updated spacewalk-common-channel to spacewalk 1.3
- Bumping package versions for 1.4

* Tue Jan 04 2011 Michael Mraka <michael.mraka@redhat.com> 1.3.4-1
- fixed pylint errors

* Tue Dec 14 2010 Jan Pazdziora 1.3.3-1
- We need to check the return value of GetOptions and die if the parameters
  were not correct.

* Tue Nov 23 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.2-1
- fixed pylint errors
- added spacewalk 1.2 channels and repos

* Fri Nov 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.3.1-1
- re-added automatic external yum repo creation based on new API
- Bumping package versions for 1.3

* Fri Nov 05 2010 Miroslav Suchý <msuchy@redhat.com> 1.2.9-1
- 491331 - move /etc/sysconfig/rhn-satellite-prep to /var/lib/rhn/rhn-
  satellite-prep (msuchy@redhat.com)

* Mon Nov 01 2010 Jan Pazdziora 1.2.8-1
- As the table rhnPaidErrataTempCache is no more, we do not need to have check
  for temporary tables.

* Fri Oct 29 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.7-1
- fixed spacewalk-common-channels
- updated spacewalk-common-channels to Spacewalk 1.1 and Fedora 13 and 14

* Tue Oct 26 2010 Jan Pazdziora 1.2.6-1
- Blobs (byteas) want double backslashes and octal values.

* Thu Oct 21 2010 Jan Pazdziora 1.2.5-1
- Adding spacewalk-dump-schema to the Makefile to be added to the rpm.
- Documentation (man page).
- For blobs, quote everything; for varchars, do not quote the UTF-8 characters.
- Export in UTF-8.
- To process the evr type, we need to handle the ARRAY ref.
- Skip the quartz tables, they get regenerated anyway.
- Escape characters that we need to escape.
- Use the ISO format for date.
- Dump records.
- No commit command, we run psql in autocommit.
- Fail if we try to dump lob longer than 10 MB.
- Do not dump copy commands for tables that are empty.
- For each table, print the copy command.
- Do not attempt to copy over temporary tables or we get error about
  rhnpaiderratatempcache.
- Initial table processing -- just purge for now.
- Stop on errors.
- Dump sequences.
- Process arguments and connect.
- Original stub of the schema dumper.

* Tue Oct 19 2010 Jan Pazdziora 1.2.4-1
- As Oracle XE is no longer managed by rhn-satellite, we need to change the
  logic in spacewalk-hostname-rename a bit as well.

* Tue Oct 05 2010 Tomas Lestach <tlestach@redhat.com> 1.2.3-1
- 639818 - fixing sys path (tlestach@redhat.com)

* Mon Oct 04 2010 Michael Mraka <michael.mraka@redhat.com> 1.2.2-1
- replaced local copy of compile.py with standard compileall module

* Thu Sep 09 2010 Tomas Lestach <tlestach@redhat.com> 1.2.1-1
- 599030 - check whether SSL certificate generation was successful
  (tlestach@redhat.com)
- use hostname as default value for organization unit (tlestach@redhat.com)
- enable also VPN IP (tlestach@redhat.com)
- bumping package versions for 1.2 (mzazrivec@redhat.com)

* Mon May 17 2010 Tomas Lestach <tlestach@redhat.com> 1.1.5-1
- changing package description (tlestach@redhat.com)
- do not check /etc/hosts file for actual hostname (tlestach@redhat.com)
- check for presence of bootstrap files before modifying them
  (tlestach@redhat.com)
- fixed typo (tlestach@redhat.com)
- set localhost instead of hostname to tnsnames.ora and listener.ora
  (tlestach@redhat.com)
- fixed a typo in the man page (tlestach@redhat.com)

* Tue Apr 27 2010 Tomas Lestach <tlestach@redhat.com> 1.1.4-1
- fixed Requires (tlestach@redhat.com)
- spacewalk-hostname-rename code cleanup (tlestach@redhat.com)

* Thu Apr 22 2010 Tomas Lestach <tlestach@redhat.com> 1.1.3-1
- adding requires to utils/spacewalk-utils.spec (tlestach@redhat.com)

* Wed Apr 21 2010 Tomas Lestach <tlestach@redhat.com> 1.1.2-1
- changes to spacewalk-hostname-rename script (tlestach@redhat.com)
- introducing spacewalk-hostname-rename.sh script (tlestach@redhat.com)

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

