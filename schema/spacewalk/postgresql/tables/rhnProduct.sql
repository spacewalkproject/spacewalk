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

create sequence rhn_product_id_seq start with 101;

create table
rhnProduct
(
	id		numeric
                 	constraint rhn_product_id_pk primary key,
	label		varchar(128)
			not null
                        constraint rhn_product_label_uq unique,
	name		varchar(128)
			not null
                        constraint rhn_product_name_uq unique,
	product_line_id	numeric
        		not null 
			constraint rhn_product_cat_fk
			references rhnProductLine(id)
			on delete cascade,
	last_modified	date default (current_date)
			not null,
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null
)
  ;

create index rhn_product_id_idx
	on rhnProduct(id)
--	tablespace [[64k_tbs]]
  ;

create index rhn_product_label_idx
	on rhnProduct(label)
--	tablespace [[64k_tbs]]
  ;

create index rhn_product_name_idx
	on rhnProduct(name)
--	tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_product_mod_trig
before insert or update on rhnProduct
for each row
begin
	:new.modified := sysdate;
	:new.last_modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
