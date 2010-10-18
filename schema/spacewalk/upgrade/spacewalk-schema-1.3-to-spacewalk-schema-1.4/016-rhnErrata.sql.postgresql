-- oracle equivalent source sha1 39fa9a29a144cc3a44e19a6db4190dbd0e469dcc
--
-- Copyright (c) 2010 Novell, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
--
drop view IF EXISTS rhnVisServerGroupOverviewLite;
drop view IF EXISTS rhnServerOverview;
drop view IF EXISTS rhnServerErrataTypeView;
drop view IF EXISTS rhnServerGroupOVLiteHelper;
drop view IF EXISTS rhnServerOutdatedPackages;
drop view IF EXISTS rhnServerGroupOverview;
drop view IF EXISTS rhnServerNeededPackageView;
drop view IF EXISTS rhnVisServerGroupOverview;

ALTER TABLE rhnErrata ALTER advisory_name type varchar(100);
ALTER TABLE rhnErrata ALTER advisory type varchar(100);
ALTER TABLE rhnErrata ADD    errata_from varchar(127);

CREATE OR REPLACE VIEW rhnServerErrataTypeView
(
	server_id,
	errata_id,
	errata_type
)
AS
SELECT
	SNEC.server_id,
	SNEC.errata_id,
	E.advisory_type
FROM    rhnErrata E,
		rhnServerNeededErrataCache SNEC
WHERE   E.id = SNEC.errata_id
GROUP BY SNEC.server_id, SNEC.errata_id, E.advisory_type
;

create or replace view
rhnServerGroupOVLiteHelper as
select	sgm.server_group_id						as server_group_id,
		e.advisory_type							as advisory_type
from	rhnErrata								e,
		rhnServerNeededPackageCache				snpc,
		rhnServerGroupMembers					sgm
where   sgm.server_id = snpc.server_id
	and snpc.errata_id = e.id
;

CREATE OR REPLACE VIEW
rhnServerOutdatedPackages
(
    server_id,
    package_name_id,
    package_evr_id,
    package_nvre,
    errata_id,
    errata_advisory
)
AS
SELECT DISTINCT SNPC.server_id,
       P.name_id,
       P.evr_id,
       PN.name || '-' || evr_t_as_vre_simple( PE.evr ),
       E.id,
       E.advisory
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackage P,
       rhnServerNeededPackageCache SNPC
         left outer join
        rhnErrata E
          on SNPC.errata_id = E.id
 WHERE SNPC.package_id = P.id
   AND P.name_id = PN.id
   AND P.evr_id = PE.id;

CREATE OR REPLACE VIEW rhnServerGroupOverview (
         ORG_ID, SECURITY_ERRATA, BUG_ERRATA, ENHANCEMENT_ERRATA, GROUP_ID, GROUP_NAME, GROUP_ADMINS, SERVER_COUNT, NOTE_COUNT, MODIFIED, MAX_MEMBERS
)
AS
  SELECT SG.org_id,
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededPackageCache SNPC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Security Advisory'
                 and snpc.errata_id = e.id
                 and snpc.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededPackageCache SNPC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Bug Fix Advisory'
                 and snpc.errata_id = e.id
                 and snpc.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         (SELECT COUNT(distinct E.id)
            FROM rhnErrata E,
                 rhnServerNeededPackageCache SNPC,
                 rhnServerGroupMembers SGM
           WHERE E.advisory_type = 'Product Enhancement Advisory'
                 and snpc.errata_id = e.id
                 and snpc.server_id = sgm.server_id
                 and sgm.server_group_id = sg.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         SG.id, SG.name,
         (SELECT COUNT(*) FROM rhnUserManagedServerGroups UMSG WHERE UMSG.server_group_id = SG.id),
         (SELECT COUNT(*) FROM rhnServerGroupMembers SGM WHERE SGM.server_group_id = SG.id
                 AND EXISTS ( SELECT 1
                              FROM rhnServerFeaturesView SFV
                              WHERE SFV.server_id = SGM.server_id
                                    AND SFV.label = 'ftr_system_grouping')),
         cast(0 as bigint), CURRENT_TIMESTAMP, MAX_MEMBERS
    FROM rhnServerGroup SG;

CREATE OR REPLACE VIEW
rhnServerNeededPackageView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id
)
AS
SELECT   S.org_id,
         S.id,
	  (SELECT EP.errata_id
	     FROM rhnErrataPackage EP,
	          rhnChannelErrata CE,
		  rhnServerChannel SC
	    WHERE SC.server_id = S.id
	      AND SC.channel_id = CE.channel_id
	      AND CE.errata_id = EP.errata_id
	      AND EP.package_id = P.id
	    LIMIT 1),
	 P.id,
	 P.name_id
FROM
	 rhnPackage P,
	 rhnServerPackageArchCompat SPAC,
	 rhnPackageEVR P_EVR,
	 rhnPackageEVR SP_EVR,
	 rhnServerPackage SP,
	 rhnChannelPackage CP,
	 rhnServerChannel SC,
         rhnServer S
WHERE
		 SC.server_id = S.id
  AND  	 SC.channel_id = CP.channel_id
  AND    CP.package_id = P.id
  AND    p.package_arch_id = spac.package_arch_id
  AND    spac.server_arch_id = s.server_arch_id
  AND    SP_EVR.id = SP.evr_id
  AND    P_EVR.id = P.evr_id
  AND    SP.server_id = S.id
  AND    SP.name_id = P.name_id
  AND    SP.evr_id != P.evr_id
  AND    SP_EVR.evr < P_EVR.evr
  AND    SP_EVR.evr = (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND SP2.name_id = SP.name_id)
