%{!?fedora: %global sbinpath /sbin}%{?fedora: %global sbinpath %{_sbindir}}

Name:           spacewalk-schema
Summary:        SQL schema for Spacewalk server

Version:        2.8.22
Release:        1%{?dist}
Source0:        %{name}-%{version}.tar.gz

License:        GPLv2
Url:            https://github.com/spacewalkproject/spacewalk/
BuildArch:      noarch

BuildRequires:  perl(Digest::SHA)
BuildRequires:  python
BuildRequires:  /usr/bin/pod2man
Requires:       %{sbinpath}/restorecon
Obsoletes:      rhn-satellite-schema <= 5.1.0

%if 0%{?suse_version}
BuildRequires:  fdupes
%endif

%define rhnroot /etc/sysconfig/rhn/
%define oracle %{rhnroot}/oracle
%define postgres %{rhnroot}/postgres

%description
spacewalk-schema is the SQL schema for the Spacewalk server.

%package sanity
Summary:  Schema source sanity check for Spacewalk database scripts.

Requires:  perl(Digest::SHA)

%description sanity
Provides schema-source-sanity-check.pl script for external usage.

%prep

%setup -q

%build
%if 0%{?fedora} || 0%{?rhel} >= 7
find . -name '*.91' | while read i ; do mv $i ${i%%.91} ; done
%endif
make -f Makefile.schema SCHEMA=%{name} VERSION=%{version} RELEASE=%{release}
pod2man spacewalk-schema-upgrade spacewalk-schema-upgrade.1
pod2man spacewalk-sql spacewalk-sql.1

%install
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}
install -m 0755 -d $RPM_BUILD_ROOT%{oracle}
install -m 0755 -d $RPM_BUILD_ROOT%{postgres}
install -m 0644 oracle/main.sql $RPM_BUILD_ROOT%{oracle}
install -m 0644 postgres/main.sql $RPM_BUILD_ROOT%{postgres}
install -m 0644 oracle/end.sql $RPM_BUILD_ROOT%{oracle}/upgrade-end.sql
install -m 0644 postgres/end.sql $RPM_BUILD_ROOT%{postgres}/upgrade-end.sql
install -m 0755 -d $RPM_BUILD_ROOT%{_bindir}
install -m 0755 %{name}-upgrade $RPM_BUILD_ROOT%{_bindir}
install -m 0755 spacewalk-sql $RPM_BUILD_ROOT%{_bindir}
install -m 0755 -d $RPM_BUILD_ROOT%{rhnroot}/schema-upgrade
( cd upgrade && tar cf - --exclude='*.sql' . | ( cd $RPM_BUILD_ROOT%{rhnroot}/schema-upgrade && tar xf - ) )
mkdir -p $RPM_BUILD_ROOT%{_mandir}/man1
cp -p spacewalk-schema-upgrade.1 $RPM_BUILD_ROOT%{_mandir}/man1
cp -p spacewalk-sql.1 $RPM_BUILD_ROOT%{_mandir}/man1

%if 0%{?suse_version}
%fdupes %{buildroot}/%{rhnroot}
%endif

install -m 755 schema-source-sanity-check.pl $RPM_BUILD_ROOT%{_bindir}/schema-source-sanity-check.pl

%clean

%files
%{oracle}
%{postgres}
%{rhnroot}/schema-upgrade
%{_bindir}/%{name}-upgrade
%{_bindir}/spacewalk-sql
%{_mandir}/man1/spacewalk-schema-upgrade*
%{_mandir}/man1/spacewalk-sql*
%if 0%{?suse_version}
%dir %{rhnroot}
%endif

%files sanity
%attr(755,root,root) %{_bindir}/schema-source-sanity-check.pl

%changelog
* Thu Mar 29 2018 Jiri Dostal <jdostal@redhat.com> 2.8.22-1
- Update gpgs in database

* Tue Mar 27 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.21-1
- fix sha1sums

* Tue Mar 27 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.20-1
- implicit default null is different from explicit default null - use the
  implicit one

* Wed Mar 21 2018 Jiri Dostal <jdostal@redhat.com> 2.8.19-1
- Updating schema SHAs to match after copyright update
- Updating copyright years for 2018

* Tue Feb 20 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.18-1
- fix schema upgrade for oracle

* Wed Feb 14 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.17-1
- add forgotten semicolon

* Tue Feb 13 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.16-1
- 1542287 - purge records that would be violating unique constraint during
  fixup

* Tue Feb 13 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.15-1
- fix sha1sums

* Tue Feb 13 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.14-1
- Oracle expects procedure signatures in pks files

* Mon Feb 12 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.13-1
- create indexes instead of constraints during upgrade
- extra newline is causing troubles on Oracle DBs

* Fri Feb 09 2018 Michael Mraka <michael.mraka@redhat.com> 2.8.12-1
- remove install/clean section initial cleanup
- removed Group from specfile
- removed BuildRoot from specfiles

* Fri Feb 09 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.11-1
- postgresql requires numeric datatype not number

* Thu Feb 08 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.10-1
- fix oracle equivalent shource sha1 sums

* Thu Feb 08 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.9-1
- update set_comps stored procedure for usage with modules
- use rhnCompsType table for different types of repo metadata (comps) files
- create table for different metadata file types

* Wed Feb 07 2018 Jiri Dostal <jdostal@redhat.com> 2.8.8-1
- fix different schema creation vs. upgrade

* Tue Feb 06 2018 Jiri Dostal <jdostal@redhat.com> 2.8.7-1
- Constraint already exists, use different name

* Tue Feb 06 2018 Tomas Kasparek <tkasparek@redhat.com> 2.8.6-1
- 1542287 - we don't have solaris table anymore

