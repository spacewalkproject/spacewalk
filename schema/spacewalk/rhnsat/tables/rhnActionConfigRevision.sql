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

create sequence rhn_actioncr_id_seq;

create table
rhnActionConfigRevision
(
	id			number
				constraint rhn_actioncr_id_nn not null
				constraint rhn_actioncr_id_pk primary key
					using index tablespace [[2m_tbs]],
	action_id		number
				constraint rhn_actioncr_aid_nn not null
				constraint rhn_actioncr_aid_fk
					references rhnAction(id)
					on delete cascade,
	server_id		number
				constraint rhn_actioncr_sid_nn not null
				constraint rhn_actioncr_sid_fk
					references rhnServer(id),
	-- we don't need the revision or the configchannel here,
	-- because they're derivable from config_revision_id
	config_revision_id	number
				constraint rhn_actioncr_crid_nn not null
				constraint rhn_actioncr_crid_fk
					references rhnConfigRevision(id)
					on delete cascade,
        failure_id              number
				constraint rhn_actioncr_failid_fk
					references rhnConfigFileFailure(id),
	created			date default(sysdate)
				constraint rhn_actioncr_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actioncr_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_actioncr_aid_sid_crid_uq
	on rhnActionConfigRevision( action_id, server_id, config_revision_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_actioncr_sid_aid_idx
	on rhnActionConfigRevision( server_id, action_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_act_cr_crid_idx
on rhnActionConfigRevision ( config_revision_id )
        tablespace [[4m_tbs]]
        storage ( freelists 16 )
        initrans 32;

create or replace trigger
rhn_actioncr_mod_trig
before insert or update on rhnActionConfigRevision
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.5  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.4  2003/11/17 14:36:03  misa
-- Adding a failure_id to store the reason for a failure
--
-- Revision 1.3  2003/11/14 20:27:57  pjones
-- bugzilla: 110082 -- these need it too (even including the one in the bug! ;)
--
-- Revision 1.2  2003/11/14 19:45:05  pjones
-- bugzilla: 110082 -- delete cascade on config_revision_id
--
-- Revision 1.1  2003/11/09 17:15:13  pjones
-- bugzilla: 109083 -- actions need to know about config revisions
--
