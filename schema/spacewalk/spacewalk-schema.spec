Name:           spacewalk-schema
Group:          Applications/Internet
Summary:        Oracle SQL schema for Spacewalk server

Version:        1.1.13
Release:        1%{?dist}
Source0:        %{name}-%{version}.tar.gz

License:        GPLv2
Url:            http://fedorahosted.org/spacewalk/
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  chameleon

Obsoletes:      rhn-satellite-schema <= 5.1.0


%define rhnroot /etc/sysconfig/rhn/
%define oracle %{rhnroot}/oracle
%define postgres %{rhnroot}/postgres

%description
rhn-satellite-schema is the Oracle SQL schema for the Spacewalk server.
Oracle tablespace name conversions have NOT been applied.

%prep

%setup -q

%build
make -f Makefile.schema SCHEMA=%{name} VERSION=%{version} RELEASE=%{release}
pod2man spacewalk-schema-upgrade spacewalk-schema-upgrade.1

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0755 -d $RPM_BUILD_ROOT%{oracle}
install -m 0755 -d $RPM_BUILD_ROOT%{postgres}
install -m 0644 oracle/main.sql $RPM_BUILD_ROOT%{oracle}
install -m 0644 postgres/main.sql $RPM_BUILD_ROOT%{postgres}
install -m 0755 -d $RPM_BUILD_ROOT%{_bindir}
install -m 0755 %{name}-upgrade $RPM_BUILD_ROOT%{_bindir}
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}/schema-upgrade
cp -r upgrade/* $RPM_BUILD_ROOT%{rhnroot}/schema-upgrade
mkdir -p $RPM_BUILD_ROOT%{_mandir}/man1
cp -p spacewalk-schema-upgrade.1 $RPM_BUILD_ROOT%{_mandir}/man1

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{oracle}
%{postgres}
%{rhnroot}/schema-upgrade
%{_bindir}/%{name}-upgrade
%{_mandir}/man1/spacewalk-schema-upgrade*

%changelog
* Fri Jul 09 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.13-1
- fixed schema dependencies
* Thu Jul 08 2010 Justin Sherrill <jsherril@redhat.com> 1.1.12-1
- adding upgrade script for rhnAvailableChannels performance issue
  (jsherril@redhat.com)
- 603240 - fixing performance issue with rhnAvailableChannels, since one half
  of the query looks for channels the org owns, and the other half looks for
  channels shared to the org, changing to union all should be no problem
  (jsherril@redhat.com)
- Fixed a stored proc to only look at flex stuff (paji@redhat.com)

* Thu Jul 08 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.11-1
- fixed dependencies on rhnServerFveCapable and rhnChecksumView
- let schema population fail if there are invalid objects
- Made entitlement logic handle flex guests when the host is virt (un)entitled

* Wed Jul 07 2010 Justin Sherrill <jsherril@redhat.com> 1.1.10-1
- allowing satellite-sync to juggle entitlements between flex guest and regular
  entitlement slots if it can (jsherril@redhat.com)

* Fri Jul 02 2010 Jan Pazdziora 1.1.9-1
- bug fixes to repo sync schema upgrades and sql (shughes@redhat.com)
- 526864 - don't allow duplicated rows in rhnServerPackage
  (michael.mraka@redhat.com)
- Triggers that call something in rhn_email package (schema) are not useful
  because we do not have rhn_email.

* Fri Jul 02 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.8-1
- fix index creation and duplicite name of index (msuchy@redhat.com)
- would be much better if it fails with error when something bad happens
  (michael.mraka@redhat.com)

* Fri Jul 02 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.7-1
- table rhnChannelContentSource depends on rhnContentSource (msuchy@redhat.com)
- Match the types of parameters of create_new_user to those given to us by the
  Java code. (jpazdziora@redhat.com)

* Thu Jul 01 2010 Miroslav Suchý <msuchy@redhat.com> 1.1.6-1
- syntax error on rhnContentSource table sql (shughes@redhat.com)
- modify last_synced column for repo sync (shughes@redhat.com)
- missing semicolon on sql declare block (shughes@redhat.com)
- making links between repo objects and taskomatic (shughes@redhat.com)
- migrate sync date from repo content source to the channel table
  (shughes@redhat.com)
- modified repo schema to handle org_id for content source objects. migrate
  script updated too. (shughes@redhat.com)
- adding extra column to the rhnTaskQueue to allow tracking of many2many
  objects IDs (shughes@redhat.com)
- upgrade script for migrating channels from repo table to the new mapping
  table, rhnChannelContentSource (shughes@redhat.com)
- initial table for mapping channel ids to content sources (yum repos)
  (shughes@redhat.com)
- renaming to contentsource since we are moving channel out to a new mapping
  table named rhnChannelContentSource (shughes@redhat.com)
- Fixed a goofed up merge for rhn_channel.pkb (paji@redhat.com)
- Updated the position of rhnPackageRepodata.sql to avoid conflict in naming
  (paji@redhat.com)
- added rhn channels and rhn_entitlements schema upgrade items
  (paji@redhat.com)
- Consolidate virtual instance type changes to 1 file (paji@redhat.com)
- Added code to get multiorgs org -> software channel ents page work with flex
  entitlements (paji@redhat.com)
- Added the convert to flex plsql operation (paji@redhat.com)
- Wiped out unused bulk procs (paji@redhat.com)
- Removed unused stored procedures (paji@redhat.com)
- Added an rhnException data (paji@redhat.com)
- Added channel family permissions to upgrade (paji@redhat.com)
- adding flex guest detection at registration time (jsherril@redhat.com)
- Commiting the initial compilable merge of rhn_channel (paji@redhat.com)
- Added rhnChannelFamilyServerFve in the hopes that it'll get used
  (paji@redhat.com)
- updating rhn_entitlement package for cert activation (jsherril@redhat.com)
- convertin rhn_entitlements.pkb to use four spaces instead of tabs
  (jsherril@redhat.com)
- Updated some views using hosted changes (paji@redhat.com)
- few fixes for rhn cert activation, cert activation now works and populates
  max_members correctly, but not populating fve_max_members yet
  (jsherril@redhat.com)
- matching hosteds column names for flex guests (jsherril@redhat.com)
- first attempt at adding flex guest to sat cert processing
  (jsherril@redhat.com)
- adding flex guest table changes (jsherril@redhat.com)

* Mon Jun 28 2010 Jan Pazdziora 1.1.5-1
- As the tables rhnChannelFamilyLicense and rhnChannelFamilyLicenseConsent were
  removed, so should the triggers.
- Replace nvl and nvl2 with coalesce, to make the rhnServerNeededView view
  compatible with PostgreSQL.
- Revert "Revert "Fix numeric/smallint incompatible types in PostgreSQL.""

* Mon Jun 28 2010 Jan Pazdziora 1.1.4-1
- The for does not like NULL which we get for empty ents_to_process.
- Array concatenation seems to want array_append.
- Fix cursors in PostgreSQL version of prune_group.
- Use AS with column alias.
- TOP declaration seems to be needed, for Makefile to be useful at all.

* Mon Jun 21 2010 Jan Pazdziora 1.1.3-1
- updating rhnPackageRepodata table to not use a reserved word.
  (jsherril@redhat.com)
- Good Bye rhnChannelFamilyLicense and rhnChannelFamilyLicenseConsent tables
  schemas (paji@redhat.com)
- Removed the bulk-subscribe and unsubscribe which is not used anywhere
  (paji@redhat.com)

* Mon May 31 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.2-1
- none of rhnDumpSnapshot* exists anymore
- 585965 - adding upgrade schema for bug
- 585965 - fixing issue with multilib packages and errata-cache generation
- Fix ORA-02429 error during schema upgrade

* Mon Apr 19 2010 Michael Mraka <michael.mraka@redhat.com> 1.1.1-1
- bumping spec files to 1.1 packages

* Wed Apr 14 2010 Justin Sherrill <jsherril@redhat.com> 0.9.8-1
- moving rhn_schedule_days to be db depedent because it has an inner select
  clause (jsherril@redhat.com)
- 516772 - removing fedora version specific kickstart install types since we do
  not use them (jsherril@redhat.com)

* Tue Apr 13 2010 Jan Pazdziora 0.9.5-1
- Fix Makefile to workaround chameleon failing.

* Mon Apr 12 2010 Miroslav Suchý <msuchy@redhat.com> 0.9.4-1
- Fix db schema for debian support (ukas.durfina@gmail.com)
- Retrieve the rhn_schedules(recid) instead of using the hardcoded value of 1 (jpazdziora@redhat.com)
- schema upgrade for Spacewalk and Fedora gpg keys (michael.mraka@redhat.com)
- 561553 - added Spacewalk into package providers
- drop this useless index (michael.mraka@redhat.com)
- 563902 - tuned sql upgrade script (michael.mraka@redhat.com)

* Thu Mar 11 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.3-1
- fixed misplaced column in index

* Tue Mar 09 2010 Michael Mraka <michael.mraka@redhat.com> 0.9.2-1
- 568293 - don't allow duplicated rows in rhnChecksum
- added constraints to rhnReleaseChannelMap
- repo generation changes, precomputing package repodata

* Thu Feb 18 2010 Miroslav Suchý <msuchy@redhat.com> 0.9.1-1
- support for Debian (lukas.durfina@gmail.com)

* Thu Feb 04 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.9-1
- call update_family_counts() only once in prune_family()

* Wed Feb 03 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.7-1
- fixed upgrades 0.7 -> 0.8

* Mon Feb 01 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.6-1
- 559447 - added upgrade scripts

* Fri Jan 29 2010 Miroslav Suchý <msuchy@redhat.com> 0.8.5-1
- 559447 - speed up rhn-satelite-activate (michael.mraka@redhat.com)
- 559447 - removed update_family_counts() from clear_subscriptions() (michael.mraka@redhat.com)

* Fri Jan 15 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.4-1
- added upgrade script for rhnChannel.checksum_type_id

* Thu Jan 14 2010 Michael Mraka <michael.mraka@redhat.com> 0.8.3-1
- dropped dead tables

* Mon Dec 07 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.2-1
- fixed sha256 related data upgrade scripts

* Fri Dec 04 2009 Michael Mraka <michael.mraka@redhat.com> 0.8.1-1
- SHA256 feature related changes

* Mon Nov 30 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.7.7-1
- schema upgrade fixes for Spacewalk 0.7

* Thu Nov 19 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.6-1
- replaced cursors + for loops with already written bulk procedure
- removed cartesian join
- 532683 - removed unnecessary table joins
- fixed schema upgrades
- optimized queries in update_perms_for_server
- 532683 - optimized delete

* Thu Oct 22 2009 Miroslav Suchy <msuchy@redhat.com> 0.7.5-1
- 449167 - record installation date of rpm package

* Tue Oct 20 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.4-1
- 449167 - record rpm installation date
- 522526 - fixing issue where snippets couldnt be used in the partitioning section of the kickstart wizard (jsherril@redhat.com)
- 522526 - adding schema upgrade script for snippet issue (jsherril@redhat.com)
- Don't indent sql upgrade code in resulting script (mzazrivec@redhat.com)
- 523389 - can't add NOT NULL column into non-empty table (michael.mraka@redhat.com)
- 523389 - decrease TEMP usage (michael.mraka@redhat.com)
- 523389 - add support for schema upgrade overrides (mzazrivec@redhat.com)

* Thu Sep 17 2009 Miroslav Suchý <msuchy@redhat.com> 0.7.3-1
- 523389 - split update into smaller chunks so it will not eat all UNDO at once
- 476851 - removal of tables: rhn_db_environment, rhn_environment (upgrade)
- 476851 - remove environment colum which refers to deleted rhn_enviroment table
- 476851 - removal of tables: rhn_db_environment, rhn_environment

* Wed Sep 02 2009 Michael Mraka <michael.mraka@redhat.com> 0.7.2-1
- Add symlink capability to config management (joshua.roys@gtri.gatech.edu)
- 517867 - insert solaris data only if these do not exist

* Thu Aug 13 2009 Devan Goodwin <dgoodwin@redhat.com> 0.7.1-1
- bumping Version to 0.7.0 (jmatthew@redhat.com)
- Removing PostgreSQL rhnFAQ trigger, table no longer exists.
  (dgoodwin@redhat.com)
- Fix numeric/smallint incompatible types in PostgreSQL. (dgoodwin@redhat.com)
- adding upgrade for new fedora gpg key (jsherril@redhat.com)
- adding newest fedora gpg key, and moving _data sql file to the right place
  (jsherril@redhat.com)

* Thu Aug 06 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.6.21-1
- remove symlinks from schema upgrades
- consistent data in new & upgraded schema
- create or replace function needs to be followed by execute
- remove extraneous execute after create index

* Wed Aug 05 2009 John Matthews <jmatthew@redhat.com> 0.6.20-1
- bugfix patch on selinux config file deploy (joshua.roys@gtri.gatech.edu)
- use new path to merged schema file (mzazrivec@redhat.com)
- fixing schema errors for build (jsherril@redhat.com)

* Wed Aug 05 2009 Jan Pazdziora 0.6.19-1
- updating repo-sync schema to better conform with new schema standards, also
  adding deps (jsherril@redhat.com)
- being cautious (pkilambi@redhat.com)
- Fixing the upgrades to default to sha1 for already existing channels
  (pkilambi@redhat.com)
- fixing small typo in upgrade script names (jsherril@redhat.com)
- Merge branch 'master' into repo-sync (jsherril@redhat.com)
- upgrade script for the previous commit. Patch from Joshua Roys
  (joshua.roys@gtri.gatech.edu)
- Patch: Selinux Context support for config files (joshua.roys@gtri.gatech.edu)
- moving three new tables for postgres merge (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- Re-order Oracle upgrade script. (dgoodwin@redhat.com)
- adding label to ContentSource schema (jsherril@redhat.com)
- merge conflict (jsherril@redhat.com)
- initial yum repo sync schema and UI work (jsherril@redhat.com)

* Wed Jul 29 2009 John Matthews <jmatthew@redhat.com> 0.6.18-1
- Add upgrade scripts for PostgreSQL compat procedures. (dgoodwin@redhat.com)

* Tue Jul 28 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.17-1
- Fix rhnVersionInfo information (jortel@redhat.com)
- Restore some Oracle/PostgreSQL compatability functions.
  (dgoodwin@redhat.com)

* Mon Jul 27 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.16-1
- Add support for PostgreSQL schema. (jortel@redhat.com)
- Build both database versions from common schema. (jortel@redhat.com)
- Add spacewalk-schema BuildRequires for chameleon. (dgoodwin@redhat.com)

* Mon Jul 27 2009 John Matthews <jmatthew@redhat.com> 0.6.15-1
- fixing descritpion on checksums (pkilambi@redhat.com)
-  Sha256 support for channel creation: (pkilambi@redhat.com)

* Wed Jul 22 2009 John Matthews <jmatthew@redhat.com> 0.6.14-1
- 512814 - tickle the upgrade logic (mmccune@redhat.com)

* Thu Jul 16 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.13-1
- 512104 - add sshbannerignore parametr to existing probes which use ssh

* Mon Jul 06 2009 John Matthews <jmatthew@redhat.com> 0.6.12-1
- 509029 - schema/upgrade - update the text used for action type =
  kickstart_guest.initiate (bbuckingham@redhat.com)

* Thu Jun 25 2009 John Matthews <jmatthew@redhat.com> 0.6.11-1
- rebuild 

* Thu Jun 25 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.6.10-1
- 506272 - insert sub4v rows only if they do not exist
- 431673 - reworking rhnServerNeededView for performance fixes.
  (mmccune@gmail.com)
- 492588 - Provide for shared child channels with non-shared parent channels
  (jortel@redhat.com)

* Fri Jun 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.9-1
- 503243 - Dropping the is_default column as we now determine the default in
  the app code based on the compatible eus channel instead of jus the default.
  (pkilambi@redhat.com)
- no need to add whitespace to upgrade script (mzazrivec@redhat.com)
- monitoring log files belong to /var/log/nocpulse (mzazrivec@redhat.com)
- 502641 - renaming upgrade script to 119-rhnSystemMigrations.sql
  (bbuckingham@redhat.com)
- 502641 - rhnSystemMigrations remove not null constraints from to/from org ids
  (bbuckingham@redhat.com)
- 498467 - A few changes related to the channel name limit increase.
  (jason.dobies@redhat.com)

* Tue May 26 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.8-1
- 501389 - splitting up virt types none and kvm guests, as well as improving
  virt type names (jsherril@redhat.com)

* Mon May 25 2009 Miroslav Suchy <msuchy@redhat.com> 0.6.7-1
- 502476 - rhn_sat_node should have uniq constraint on column server_id

* Mon May 18 2009 Jan Pazdziora 0.6.6-1
- spacewalk-schema-upgrade: add support for reference files
- 498467 - Forgot to update the create scripts with the new column length
  (jason.dobies@redhat.com)
- Merge branch 'bugs' (jason.dobies@redhat.com)
- 498467 - Increased size of channel name column (jason.dobies@redhat.com)

* Wed May 06 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.5-1
- 499046 - making it so that pre/post scripts can be templatized or not,
  defaulting to not (jsherril@redhat.com)
- alter index needs to be run via execute immediate (mzazrivec@redhat.com)
- 461704 - clean time_series when deleting a server (upgrade script)
  (mzazrivec@redhat.com)
- 461704 - clear time_series when deleting server (mzazrivec@redhat.com)
- 496174 - upgrade to view (mmccune@gmail.com)
- 496174 - view optimization. (mmccune@gmail.com)

* Fri Apr 24 2009 Jan Pazdziora 0.6.4-1
- 497477 - add function based index on time_series for faster probe_id lookups,
  use hint in delete to use it

* Wed Apr 22 2009 jesus m. rodriguez <jesusr@redhat.com> 0.6.3-1
- 494976 - adding cobbler systme record name usage to reprovisioning (jsherril@redhat.com)

* Tue Apr 21 2009 Jan Pazdziora 0.6.2-1
- spacewalk-schema-upgrade: other stability and code cleanup changes
- 495869 - label the /var/log/spacewalk/schema-upgrade based on the SELinux
  policy
- set noparallel if index rhn_snc_speid_idx exists (mzazrivec@redhat.com)
- spacewalk-schema-upgrade: for upgrades from Satellite 5.3.0 up, the starting
  schema name is satellite-schema
- 487319 - restore text input for SNMP Community String field
  (mzazrivec@redhat.com)
- 487319 - text input for "SNMP Community String" field (mzazrivec@redhat.com)

* Wed Apr 15 2009 Devan Goodwin <dgoodwin@redhat.com> 0.6.1-1
- 495133 - fixing errata mailer such that mails are only sent for a particular
  channel that was changed (jsherril@redhat.com)
- fix ORA-00955 when creating RHN_SNC_SPEID_IDX (mzazrivec@redhat.com)
- 149695 - Including channel_id as part of rhnErrataQueue table so that
  taskomatic can send errata notifications based on channel_id instead of
  sending to everyone subscribed to the channel. The changes include db change
  to rhnErrataQueue table and backend change to satellite-sync's errata import.
  (pkilambi@redhat.com)
- 485870 - only recalculate the channel family counts once per family.
  (mmccune@gmail.com)
- 494475,460136 - remove faq & feedback code which used customerservice emails.
  (jesusr@redhat.com)
- fixing some index mixups, nologging was left off the base schema for a few
  indexes for 0.5 (jsherril@redhat.com)
- 480060 - schema changes to support errata list enhancements.  Simple
  (mmccune@gmail.com)
- bump Versions to 0.6.0 (jesusr@redhat.com)
- adding missing index for errata cache\ (jsherril@redhat.com)

* Wed Mar 25 2009 Mike McCune <mmccune@gmail.com> 0.5.20-1
-  472595 - forgot the index in the table definition.  was in the upgrade area only

* Thu Mar 19 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.19-1
- 487316 - disallows multiple eus channels to be considered the most recent
- 472595 - fixes for kickstart performance, start porting ks downloads to java
- update rhnUserInfo page_size to 25

* Wed Mar 11 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.17-1
- fix typo in index name (upgrade script)
- add sql upgrade part for 466035

* Tue Mar 10 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.15-1
- add missing ';' when creating web_user_site_info_wuid

* Mon Mar  9 2009 Milan Zazrivec <mzazrivec@redhat.com> 0.5.14-1
- fix upgrade script dropping parallel query

* Mon Mar 09 2009 Michael Mraka <michael.mraka@redhat.com> 0.5.13-1
- fixed #489319

* Thu Mar 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.12-1
- fixing upgrade script to properly update all dependant tables
- Fix bug 474597, schema updated but upgrade script not included.

* Thu Feb 26 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.11-1
- fix comment to avoid confusion with / symbol

* Thu Feb 19 2009 Devan Goodwin <dgoodwin@redhat.com> 0.5.10-1
- 486254 - Fix broken schema population during spacewalk-setup.

* Wed Feb 18 2009 Pradeep Kilambi 0.5.9-1
- minor typo and dep fixes for rhnRepoRegenQueue table 

* Mon Feb 16 2009 Pradeep Kilambi 0.5.8-1
- rhnRepoRegenQueue table for yum repodata regen queue

* Thu Feb 12 2009 Mike McCune <mmccune@gmail.com> 0.5.7-1
- 484312 - massive cleanup of virt types.  getting rid of useless AUTO type.

* Thu Feb 12 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.6-1
- 484964 - increasing the copyright column size

* Thu Feb 12 2009 Miroslav Suchý <msuchy@redhat.com> 0.5.5-1
- move logs from /var/tmp to /var/log/nocpulse

* Wed Feb 11 2009 Milan Zazrivec 0.5.4-1
- fixed multiorg sql upgrade script

* Thu Feb 05 2009 jesus m. rodriguez <jesusr@redhat.com> 0.5.3-1
- 443718 - fixing a view mistage and having a query just use the view
- 443718 - improving errata cache calcs when pushing a single errata
- 481671 - rewrote inner query to improve performance.
- 480671 fix for deleting orgs in multiorg env
- fixing some forgotten indexes
- a few schema fixes and test case fixes related to the errata-cache update
- fixing a few test cases
- renaming upgrade script
- upgrade support for multiorg sharing logic
- validate channel is 'protected' when joining to the rhnChannelTrusts table.

* Fri Jan 23 2009 Jan Pazdziora 0.5.2-1
- fix for ORA-01440 error occurring when updating populated table (Michael M.)
- removed s/%{?dist}// substitution with no effect (Milan Z.)
- spacewalk-schema-upgrade: minor cleanup
- spacewalk-schema-upgrade: add support for schema overrides

* Wed Jan 14 2009 Mike McCune <mmccune@gmail.com> 0.4.17-1
- 461162 - correcting to match upgrade scripts

* Wed Jan 14 2009 Milan Zazrivec 0.4.16-1
- fixes for #479950 - spacewalk 0.4: new and upgraded schemas do not match

* Tue Jan 13 2009 Miroslav Suchý <msuchy@redhat.com> 0.4.15-1
- 479837 - Support rpm, which contains files with filename + path longer than 256 chars

* Tue Jan 13 2009 Milan Zazrivec 0.4.13-1
- 461162 - cleanup dead code in systemmanager and add new distro types
- 461162 - more virt-type fixing
- 461162 - get the virtualization provisioning tracking system to work with a :virt system record
- 476730 - increase advisory column to 37

* Wed Jan  7 2009 Milan Zazrivec 0.4.12-1
- added spacewalk-schema-upgrade manual page (bz #479003)
- renamed two sql upgrade scripts to use uniform extension

* Thu Dec 18 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.4.11-1
- fixed duplicate modification of rhnChannel

* Thu Dec 18 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.10-1
- 476644 - fixed rhn_org.delete_user

* Mon Dec 15 2008 Jan Pazdziora 0.4.9-1
- 461162 - adding virt options for cobbler
- 461162 - add type 'auto' virtualization
- remove vmware choice from vm type list
- drop also unique index associated with constraint
- updated the alter script numbers to have things go sequential
- 456532 - initial changes to stored profiles to support multiarch
- initial commit for stored profiles to support multiarch
- fixed upgrade script to upgrade the constraint as well
- added new rhnSet column to clean SQL create scripts
- added upgrade scripts to add necessary column to rhnSet
- updates to rhnRegTokenPackages to include id as primary key as well as sequence for generating ids
- making the arch_id column nullable
- updating rhnRegTokenPackages to include arch_id column
- 461162 - initial commit of the manager layer for cobbler
- changes by multiple authors

* Fri Dec  5 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.8-1
- fix monitoring paths in schema

* Mon Dec  1 2008 Miroslav Suchý <msuchy@redhat.com> 0.4.6-1
- 472910 - fix paths to nofitication configs

* Thu Nov 27 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.5-1
- 473242 - fix paths for alert_queue and ack_queue

* Wed Nov 26 2008 Miroslav Suchy <msuchy@redhat.com> 0.4.4-1
- 473097 - point monitoring paths to new destination

* Fri Nov 21 2008 Michael Mraka <michael.mraka@redhat.com> 0.4.3-1
- resolved #471199 - performance improvement of delete_server

* Fri Oct 31 2008 Miroslav Suchy <msuchy@redhat.com> 0.3.5-1
- 469244 - remove trailing /

* Thu Oct 23 2008 Jan Pazdziora 0.3.4-1
- release containing multiple contributions:
- removed rhn_clean_current_state, is_user_org_admin
- moved /opt dir to proper location
- removed unused $Id$, $id$, and $Log$ in the schema
- removed unused macros from table SQL
- rhn_channel_cloned_comps_trig depends on rhnChannelComps
- changed mode of spacewalk-schema-upgrade
- spacewalk-schema-upgrade: require confirming Enter
- 468016 - remove orphaned rhn_contact_groups in rhn_org.delete_user

* Tue Sep 23 2008 Milan Zazrivec 0.3.3-1
- fixed package obsoletes

* Thu Sep 18 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.2-1
- Fix bug with bad /var/log/rhn/ permissions.

* Thu Sep 18 2008 Michael Mraka <michael.mraka@redhat.com> 0.2.5-1
- Added upgrade scripts

* Wed Sep 17 2008 Devan Goodwin <dgoodwin@redhat.com> 0.3.1-1
- Bumping version to 0.3.x.

* Wed Sep 10 2008 Milan Zazrivec 0.2.3-1
- fixed package obsoletes

* Tue Sep  2 2008 Devan Goodwin <dgoodwin@redhat.com> 0.2.2-1
- Adding new kickstart profile options.

* Mon Sep  1 2008 Milan Zazrivec <mzazrivec@redhat.com> 0.2.1-1
- bumping version for spacewalk 0.2

* Tue Aug  5 2008 Michael Mraka <michael.mraka@redhat.com> 0.1.0-2
- renamed from rhn-satellite-schema and changed version

* Mon Jun  9 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-2
- fixed build issue

* Tue Jun  3 2008 Michael Mraka <michael.mraka@redhat.com> 5.2.0-1
- purged unused code
- rebuilt via brew / dist-cvs

