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

create sequence rhn_sproftype_id_seq;

create table
rhnServerProfileType
(
	id		numeric
			not null
			constraint rhn_sproftype_id_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	label		varchar(64)
			not null
                        constraint rhn_sproftype_label_uq
                        unique,
	name		varchar(64)
			not null,
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create index rhn_sproftype_label_id_idx
	on rhnServerProfileType( label, id )
--	tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_sproftype_mod_trig
before insert or update on rhnServerProfileType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