;

CREATE OR REPLACE VIEW rhnVisServerGroupOverview (
         ORG_ID, SECURITY_ERRATA, BUG_ERRATA, ENHANCEMENT_ERRATA, GROUP_ID, GROUP_NAME, GROUP_ADMINS, SERVER_COUNT, NOTE_COUNT, MODIFIED, MAX_MEMBERS
)
AS
  SELECT SG.org_id,
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Security Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Bug Fix Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Product Enhancement Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
	 SG.id, SG.name,
	 (SELECT COUNT(*) FROM rhnUserManagedServerGroups UMSG WHERE UMSG.server_group_id = SG.id),
	 (SELECT COUNT(*) FROM rhnServerGroupMembers SGM WHERE SGM.server_group_id = SG.id),
	 cast(0 as bigint), current_timestamp, MAX_MEMBERS
    FROM rhnVisibleServerGroup SG;

create or replace view
rhnServerOverview
(
    org_id,
    server_id,
    server_name,
    note_count,
    modified,
    server_admins,
    group_count,
    channel_id,
    channel_labels,
    history_count,
    security_errata,
    bug_errata,
    enhancement_errata,
    outdated_packages,
    config_files_with_differences,
    last_checkin_days_ago,
    last_checkin,
    pending_updates,
    os,
    release,
    server_arch_name,
    locked
)
as
select
    s.org_id, s.id, s.name, 0, s.modified,
    ( select count(user_id) from rhnUserServerPerms ap
      where server_id = s.id ),
    ( select count(server_group_id) from rhnVisibleServerGroupMembers
      where server_id = s.id ),
    ( select C.id
        from rhnChannel C,
         rhnServerChannel SC
       where SC.server_id = S.id
         and SC.channel_id = C.id
     and C.parent_channel IS NULL),
    coalesce(( select C.name
        from rhnChannel C,
         rhnServerChannel SC
       where SC.server_id = S.id
         and SC.channel_id = C.id
     and C.parent_channel IS NULL), '(none)'),
    ( select count(id) from rhnServerHistory
      where
            server_id = S.id),
    ( select count(*) from rhnServerErrataTypeView setv
      where
            setv.server_id = s.id
        and setv.errata_type = 'Security Advisory'),
    ( select count(*) from rhnServerErrataTypeView setv
      where
            setv.server_id = s.id
        and setv.errata_type = 'Bug Fix Advisory'),
    ( select count(*) from rhnServerErrataTypeView setv
      where
            setv.server_id = s.id
        and setv.errata_type = 'Product Enhancement Advisory'),
    ( select count(distinct p.name_id) from rhnPackage p, rhnServerNeededPackageCache snpc
      where
             snpc.server_id = S.id
     and p.id = snpc.package_id
     ),
    ( select count(*)
        from rhnActionConfigRevision ACR
             INNER JOIN rhnActionConfigRevisionResult ACRR on ACR.id = ACRR.action_config_revision_id
       where ACR.server_id = S.id
         and ACR.action_id = (
              select MAX(rA.id)
                from rhnAction rA
                     INNER JOIN rhnServerAction rSA on rSA.action_id = rA.id
                     INNER JOIN rhnActionStatus rAS on rAS.id = rSA.status
                     INNER JOIN rhnActionType rAT on rAT.id = rA.action_type
               where rSA.server_id = S.id
                 and rAS.name in ('Completed', 'Failed')
                 and rAT.label = 'configfiles.diff'
         )
         and ACR.failure_id is null
         and ACRR.result is not null
        ),
    ( select date_diff_in_days(checkin, current_timestamp) from rhnServerInfo where server_id = S.id ),
    ( select TO_CHAR(checkin, 'YYYY-MM-DD HH24:MI:SS') from rhnServerInfo where server_id = S.id ),
    ( select count(1)·
        from rhnServerAction
       where server_id = S.id
         and status in (0, 1)),
    os,
    release,
    ( select name from rhnServerArch where id = s.server_arch_id),
    coalesce((select 1 from rhnServerLock SL WHERE SL.server_id = S.id), 0)
from
    rhnServer S
;

create or replace view
rhnVisServerGroupOverviewLite as
select  sg.org_id                                       as org_id,
                case when exists (
                        select  1
                        from    rhnServerGroupOVLiteHelper
                        where   server_group_id = sg.id
                                and advisory_type = 'Security Advisory'
                        )
                        then 1
                        else 0
                        end                                             as security_errata,
                case when exists (
                        select  1
                        from    rhnServerGroupOVLiteHelper
                        where   server_group_id = sg.id
                                and advisory_type = 'Bug Fix Advisory'
                        )
                        then 1
                        else 0
                        end                                             as bug_errata,
                case when exists (
                        select  1
                        from    rhnServerGroupOVLiteHelper
                        where   server_group_id = sg.id
                                and advisory_type = 'Product Enhancement Advisory'
                        )
                        then 1
                        else 0
                        end                                             as enhancement_errata,
                sg.id                                           as group_id,
                sg.name                                         as group_name,
                (       select  count(*)
                        from    rhnUserManagedServerGroups      umsg
                        where   umsg.server_group_id = sg.id
                )                                                       as group_admins,
                (       select  count(*)
                        from    rhnServerGroupMembers           sgm
                        where   sgm.server_group_id = sg.id
                )                                                       as server_count,
                0                                                       as note_count,
                current_timestamp                                       as modified,
                max_members                                     as max_members
from    rhnVisibleServerGroup           sg
;
