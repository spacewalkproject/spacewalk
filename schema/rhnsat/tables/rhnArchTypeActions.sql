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
rhnArchTypeActions
(
	arch_type_id	number
			constraint rhn_archtypeacts_atid_nn not null
			constraint rhn_archtypeacts_atid_fk
				references rhnArchType(id),
	action_style	varchar2(64)
			constraint rhn_archtypeacts_as_nn not null,
	action_type_id	number
			constraint rhn_archtypeacts_actid_nn not null
			constraint rhn_archtypeacts_actid_fk
				references rhnActionType(id),
	created		date default(sysdate)
			constraint rhn_archtypeacts_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_archtypeacts_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_archtypeacts_atid_as_uq
	on rhnArchTypeActions( arch_type_id, action_style )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_archtypeacts_mod_trig
before insert or update on rhnArchTypeActions
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/02/13 19:38:37  pjones
-- bugzilla: 115515 -- add table to make arch types and an action label to
-- action names
--
