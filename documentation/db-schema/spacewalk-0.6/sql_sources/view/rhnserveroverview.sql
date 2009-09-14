-- created by Oraschemadoc Mon Aug 31 10:54:33 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNSERVEROVERVIEW" ("ORG_ID", "SERVER_ID", "SERVER_NAME", "NOTE_COUNT", "MODIFIED", "SERVER_ADMINS", "GROUP_COUNT", "CHANNEL_ID", "CHANNEL_LABELS", "HISTORY_COUNT", "SECURITY_ERRATA", "BUG_ERRATA", "ENHANCEMENT_ERRATA", "OUTDATED_PACKAGES", "LAST_CHECKIN_DAYS_AGO", "LAST_CHECKIN", "PENDING_UPDATES", "OS", "RELEASE", "SERVER_ARCH_NAME", "LOCKED") AS 
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
    NVL(( select C.name
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
    ( select sysdate - checkin from rhnServerInfo where server_id = S.id ),
    ( select TO_CHAR(checkin, 'YYYY-MM-DD HH24:MI:SS') from rhnServerInfo where server_id = S.id ),
    ( select count(1)
        from rhnServerAction
       where server_id = S.id
         and status in (0, 1)),
    os,
    release,
    ( select name from rhnServerArch where id = s.server_arch_id),
    NVL((select 1 from rhnServerLock SL WHERE SL.server_id = S.id), 0)
from
    rhnServer S
 
/
