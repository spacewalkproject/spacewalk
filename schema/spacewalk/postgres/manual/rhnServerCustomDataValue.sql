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

create table
rhnServerCustomDataValue
(
	server_id	numeric
			not null
			constraint rhn_scdv_sid_fk
			references rhnServer(id),
	key_id		numeric
			not null
			constraint rhn_scdv_kid_fk
			references rhnCustomDataKey(id),
	value		varchar(4000),  -- nullable?
	created_by	numeric
			constraint rhn_scdv_cb_fk
			references web_contact(id)
			on delete set null,
	last_modified_by numeric
			constraint rhn_scdv_lmb_fk
			references web_contact(id)
			on delete set null,
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null,
                        constraint rhn_scdv_sid_kid_uq
                        unique(server_id, key_id)	
)
  ;
	
create index rhn_scdv_kid_sid_idx
	on rhnServerCustomDataValue(key_id, server_id);

/*
create or replace trigger
rhn_scdv_mod_trig
before insert or update on rhnServerCustomDataValue
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/

--
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2003/09/22 04:58:17  bretm
-- bugzilla:  103654
--
-- be pickier about custom value deletion... don't have a cascade delete on key_id
--
-- Revision 1.2  2003/09/08 19:58:29  pjones
-- bugzilla: 103650
--
-- Minor cleanups and added triggers.
--
-- Revision 1.1  2003/09/03 15:19:39  bretm
-- bugzilla:  75121
--
-- 1st pass at schema for custom server data values
--
