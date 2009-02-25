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
-- this table holds the types for saved searches

create table
rhnSavedSearchType
(
	id		numeric
			constraint rhn_sstype_id_pk primary key,
	label		varchar(8)
			not null
                        constraint rhn_sstype_label_uq unique ,
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create sequence rhn_sstype_id_seq;

create index rhn_sstype_id_label_idx
	on rhnSavedSearchType(id,label)
--	tablespace [[64k_tbs]]
  ;
create index rhn_sstype_label_id_idx
	on rhnSavedSearchType(label,id)
--	tablespace [[64k_tbs]]
  ;

insert into rhnSavedSearchType (id, label)
	values (nextval('rhn_sstype_id_seq'), 'system');
insert into rhnSavedSearchType (id, label)
	values (nextval('rhn_sstype_id_seq'), 'package');
insert into rhnSavedSearchType (id, label)
	values (nextval('rhn_sstype_id_seq'), 'errata');

--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/15 20:51:26  pjones
-- add saved search schema
--
