
-- $Id$

-- supports adding arbitrary text to a message.  will allow in the future for 
-- user -> user messages?
create table
rhnTextMessage
(
	message_id	number
			constraint rhn_tm_message_id_nn not null
			constraint rhn_tm_message_id_fk
				references rhnMessage(id)
				on delete cascade,
	message_body	varchar2(4000) -- the contents of the message
			constraint rhn_tm_message_body_nn not null,
	created		date default (sysdate)
			constraint rhn_tm_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_tm_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_tm_mod_trig
before insert or update on rhnTextMessage
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/08/13 19:17:59  pjones
-- cascades
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
