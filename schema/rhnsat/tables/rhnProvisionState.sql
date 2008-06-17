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

create sequence rhn_provstate_id_seq;

create table
rhnProvisionState
(
	id		number
			constraint rhn_provstate_id_nn not null
			constraint rhn_provstate_id_pk primary key,
	label		varchar2(32)
			constraint rhn_provstate_label_nn not null,
	description	varchar2(256)
			constraint rhn_provstate_desc_nn not null,
	created		date default(sysdate)
			constraint rhn_provstate_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_provstate_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_provstate_l_id_idx
	on rhnProvisionState(label, id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnProvisionState add constraint rhn_provstate_l_uq
	unique ( label );

create or replace trigger
rhn_provstate_mod_trig
before insert or update on rhnProvisionState
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/09/05 20:45:07  pjones
-- bugzilla: 103313
--
-- schema to represent a system's provisioning state.  We still need data here.
--
