--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
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
    ( select sysdate - checkin from rhnServerInfo where server_id = S.id ),
    ( select TO_CHAR(checkin, 'YYYY-MM-DD HH24:MI:SS') from rhnServerInfo where server_id = S.id ),
    ( select count(1) 
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

