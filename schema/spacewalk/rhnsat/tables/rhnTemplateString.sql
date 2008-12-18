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

create sequence rhn_template_str_id_seq;

create table
rhnTemplateString
(
	id		number
			constraint rhn_template_str_id_nn not null,
	category_id	number
			constraint rhn_template_str_cid_nn not null
			constraint rhn_template_str_cid_fk
				references rhnTemplateCategory(id),
	label		varchar2(64)
			constraint rhn_template_str_key_nn not null,
	value		varchar2(4000),
	description	varchar2(512)
			constraint rhn_template_str_desc_nn not null,
	created		date default(sysdate)
			constraint rhn_template_str_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_template_str_modified_nn not null
)
	enable row movement
  ;

create index rhn_template_str_icl_idx
	on rhnTemplateString ( id, category_id, label )
	tablespace [[4m_tbs]]
  ;
alter table rhnTemplateString add constraint rhn_template_str_id_pk
	primary key ( id );

create index rhn_template_str_cid_label_idx
	on rhnTemplateString ( category_id, label )
	tablespace [[2m_tbs]]
  ;
alter table rhnTemplateString add constraint rhn_template_str_cid_label_uq
	unique ( category_id, label );

create or replace trigger
rhn_template_str_mod_trig
before insert or update on rhnTemplateString
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.2  2003/02/11 18:20:49  pjones
-- added pk
-- key -> label
-- new index ( id, category_id, label )
-- value is 4k now.
--
-- Revision 1.1  2003/02/11 16:56:48  pjones
-- add string templating
--
