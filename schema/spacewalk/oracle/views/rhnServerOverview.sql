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


--
-- Revision 1.21  2003/10/23 17:12:36  cturner
-- get locked state into rhnServerOverview
--
-- Revision 1.20  2002/11/14 20:26:31  cturner
-- I am a dumbass; it was not an id
--
-- Revision 1.19  2002/11/14 20:15:39  cturner
-- be consistent; server_arch_id not server_arch
--
-- Revision 1.18  2002/11/14 17:20:34  pjones
-- arch -> *_arch_id and archCompat changes
--
-- Revision 1.17  2002/06/03 18:35:07  cturner
-- fix for bug 58264
--
-- Revision 1.16  2001/12/03 18:35:56  cturner
-- fix view for odd case of same nvre in multiple channels for differing errata
--
-- Revision 1.15  2001/11/28 20:23:30  cturner
-- show last checkin on entitlement page, too
--
-- Revision 1.14  2001/10/28 04:28:13  cturner
-- moving towards hiding servergroups with a specific type, in favor of task-oriented lists.
--
-- Revision 1.13  2001/10/25 09:48:26  cturner
-- mods to server overview view
--
-- Revision 1.12  2001/08/09 23:47:54  cturner
-- push script changes
--
-- Revision 1.11  2001/07/31 00:17:40  cturner
-- fix for history table change
--
-- Revision 1.10  2001/07/28 23:30:55  cturner
-- outdated package column in server list... whew
--
-- Revision 1.9  2001/07/25 23:04:20  cturner
-- new column on rhnServerOverview -- whether the server is entitled
--
-- Revision 1.8  2001/07/07 13:03:39  cturner
-- better overview
--
-- Revision 1.7  2001/07/04 06:55:33  cturner
-- fixing broken server overview view.  syntax errors.
--
-- Revision 1.6  2001/07/02 21:12:18  gafton
-- more formatting
--
-- Revision 1.5  2001/07/02 21:10:50  gafton
-- format so it fits on a damn page printout
--
-- Revision 1.4  2001/06/29 08:30:53  cturner
-- more underscore changes, plus switching from rhnUser to web_contact.  may switch back later, but avoiding synonyms and such seems to make things cleaner
--
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