* Mon Feb 05 2018 Jiri Dostal <jdostal@redhat.com> 2.8.5-1
- 1541955 - Clone of an erratum doesn't have original erratum's severity

* Thu Oct 19 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.4-1
- move deletion to the inner loop to delete all duplicates

* Wed Oct 18 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.3-1
- 1410737 - remove duplicate record in rhnPackageEVR table
- 1410737 - compound indexes containg NULL behave differently on PostgreSQL

* Wed Oct 11 2017 Tomas Kasparek <tkasparek@redhat.com> 2.8.2-1
- create spacewalk-schema-sanity package providing sanity check script for
  external usage
- allow passing command line arguments into schema-source-sanity-check.pl

* Wed Sep 06 2017 Michael Mraka <michael.mraka@redhat.com> 2.8.1-1
- purged changelog entries for Spacewalk 2.0 and older
- Bumping package versions for 2.8.

* Wed Aug 09 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.28-1
- there's no table rhnOrgEntitlementType in Spacewalk anymore

* Tue Aug 08 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.27-1
- 1466493 - oracle equivalent source sha1 is missing

* Tue Aug 08 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.26-1
- 1466493 - delete remainder of nonlinux entitlement

* Mon Jul 31 2017 Eric Herget <eherget@redhat.com> 2.7.25-1
- update copyright year

* Wed May 31 2017 Grant Gainey 2.7.24-1
- 1381857 - Correct overly-broad comparison in the fixup-functions
  Set ORA back to INDEX from CONSTRAINT - consistency is important...

* Thu May 11 2017 Grant Gainey 2.7.23-1
- 1381857 - add empty .oracle to make schema-upgrade happy

* Mon May 08 2017 Grant Gainey 2.7.22-1
- 1381857 - Teach Postgres to correctly-unique-ify rhnConfigInfo rows

* Thu May 04 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.21-1
- 1444519 - update schema definition and shorten index name

* Wed May 03 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.20-1
- 1444519 - fix index behaviour on NULL org

* Wed May 03 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.19-1
- Revert "1444375 - instert package keys only if they exist"
- 1444072 - drop filters while deleting repository

* Tue May 02 2017 Jan Dobes 2.7.18-1
- 1434336 - postgresql 8.4 doesn't support WITH and DELETE combination

* Tue May 02 2017 Michael Mraka <michael.mraka@redhat.com> 2.7.17-1
- 1444047 - remove links between errata and files from different orgs
- 1444519 - allow sync of the same erratum to more orgs
- 1444375 - insert package keys only if they exist

* Wed Apr 05 2017 Jan Dobes 2.7.16-1
- 1434336 - adding postgresql upgrade
- 1434336 - on postgresql it's needed to define multiple unique indexes because
  of null values
- 1436567 - add warning that satellite service should be stopped before upgrade

* Wed Mar 22 2017 Tomas Lestach <tlestach@redhat.com> 2.7.15-1
- 1434900 - fixing typo in spacewalk-schema-upgrade

* Tue Mar 21 2017 Jiri Dostal <jdostal@redhat.com> 2.7.14-1
- 1433029 SHA1 Oracle fix

* Fri Mar 17 2017 Jiri Dostal <jdostal@redhat.com> 2.7.13-1
- 1433029 - Some of monitoring data are not removed from DB

* Thu Mar 16 2017 Jiri Dostal <jdostal@redhat.com> 2.7.12-1
- 1433029 - Some of monitoring data are not removed from DB
- Use HTTPS in all Github links
- Migrating Fedorahosted to GitHub

* Thu Mar 02 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.11-1
- 1427530 - fix sha1

* Thu Mar 02 2017 Tomas Kasparek <tkasparek@redhat.com> 2.7.10-1
- 1427530 - solaris channels can have non-solaris child channels

* Fri Feb 24 2017 Jan Dobes 2.7.9-1
- drop create_first_org

* Thu Feb 09 2017 Jan Dobes 2.7.8-1
- 1401497 - upgrades
- 1401497 - save ssl in separate table again, now allow to have multiple ssl
  sets per content source

* Wed Jan 25 2017 Jiri Dostal <jdostal@redhat.com> 2.7.7-1
- 1332805 - The problematic editing of kickstart profile - custom options

* Mon Jan 23 2017 Jan Dobes 2.7.6-1
- Drop code used from the Perl stack to 'trickle' OSAD

* Tue Dec 20 2016 Tomas Kasparek <tkasparek@redhat.com> 2.7.5-1
- 1402437 - update sha1

* Tue Dec 20 2016 Tomas Kasparek <tkasparek@redhat.com> 2.7.4-1
- 1402437 - drop child channels first
- rhnServerGroupTypeFeature table is dependant on rhnServerGroupType

* Tue Dec 13 2016 Tomas Kasparek <tkasparek@redhat.com> 2.7.3-1
- 1402437 - delete all solaris related records in database

* Fri Nov 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.7.2-1
- delete records from rhnArchTypeActions before deleting architecture types

* Wed Nov 23 2016 Tomas Kasparek <tkasparek@redhat.com> 2.7.1-1
- delete from solaris from rhnArchType table
- Bumping package versions for 2.7.

* Mon Nov 14 2016 Tomas Kasparek <tkasparek@redhat.com> 2.6.16-1
- delete solaris architecture during upgrade
- remove solaris compatibility mappings
- don't populate db with solaris architectures

* Thu Nov 10 2016 Gennadii Altukhov <galt@redhat.com> 2.6.15-1
- add Fedora 24 key into schema upgrade

* Tue Nov 08 2016 Gennadii Altukhov <galt@redhat.com> 2.6.14-1
- Added repo urls and gpg keys for Fedora 24

