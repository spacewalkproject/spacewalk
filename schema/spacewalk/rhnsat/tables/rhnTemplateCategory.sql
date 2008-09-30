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

create sequence rhn_template_cat_id_seq;

create table
rhnTemplateCategory
(
	id		number
			constraint rhn_template_cat_id_nn not null,
	label		varchar2(64)
			constraint rhn_template_cat_label_nn not null,
	description	varchar2(512)
			constraint rhn_template_cat_desc_nn not null,
	created		date default(sysdate)
			constraint rhn_template_cat_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_template_cat_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_template_cat_id_idx
	on rhnTemplateCategory ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnTemplateCategory add constraint rhn_template_cat_id_pk
	primary key ( id );
create index rhn_template_cat_label_id_idx
	on rhnTemplateCategory ( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnTemplateCategory add constraint rhn_template_cat_label_uq
	unique ( label );

create or replace trigger
rhn_template_cat_mod_trig
before insert or update on rhnTemplateCategory
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/02/11 16:56:48  pjones
-- add string templating
--
