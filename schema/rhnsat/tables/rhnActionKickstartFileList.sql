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
-- $Id$
--

create table
rhnActionKickstartFileList
(
	action_ks_id		number
				constraint rhn_actionksfl_aksid_nn not null
				constraint rhn_actionksfl_askid_fk
					references rhnActionKickstart(id)
					on delete cascade,
	file_list_id		number
				constraint rhn_actionksfl_flid_nn not null
				constraint rhn_actionksfl_flid_fk
					references rhnFileList(id)
					on delete cascade,
	created			date default (sysdate)
				constraint rhn_actionksfl_creat_nn not null,
	modified		date default (sysdate)
				constraint rhn_actionksfl_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_actionksfl_aksid_flid_uq
	on rhnActionKickstartFileList( action_ks_id, file_list_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_actionksfl_flid_idx
	on rhnActionKickstartFileList( file_list_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_actionksfl_mod_trig
before insert or update on rhnActionKickstartFileList 
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.2  2004/05/28 03:47:57  misa
-- typo
--
-- Revision 1.1  2004/05/27 22:59:34  pjones
-- bugzilla: none -- rhnActionKickstartFileList, so we can find what KSData
-- the filelist comes from on an action.  I need a bug for this...
--