* Mon Oct 24 2016 Jan Dobes 2.6.13-1
- fixing ORA-00904: : invalid identifier

* Fri Oct 21 2016 Jan Dobes 2.6.12-1
- adding missing dependency

* Thu Oct 20 2016 Jan Dobes 2.6.11-1
- drop rhnContentSourceSsl completely

* Tue Oct 04 2016 Jan Dobes 2.6.10-1
- splitting oracle and postgresql upgrade

* Fri Sep 02 2016 Grant Gainey 2.6.9-1
- Avoid a deadlock when deleting a server

* Wed Aug 24 2016 Grant Gainey 2.6.8-1
- 1369559 - adjust pgres autovacuum settings for rhnChannelPackage to make
  rapid, large, size-changes more performant

* Fri Aug 12 2016 Jan Dobes 2.6.7-1
- enable deb type

* Fri Jun 17 2016 Jan Dobes 2.6.6-1
- we already have unbreakable linux network reposync plugin

* Mon Jun 13 2016 Grant Gainey 2.6.5-1
- spacewalk-schema: build on openSUSE

* Mon Jun 13 2016 Jan Dobes 2.6.4-1
- sequence is still there

* Mon Jun 13 2016 Jan Dobes 2.6.3-1
- fixing invalid syntax

* Fri Jun 10 2016 Jan Dobes 2.6.2-1
- change rhnContentSourceSsl table to possibly connect to channel family
  (instead of content source) and rename to rhnContentSsl

* Thu Jun 09 2016 Jan Dobes 2.6.1-1
- fix dropping unused entitlements when multiple orgs are available
- Bumping package versions for 2.6.

* Wed May 25 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.21-1
- updating copyright years
- 1303886 - remove Oracle from summary

* Thu Apr 14 2016 Jiri Precechtel <jprecech@redhat.com> 2.5.20-1
- 1320119 - added delete of data in referrenced table

* Fri Mar 18 2016 Jan Dobes 2.5.19-1
- add missing database commit

* Thu Mar 17 2016 Jan Dobes 2.5.18-1
- adding missing Oracle upgrade
- delete sync probe task
- populate uuid cleanup task on clean installation
- drop column from _log table too
- sequnce rhn_org_entitlement_type_seq should be dropped
- dropping functions after entitlements removal in upgrade

* Fri Mar 11 2016 Jan Dobes 2.5.17-1
- Revert "fix oracle sha1 for 017-drop_monitoring_tables.sql"

* Fri Mar 11 2016 Jan Dobes 2.5.16-1
- make sure people already on 2.4 will get missed 2.2 -> 2.3 upgrades
- fixing missing 2.2 -> 2.3 upgrades
- Revert "delete one more table"

* Wed Mar 09 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.15-1
- fixing oracle sha1
- taskomatic records for uuid cleanup

* Wed Mar 09 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.14-1
- remove uuid cleanup from database level

