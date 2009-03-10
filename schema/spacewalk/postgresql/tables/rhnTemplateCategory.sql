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
	id		numeric not null,
	label		varchar(64) not null,
	description	varchar(512) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
  ;

create index rhn_template_cat_id_idx
	on rhnTemplateCategory ( id )
--	tablespace [[64k_tbs]]
  ;
alter table rhnTemplateCategory add constraint rhn_template_cat_id_pk
	primary key ( id );
create index rhn_template_cat_label_id_idx
	on rhnTemplateCategory ( label, id )
--	tablespace [[64k_tbs]]
  ;
alter table rhnTemplateCategory add constraint rhn_template_cat_label_uq
	unique ( label );
/*
create or replace trigger
rhn_template_cat_mod_trig
before insert or update on rhnTemplateCategory
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.1  2003/02/11 16:56:48  pjones
-- add string templating
--
