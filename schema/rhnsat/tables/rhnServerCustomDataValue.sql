--
-- $Id$
--

create table
rhnServerCustomDataValue
(
	server_id	number
			constraint rhn_scdv_sid_nn not null
			constraint rhn_scdv_sid_fk
				references rhnServer(id),
	key_id		number
			constraint rhn_scdv_kid_nn not null
			constraint rhn_scdv_kid_fk
				references rhnCustomDataKey(id),
	value		varchar2(4000),  -- nullable?
	created_by	number
			constraint rhn_scdv_cb_fk
				references web_contact(id)
				on delete set null,
	last_modified_by number
			constraint rhn_scdv_lmb_fk
				references web_contact(id)
				on delete set null,
	created		date default (sysdate)
			constraint rhn_scdv_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_scdv_modified_nn not null	
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;
	
create unique index rhn_scdv_sid_kid_uq
	on rhnServerCustomDataValue(server_id, key_id);

create index rhn_scdv_kid_sid_idx
	on rhnServerCustomDataValue(key_id, server_id);

create or replace trigger
rhn_scdv_mod_trig
before insert or update on rhnServerCustomDataValue
for each row
begin
	:new.modified := sysdate;
end;
/
show errors


-- $Log$
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