* Mon Mar 07 2016 Jan Dobes 2.5.13-1
- fixing upgrade on Oracle - it's function
- fixing upgrade on Oracle - invalid end of file
- fixing upgrade on Oracle
- add Chile to the list of timezones (bsc#959055)

* Fri Feb 12 2016 Jan Dobes 2.5.12-1
- fixing missing upgrade

* Tue Feb 09 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.11-1
- delete trigger if does exist before creating it

* Tue Feb 02 2016 Grant Gainey 2.5.10-1
- When deleting a server, delete all associated rhnSet entries
- 1303886 - update %%description of spacewalk-schema package

* Fri Jan 29 2016 Jan Dobes 2.5.9-1
- 1301611 - no need to lock table since we don't update entitlements

* Fri Jan 22 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.8-1
- fix oracle sha1 for 017-drop_monitoring_tables.sql

* Thu Jan 14 2016 Jan Dobes 2.5.7-1
- delete one more table

* Mon Jan 11 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.6-1
- purge duplicate uuid records during upgrade process

* Fri Jan 08 2016 Tomas Kasparek <tkasparek@redhat.com> 2.5.5-1
- purge uuid records after deleting a system

* Mon Dec 07 2015 Jan Dobes 2.5.4-1
- first org needs id = 1

* Fri Dec 04 2015 Jan Dobes 2.5.3-1
- when installing insert default SSL crypto key with null org

* Tue Nov 24 2015 Jan Dobes 2.5.2-1
- fixing sha
- schema upgrade: org entitlement related tables
- schema: remove org_entitlement(sw_mgr_enterprise) from rhnInfoPane
- schema: drop rhnOrgEntitlements and rhnOrgEntitlementType tables
- schema: fix shas
- schema upgrade: drop max_members from rhnServerGroupType
- schema upgrade: delete_server proc
- schema upgrade: views
- schema upgrade: delete unused rhnExceptions
- schema upgrade: rhn_server package
- schema upgrade: rhn_org package
- schema upgrade: rhn_enttitlements package
- schema upgrade: create_org procs
- schema upgrade: drop rhnSatelliteCert
- schema upgrade: drop the sat-check Taskomatic task
- schema: assign org entitlements when creating a new organization
- schema: create config_admin user group while creating a new organization
- schema: remove repoll parameter from
  rhn_entitlements.remove_server_entitlement()
- schema: drop rhn_entitlements.repoll_virt_guest_entitlements()
- schema: remove rhn_server.can_server_consume_virt_slot() and count
  current_members like normal server groups
- schema: remove max_members from rhnServerGroupOverview view
- schema: drop unused rhnVisServerGroupOverviewLite view
- schema: remove use of max_members in views
- schema: remove max_members from rhnServerGroup table
- schema: remove unused not_enough_entitlements_in_base_org exception
- schema: remove unused exception servergroup_max_members
- schema: do not set max_members in create_first_org and create_new_org
- schema: modify rhn_server.insert_into_servergroup() to not use max_members
- schema: drop modify_org_service, set_customer_enterprise,
  unset_customer_enterprise from rhn_entitlements
- schema: drop rhn_entitlements.entitle_last_modified_servers()
- schema: drop rhn_entitlements.activate_system_entitlement()
- schema: drop rhn_entitlements.assign_system_entitlement()
- schema: drop rhn_entitlements.set_server_group_count()
- schema: drop rhn_entitlements.prune_group()
- schema: remove handling of max_members from
  rhn_entitlements.repoll_virt_guest_entitlements()
- schema: drop rhn_entitlements.remove_org_entitlements()
- schema: add virtualization host entitlement and enterprise entitlement to SP
  for creating organizations
- db: drop rhnSatelliteCert
- sat-cert-check Taskomatic task dropped
- rhn_server migrations: drop provisioning, update,
  virtualization_host_platform entitlements
- rhn_entitlements migrations: drop provisioning, update, nonlinux and
  virtualization_host_platform entitlements
- migration for create_first_org and create_new_org SP: don't add update
  entitlement for new orgs
- rhnEntitledServers view migration: remove reference to update entitlements
- db migration: remove references to rhnVirtSubLevel, rhnSGTypeVirtSubLevel and
  rhnChannelFamilyVirtSubLevel
- delete_server stored procedure migration: remove references to virtualization
  host platform entitlements
- data migration: remove references to virtualization host platform
  entitlements
- data migration: remove references to nonlinux entitlements
- data migration: remove references to update entitlements
- db: remove references to rhnVirtSubLevel, rhnSGTypeVirtSubLevel and
  rhnChannelFamilyVirtSubLevel
- data: remove references to virtualization host platform entitlements
- rhn_server: remove references to virtualization host platform entitlements
- rhn_entitlements: remove references to virtualization host platform
  entitlements
- delete_server: remove references to virtualization host platform entitlements
- data: remove references to nonlinux entitlements
- rhn_entitlements: remove references to nonlinux entitlements
- rhnEntitledServers: remove reference to update entitlements
- data: remove references to update entitlements
- rhn_server: don't expect update entitlement
- rhn_entitlements: update shas
- rhn_entitlements.entitle_server: remove update entitlement references
- rhn_entitlements.remove_server_entitlement: delete default function value,
  callers always specify it
- rhn_entitlements.entitle_server: delete default function value, callers
  always specify it
- rhn_entitlements: drop unused create_entitlement_group function
- rhn_entitlements: drop unused lookup_entitlement_group function
- create_new_org and create_first_org: remove automatically added update
  entitlement server group
- schema upgrades: fix to the dropping of provisioning entitlements
- db: upgrade scripts
- rhnEntitledServers view: remove references to provisioning
- db data: remove references to provisioning
- rhn_server: remove provisioning references
- create_new_org and create_first_org: remove outdated comment
- rhn_entitlements: remove provisioning references
- Remove unused rhn_host_monitoring and its oracle synonym
- Remove unused rhn_customer_monitoring view and its oracle synonym
- Removed unused rhn_contact_monitoring and its oracle synonym
- Remove monitoring_admin role from users, remove monitoring_admin row from
  rhnUserGroupType
- Remove populating rhn_config_macro table as it doesn't exist anymore
- Drop the rhn_config_macro table
- db: Remove monitoring entitlement from insert/delete to/from server group
- db: Remove rhn_monitoring from the database
- schema: drop parameter from clear_subscriptions in delete_server
- schema migration: drop not_enough_flex_entitlements exception
- schema migration: drop not_enough_flex_entitlements_in_base_org exception
- schema migration: remove server_cannot_convert_to_flex exception
- schema: drop not_enough_flex_entitlements exception
- schema: drop not_enough_flex_entitlements_in_base_org exception
- schema: remove server_cannot_convert_to_flex exception
- schema migration: remove unused invalid_channel_family exception
- schema: remove unused invalid_channel_family exception
- schema migration: drop software channel subscription counting
- schema: drop unused rhnChannelFamilyServerPhysical view
- schema: drop is_fve column from rhnServerChannel
- schema: remove unused rhn_entitlements.subscribe_newest_servers()
- schema: fix syntax error in rhn_channel
- schema: remove member columns from rhnPrivateChannelFamily
- schema: remove channel entitlement setting from remove_org_entitlements in
  rhn_entitlements
- schema: remove maxMembers, currentMembers, maxFlex and currentFlex from
  rhnChannelFamilyPermissions view
- schema: remove member check from rhn_channel.get_org_access()
- schema: remove members from rhnOrgChannelFamilyPermissions and
  rhnUserChannelFamilyPerms views
- schema: drop rhnChannelFamilyServerVirtual view
- schema: drop unused view rhnChannelFamilyServers
- schema: drop rhnChannelFamilyServerFve view
- schema: remove unused vars from [un]subscribe_server in rhn_channel
- schema: remove unused virt_guest_orgs from repoll_virt_guest_entitlements in
  rhn_entitlements
- schema: remove delete_server_channels from rhn_channel and delete_server
  proceedure
- schema: remove rhnChannelFamilyOverview view
- schema: remove channel_family_no_subscriptions exception
- schema: drop unused view rhnServerFveCapable
- schema: drop channel_family_no_subscriptions exception
- schema: remove channel_family_current_members from rhn_channel
- schema: remove prune_family from rhn_entitlements
- schema: remove set_family_count from rhn_entitlements
- schema: remove channel entitlement handling from
  repoll_virt_guest_entitlements in rhn_entitlements
- schema: remove assign_channel_entitlement from rhn_entitlements
- schema: remove available_family_subscriptions from rhn_channel
- schema: remove available_fve_family_subs from rhn_channel
- schema: remove unused available_fve_chan_subs from rhn_channel
- schema: remove unused available_chan_subscriptions from rhn_channel
- schema: remove unused rhnUserAvailableChannels view
- remove current_members and available_members from rhnAvailableChannels view
- schema: remove unused can_server_consume_fve from rhn_channel
- schema: remove unused can_server_consume_virt_channl from rhn_channel
- schema: remove channel entitlement checks on subscribe_server
- schema: drop convert_to_fve and can_convert_to_fve from rhn_channel
- schema: whitespace fixes
- schema: remove unused activate_channel_entitlement from rhn_entitlements
- schema: remove unused function cfam_curr_fve_members from rhn_channel
- schema: remove usage of update_group_family_counts from rhn_entitlements
- schema: remove update_family_counts from rhn_entitlements
- schema: remove update_family_counts and update_group_family_counts

* Wed Sep 30 2015 Tomas Kasparek <tkasparek@redhat.com> 2.5.1-1
- fix delete user by deleting the reference to rhnResetPassword
- Bumping package versions for 2.5.

* Tue Sep 29 2015 Jan Dobes 2.4.23-1
- fix schema migration error - trigger must be created after the table

* Thu Sep 24 2015 Jan Dobes 2.4.22-1
- Bumping copyright year.

* Wed Sep 16 2015 Grant Gainey 2.4.21-1
- 608355 - missed updating a checksum
- 608355 - Support 2.3-to-2.4 upgrade
- 608355 - rhnResetPassword to support password-recovery-tokens

* Fri Jul 31 2015 Grant Gainey 2.4.20-1
- 1249219 - Fix file-naming error for upgrade

* Fri Jul 31 2015 Grant Gainey 2.4.19-1
- 1249219 - Fix postgres rpm.rpmstrcmp to exhibit same behavior as original
  Oracle functionality

* Thu Jul 23 2015 Tomas Lestach <tlestach@redhat.com> 2.4.18-1
- unify schema comment message

* Wed Jul 22 2015 Tomas Lestach <tlestach@redhat.com> 2.4.17-1
- update the oracle equivalent sha1s
- removing outdated revision information for schema files

* Mon Jul 20 2015 Tomas Lestach <tlestach@redhat.com> 2.4.16-1
- ensure appropriate table entries are avaialble for newly created
  organizations
- introduce rhnOrgAdminManagement table
- add errata_emails_enabled column to the rhnOrgConfiguration table

* Tue Jun 30 2015 Grant Gainey 2.4.15-1
- 1234604 - teach oracle to do update_needed_cache async as well

* Mon Jun 22 2015 Grant Gainey 2.4.14-1
- 1234604 - Fix oracle-sha1sum for 007- upgrade

* Mon Jun 22 2015 Grant Gainey 2.4.13-1
- 1234604 - Make rhn_channel.update_needed_cache hand off servers to Taskomatic

* Fri Jun 12 2015 Jan Dobes 2.4.12-1
- prevent inserting duplicate update_server_errata_cache tasks

* Thu May 21 2015 Tomas Lestach <tlestach@redhat.com> 2.4.11-1
- extend label in rhnContentSource table

* Mon May 18 2015 Tomas Lestach <tlestach@redhat.com> 2.4.10-1
- we need to run cleanup-packagechangelog-data as the 1st task of the template

* Fri May 15 2015 Stephen Herr <sherr@redhat.com> 2.4.9-1
- Remove monitoring cleanup taskomatic task - monitoring longer exists

* Wed May 13 2015 Stephen Herr <sherr@redhat.com> 2.4.8-1
- Add spacewalk-2015 and Fedora 23 gpg key fingerprints
- Add package key for Spacewalk 2014 (RPM-GPG-KEY-spacewalk-2014)

* Tue May 12 2015 Grant Gainey 2.4.7-1
- 1220361 - clean up upgrade with empty .sql.oracle file

* Mon May 11 2015 Grant Gainey 2.4.6-1
- 1220361 - Use GREATEST to insure LIMIT is >= 0

* Wed Apr 29 2015 Stephen Herr <sherr@redhat.com> 2.4.5-1
- 1215671 - move auto-errata updates into separate taskomatic task

* Mon Apr 27 2015 Grant Gainey 2.4.4-1
- Update 021 postgres to new oracle sha1

* Mon Apr 27 2015 Grant Gainey 2.4.3-1
- 1215151 - Update 021-rhnServerNetwork-trigger.sql.oracle

* Thu Apr 02 2015 Tomas Kasparek <tkasparek@redhat.com> 2.4.2-1
- Oracle alter table xxx add column syntax differs from PostgreSQL one

* Wed Apr 01 2015 Jan Dobes 2.4.1-1
- 1205328 - do not ignore errata with same package version
- Bumping package versions for 2.4.

* Fri Mar 27 2015 Tomas Lestach <tlestach@redhat.com> 2.3.41-1
- Fix ORA-01403: no data found in update_needed_cache during re-registrations

* Thu Mar 19 2015 Grant Gainey 2.3.40-1
- Automatic commit of package [osad] release [5.11.56-1].
- Updating copyright info for 2015

* Thu Mar 05 2015 Stephen Herr <sherr@redhat.com> 2.3.39-1
- add the EPEL 7 key to new db installation scripts, move upgrade script
- Add EPEL 7 package key

* Wed Mar 04 2015 Stephen Herr <sherr@redhat.com> 2.3.38-1
- Avoid a deadlock when changing channel assignments (bsc#918549)

* Tue Mar 03 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.37-1
- 1128989 - allow users to set taskomatic mail preferences - schema changes

* Mon Mar 02 2015 Stephen Herr <sherr@redhat.com> 2.3.36-1
- remove monitoring server groups from servers before deleting the sg

* Fri Feb 13 2015 Stephen Herr <sherr@redhat.com> 2.3.35-1
- 1192437 - add armv7l-debian server arch

* Thu Jan 15 2015 Matej Kollar <mkollar@redhat.com> 2.3.34-1
- Getting rid of Tabs and trailing spaces in Python
- Getting rid of trailing spaces in Perl
- Getting rid of Tabs and trailing spaces in LICENSE, COPYING, and README files

* Thu Jan 08 2015 Tomas Kasparek <tkasparek@redhat.com> 2.3.33-1
- arm related sutff can be present in db before upgrade
- don't instert values that can be already present
- some values can be insterted multiple times - don't do that
- some values can be already present at the time of upgrade

* Tue Dec 23 2014 Stephen Herr <sherr@redhat.com> 2.3.32-1
- Fixing duplicated 'drop rhn_probe' statement

* Mon Dec 22 2014 Stephen Herr <sherr@redhat.com> 2.3.31-1
- Fixing order of tables to be dropped

* Fri Dec 19 2014 Stephen Herr <sherr@redhat.com> 2.3.30-1
- add schema upgrade scripts to fix triggers on rhnServerNetwork

* Thu Dec 18 2014 Stephen Herr <sherr@redhat.com> 2.3.29-1
- don't add sync-probe taskomatic task, but handle upgrades that have it

* Thu Dec 18 2014 Stephen Herr <sherr@redhat.com> 2.3.28-1
- Monitoring Panes on YourRHN no longer exist, remove schema references to them

* Thu Dec 18 2014 Stephen Herr <sherr@redhat.com> 2.3.27-1
- rhn_method_types table no longer exists, don't insert data into it

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.26-1
- fixing oracle sha1source

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.25-1
- remove monitoring server group type
- Fix upgrade schema script that drops monitoring tables

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.24-1
- fixing upgrade script ordering after perl-removal merge

* Wed Dec 17 2014 Stephen Herr <sherr@redhat.com> 2.3.23-1
- Removing solaris tables
- drop monitoring code and monitoring schema
- removing monitoring from spacewalk-schema

* Wed Dec 17 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.22-1
- armv6hl could be present at the time of upgrade

* Fri Dec 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.21-1
- 1021057 - renamed package upgrade scripts to .sql

* Fri Dec 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.20-1
- 1021057 - schema upgrade scripts
- 1021057 - fixed double-counting systems subscribed to more than one channel

* Thu Nov 13 2014 Stephen Herr <sherr@redhat.com> 2.3.19-1
- 1163977 - add virt-host-plat entitlement mappings for new arches

* Fri Oct 10 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.18-1
- increase source_url column size to 2048

* Wed Oct 08 2014 Tomas Lestach <tlestach@redhat.com> 2.3.17-1
- use fedora18 as fedora kickstart type

* Thu Oct 02 2014 Stephen Herr <sherr@redhat.com> 2.3.16-1
- 1148911 - add aarch64 server to noarch package mapping

* Fri Sep 26 2014 Tomas Lestach <tlestach@redhat.com> 2.3.15-1
- 1145478 - enhance rhnWebContactEnabled view

* Mon Sep 22 2014 Stephen Herr <sherr@redhat.com> 2.3.14-1
- 1114687 - rhnDistChannelMap index needs to handle nulls on postgresql

* Wed Sep 17 2014 Stephen Herr <sherr@redhat.com> 2.3.13-1
- 1138708, 1142110 - make child channel architecture check universal

* Thu Sep 11 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.12-1
- RHEL7 contains PostgreSQL 9

* Fri Sep 05 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.11-1
- 1021057 - system can consume only one flex entitlement

* Fri Aug 29 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.10-1
- 1128735 - force character set and numerical separators to good known
  defaults.

* Fri Aug 08 2014 Jan Dobes 2.3.9-1
- adding missing upgrade

* Thu Aug 07 2014 Jan Dobes 2.3.8-1
- fixing order of commands

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.7-1
- add Korea to the list of timezones

* Fri Aug 01 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.6-1
- there's no bootstrap entitlement in spacewalk

* Thu Jul 31 2014 Stephen Herr <sherr@redhat.com> 2.3.5-1
- 1125428 - make config file deletion faster if there are lots of snapshots

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.4-1
- Add support to the ppc64le architecture

* Thu Jul 31 2014 Michael Mraka <michael.mraka@redhat.com> 2.3.3-1
- 1066432 - make future installs run ErrataCache task more often

* Tue Jul 22 2014 Tomas Kasparek <tkasparek@redhat.com> 2.3.2-1
- 1023557 - Speed up satellite-sync by avoiding commonly-called dblink_exec

* Fri Jul 18 2014 Miroslav Suchý <msuchy@redhat.com> 2.3.1-1
- add Fedora 21 GPG keys
- Bumping package versions for 2.3.

* Fri Jul 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.33-1
- add CentOS 7 GPG key
- fix copyright years

* Tue Jul 08 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.32-1
- 1103813 - fixed order of tables in upgrade script

* Fri Jul 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.31-1
- 1103813 - armhf support for "arm Debian" channel

* Tue Jul 01 2014 Stephen Herr <sherr@redhat.com> 2.2.30-1
- 1109276 - Fix Distro syncing in CobblerSyncTask, force one sync to fix arch

* Fri Jun 27 2014 Stephen Herr <sherr@redhat.com> 2.2.29-1
- Fix rhnKickstartableTree trigger, 'null = null' is not true in sql

* Thu Jun 26 2014 Stephen Herr <sherr@redhat.com> 2.2.28-1
- Moving schema upgrade to appropriate dir
- rhnSsmOperationServer: note column added

* Thu May 29 2014 Stephen Herr <sherr@redhat.com> 2.2.27-1
- 1077365 - index for user_id on wupi table speeds up errata mailer

* Fri May 23 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.26-1
- spec file polish

* Wed Apr 23 2014 Stephen Herr <sherr@redhat.com> 2.2.25-1
- Schema typo fixed

* Mon Apr 14 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.24-1
- schema: new action type, clientcert.update_client_cert

* Fri Apr 04 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.23-1
- 903068 - update scripts for schema
- 903068 - fixed debian repo generation

* Thu Apr 03 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.22-1
- rhnActionChain.id: explicitly name the primary index constraint

* Tue Apr 01 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.21-1
- triggers to be recreated consistently with a new schema

* Tue Apr 01 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.20-1
- Drop rhn_actchainent_cid_sid_so_uq constraint from rhnActionChainEntry

* Mon Mar 31 2014 Stephen Herr <sherr@redhat.com> 2.2.19-1
- renaming upgrade scripts to put them in the proper place in the order
- New tables and upgrade scripts added
- add reboot action cleanup task

* Fri Mar 28 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.18-1
- rhnServer.secret extend length to 64: schema upgrade
- extend rhnServer.secret to 64

* Tue Mar 25 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.17-1
- reset package to avoid ORA-0406* errors

* Fri Mar 21 2014 Tomas Lestach <tlestach@redhat.com> 2.2.16-1
- create rhnOrgExtGroupMapping triggers
- change rhnUserExtGroup unique index

* Thu Mar 20 2014 Tomas Lestach <tlestach@redhat.com> 2.2.15-1
- upgrade scripts shall end with semicolon

* Wed Mar 19 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.14-1
- fixing web_contact schema upgrade script

* Wed Mar 19 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.13-1
- schema upgrade for web_contact_log

* Tue Mar 18 2014 Tomas Lestach <tlestach@redhat.com> 2.2.12-1
- add rhnUserExtGroup table dependency

* Fri Mar 14 2014 Tomas Lestach <tlestach@redhat.com> 2.2.11-1
- add table dependency

* Fri Mar 14 2014 Tomas Lestach <tlestach@redhat.com> 2.2.10-1
- add table dependency

* Thu Mar 13 2014 Tomas Lestach <tlestach@redhat.com> 2.2.9-1
- introduce create_default_sg column within the rhnOrgConfiguration table
- create rhnOrgExtGroupMapping table
- add org_id column to rhnUserExtGroup table

* Tue Mar 11 2014 Tomas Lestach <tlestach@redhat.com> 2.2.8-1
- 1070917 - extending cron_expr length to 120

* Mon Mar 10 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.7-1
- Extend length of web_contact.password to 110

* Mon Mar 10 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.6-1
- 1055969 - missing aarch64 in rhnServerArch

* Fri Mar 07 2014 Michael Mraka <michael.mraka@redhat.com> 2.2.5-1
- 1055969 - support for ARM aarch64 architecture

* Thu Mar 06 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.2.4-1
- drop web_contact.old_password column from schema
- insert new gpg key only if not exists

* Fri Feb 28 2014 Tomas Lestach <tlestach@redhat.com> 2.2.3-1
- fix oracle equivalent source sha1

* Fri Feb 28 2014 Tomas Lestach <tlestach@redhat.com> 2.2.2-1
- 1070917 - extending cron_expr column within the rhnTaskoSchedule table

* Tue Feb 25 2014 Tomas Lestach <tlestach@redhat.com> 2.2.1-1
- introduce keep_roles option
- extend rhnUserGroupMembers
- Bumping package versions for 2.2.

* Mon Feb 24 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.50-1
- replacing view must have the same number of columns (in postgresql)

* Fri Feb 21 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.49-1
- updated rhnServerOutdatePackages to include arch

* Fri Feb 21 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.48-1
- improved performance of system.listLatestUpgradeablePackages and
  UpgradableList.do

* Tue Feb 18 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.47-1
- 1063821 - update rhnServer after queue_server to avoid a deadlock

* Mon Feb 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.46-1
- 1063821 - fix ORA-01422 error when removing a channel

* Fri Feb 14 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.45-1
- fix ORA-01403: no data found, when unsubscribing a system

* Fri Feb 14 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.44-1
- rename upgrade scripts to be included in schema upgrade
- fix ORA-01403: no data found, during system registration

* Wed Feb 12 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.43-1
- 1063821 - lock rhnServerNeededCache to avoid a db deadlock

* Wed Feb 12 2014 Tomas Kasparek <tkasparek@redhat.com> 2.1.42-1
- Add missing GMT+3 timezone as Saudi Arabia

* Tue Feb 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.41-1
- fix sha1 sums

* Tue Feb 11 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.40-1
- 1063821 - deadlock fix

* Tue Feb 04 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.39-1
- upgrade script for Fedora 20 GPG key

* Mon Feb 03 2014 Tomas Lestach <tlestach@redhat.com> 2.1.38-1
- rename one and add another rhnConfiguration key
- update rhnUserExtGroupMapping triggers

* Wed Jan 22 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.37-1
- Revert "1053591 - refresh_newest_package: lock rhnChannel at the beginning"
- Revert "'is' followed by 'declare' is rarely needed"

* Fri Jan 17 2014 Michael Mraka <michael.mraka@redhat.com> 2.1.36-1
- increase length of rhnCVE name column

* Fri Jan 17 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.35-1
- 'is' followed by 'declare' is rarely needed

* Fri Jan 17 2014 Tomas Lestach <tlestach@redhat.com> 2.1.34-1
- rename the schema files to have the proper naming

* Thu Jan 16 2014 Tomas Lestach <tlestach@redhat.com> 2.1.33-1
- Tables to have mapping from external groups to internal roles
  (rhnUserGroupType).
- introduce 1st configuration key
- introduce rhnConfiguration table

* Thu Jan 16 2014 Matej Kollar <mkollar@redhat.com> 2.1.32-1
- Changed gpg keys so they match reality.

* Wed Jan 15 2014 Milan Zazrivec <mzazrivec@redhat.com> 2.1.31-1
- 1053591 - refresh_newest_package: lock rhnChannel at the beginning

* Mon Dec 02 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.30-1
- 1034742 - schema upgrade for armv6hl arch
- 1034742 - support for new Raspberry Pi arch (armv6hl)

* Fri Nov 29 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.29-1
- 1034742 - support for new Raspberry Pi arch (armv6hl)

* Tue Nov 26 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.28-1
- delete child channel references from rhnDistChannelMap

* Thu Nov 14 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.27-1
- schema upgrade fix: explicit cast for bit-wise operand

* Mon Nov 11 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.26-1
- fixed oracle equivalent checksums

* Mon Nov 11 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.25-1
- schema upgrade for rhnServerNeededCache
- extended update_needed_cache() to insert channel_id
- extended rhnServerNeededCache with channel_id

* Thu Oct 24 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.24-1
- fix space check for Oracle schema upgrades

* Thu Oct 24 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.23-1
- schema upgrade fix: explicit cast for bit-wise operand

* Tue Oct 22 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.22-1
- Regenerate the metadata for rpm enhances dependency (bnc#846436)
- add support for enhances rpm weak dependency (schema) (bnc#846436)

* Thu Oct 17 2013 Stephen Herr <sherr@redhat.com> 2.1.21-1
- 1020497 - provide a way to order kickstart scripts

* Tue Sep 17 2013 Jan Dobes 2.1.20-1
- 820225 - recount associated virtual guests entitlements even in other orgs

* Tue Sep 17 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.19-1
- upgrade script for Oracle Linux 6 key
- Added Oracle GPG key used to sign Oracle Linux 6 packages.

* Tue Sep 10 2013 Stephen Herr <sherr@redhat.com> 2.1.18-1
- 999453 - missed a sha1 hash

* Tue Sep 10 2013 Stephen Herr <sherr@redhat.com> 2.1.17-1
- 999453 - one file removal did not make it into the original commit

* Thu Sep 05 2013 Stephen Herr <sherr@redhat.com> 2.1.16-1
- 999453 - updating sha1 hashes

* Thu Sep 05 2013 Stephen Herr <sherr@redhat.com> 2.1.15-1
- 999453 - move the rhnServerNeededView sql into the function for performance
- Revert "999453 - update rhnServerNeededView to make it easier to optimize for
  fast execution"

* Thu Aug 29 2013 Stephen Herr <sherr@redhat.com> 2.1.14-1
- 999453 - update rhnServerNeededView to make it easier to optimize for fast
  execution

* Wed Aug 21 2013 Stephen Herr <sherr@redhat.com> 2.1.13-1
- 998424 - removing bad initial condition from max(evr_t)
- Revert "998424 - rpm version comparison function was broken for alphanumeric
  versions"
- Revert "998424 - naming the file properly"
- timestamps in oracle: don't shift the dates during schema upgrades

* Tue Aug 20 2013 Stephen Herr <sherr@redhat.com> 2.1.12-1
- 998424 - naming the file properly

* Tue Aug 20 2013 Stephen Herr <sherr@redhat.com> 2.1.11-1
- 998424 - rpm version comparison function was broken for alphanumeric versions

* Tue Aug 20 2013 Tomas Lestach <tlestach@redhat.com> 2.1.10-1
- fix sha1 of 014-add-column-csv-separator.sql.postgresql
- Add a hack to allow the ';' literal in table definitions
- Allow users to change the CSV separator (schema changes)
- delete duplicates from rhnDistchannelMap
- don't insert existing values twice

* Fri Aug 09 2013 Milan Zazrivec <mzazrivec@redhat.com> 2.1.9-1
- remove duplicate pairs before creating unique index

* Tue Aug 06 2013 Tomas Lestach <tlestach@redhat.com> 2.1.8-1
- fixing sha1 of upgrade/spacewalk-schema-2.0-to-spacewalk-
  schema-2.1/013-log.sql

* Tue Aug 06 2013 Tomas Lestach <tlestach@redhat.com> 2.1.7-1
- name constraints on the log table

* Mon Aug 05 2013 Tomas Lestach <tlestach@redhat.com> 2.1.6-1
- changing stamp type on log table

* Wed Jul 31 2013 Simon Lukasik <slukasik@redhat.com> 2.1.5-1
- New OrgConfig attribute: period during which it is not possible to delete
  scan

* Fri Jul 26 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.4-1
- fixed upgrade file names

* Thu Jul 25 2013 Tomas Lestach <tlestach@redhat.com> 2.1.3-1
- recreate logging triggers after we change the logging table column types

* Wed Jul 24 2013 Tomas Lestach <tlestach@redhat.com> 2.1.2-1
- fix oracle equivalent source sha1
- fix_f624b843
- extract logging.recreate_trigger from logging.enable_logging
- replace integer with number/ric in logging package
- change log_id type on logged tables
- change log table integer -> number

* Tue Jul 23 2013 Michael Mraka <michael.mraka@redhat.com> 2.1.1-1
- 876019 - schema upgrade scripts
- made serverchannels cursor properly parametrized
- 876019 - fixed misplaced end loop

