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
--

create sequence rhn_ks_sessionhist_id_seq;

create table
rhnKickstartSessionHistory
(
	id			numeric
				constraint rhn_ks_sessionhist_id_pk primary key
--				using index tablespace [[8m_tbs]]
                                ,
	kickstart_session_id	numeric
				not null
				constraint rhn_ks_sessionhist_ksid_fk
				references rhnKickstartSession(id)
				on delete cascade,
        action_id               numeric
				constraint rhn_ks_sessionhist_aid_fk
				references rhnAction(id)
				on delete set null,
	state_id		numeric
				not null
				constraint rhn_ks_sessionhist_stat_fk
				references rhnKickstartSessionState(id),
	time			date default(current_date)
				not null,
	message			varchar(4000),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null
)
  ;

create index rhn_ks_sessionhist_ksid_idx
	on rhnKickstartSessionHistory( kickstart_session_id )
--	tablespace [[8m_tbs]]
        ;
/*
create or replace trigger
rhn_ks_sessionhist_mod_trig
before insert or update on rhnKickstartSessionHistory
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.3  2003/12/16 15:16:19  pjones
-- bugzilla: 111909 -- add "message" column to handle failure messages
--
-- Revision 1.2  2003/10/17 00:36:07  rnorwood
-- bugzilla: 106068 - fix status page issues.
--
-- Revision 1.1  2003/10/15 20:11:12  pjones
-- bugzilla: 106951
-- rhnKickstartSessionHistory, per robin's request
--
