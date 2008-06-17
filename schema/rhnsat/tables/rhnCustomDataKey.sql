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

create sequence rhn_cdatakey_id_seq;

create table
rhnCustomDataKey
(
	id		number
			constraint rhn_cdatakey_id_nn not null
			constraint rhn_cdatakey_pk primary key,
	org_id		number
			constraint rhn_cdatakey_oid_nn not null
			constraint rhn_cdatakey_oid_fk
			     references web_customer(id)
			     on delete cascade,
	label		varchar2(64)
			constraint rhn_cdatakey_label_nn not null,
	description	varchar2(4000)
			constraint rhn_cdatakey_desc_nn not null,
	created_by	number
			constraint rhn_cdatakey_cb_fk
			     references web_contact(id)
			     on delete set null,
	last_modified_by number
			constraint rhn_cdatakey_lmb_fk
				references web_contact(id)
				on delete set null,
	created		date default (sysdate)
			constraint rhn_cdatakey_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_cdatakey_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;
	
create index rhn_cdatakey_oid_label_id_idx
	on rhnCustomDataKey(org_id, label, id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnCustomDataKey add constraint rhn_cdatakey_oid_label_uq
	unique ( org_id, label );

create or replace trigger
rhn_cdatakey_mod_trig
before insert or update on rhnCustomDataKey
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
	
-- $Log$
-- Revision 1.4  2004/09/13 21:16:44  pjones
-- bugzilla: 132308 -- make index/constraint include org_id
--
-- Revision 1.3  2003/09/08 19:58:29  pjones
-- bugzilla: 103650
--
-- Minor cleanups and added triggers.
--
-- Revision 1.2  2003/09/08 13:28:09  bretm
-- bugzilla:  103650
--
-- need a seqence for key ids
--
-- Revision 1.1  2003/09/03 15:19:39  bretm
-- bugzilla:  75121
--
-- 1st pass at schema for custom server data values
--
