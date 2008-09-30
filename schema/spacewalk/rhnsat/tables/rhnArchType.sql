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

create sequence rhn_archtype_id_seq;

create table
rhnArchType
(
	id		number
			constraint rhn_archtype_id_nn not null
			constraint rhn_archtype_id_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(64)
			constraint rhn_archtype_label_nn not null,
	name		varchar2(128)
			constraint rhn_archtype_name_nn not null,
	created		date default(sysdate)
			constraint rhn_archtype_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_archtype_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_archtype_label_id_idx
	on rhnArchType( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnArchType add constraint rhn_archtype_label_uq unique ( label );

create or replace trigger
rhn_archtype_mod_trig
before insert or update on rhnArchType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
