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

create sequence rhn_reltype_id_seq;

create table
rhnRelationshipType
(
	id			number
				constraint rhn_reltype_id_nn not null,
	label			varchar2(32)
				constraint rhn_reltype_label_nn not null,
	description		varchar2(256),
	created			date default(sysdate)
				constraint rhn_reltype_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_reltype_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_reltype_id_label_idx
	on rhnRelationshipType ( id, label )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnRelationshipType add constraint rhn_reltype_id_pk
	primary key ( id );

create index rhn_reltype_label_id_idx
	on rhnRelationshipType ( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnRelationshipType add constraint rhn_reltype_label_uq
	unique ( label );

create or replace trigger
rhn_reltype_mod_trig
before insert or update on rhnRelationshipType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
			
-- $Log$
-- Revision 1.1  2003/03/03 17:11:58  pjones
-- progeny relationships for channel and errata
--
