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

-- this stores the result of applying the config revision to
-- the machine specified by rhnActionConfigRevision.server_id

create table rhnActionConfigRevisionResult
(
	action_config_revision_id number
				constraint rhn_actioncfr_acrid_nn not null
				constraint rhn_actioncfr_acrid_fk
					references rhnActionConfigRevision(id)
					on delete cascade,
	result			blob,
	created			date default(sysdate)
				constraint rhn_actioncfr_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actioncfr_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_actioncfr_acrid_uq
	on rhnActionConfigRevisionResult( action_config_revision_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_actioncfr_mod_trig
before insert or update on rhnActionConfigRevisionResult
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.2  2003/11/18 19:46:19  pjones
-- bugzilla: 110354 -- make fk cascade
--
-- Revision 1.1  2003/11/09 17:15:13  pjones
-- bugzilla: 109083 -- actions need to know about config revisions
--
