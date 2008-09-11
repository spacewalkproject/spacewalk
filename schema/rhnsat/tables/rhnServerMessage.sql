
-- $Id$

-- ties a server to a message
create table
rhnServerMessage
(
	server_id	number
			constraint rhn_sm_server_id_nn not null
			constraint rhn_sm_server_id_fk
				references rhnServer(id),
	message_id	number
			constraint rhn_sm_message_id_nn not null
			constraint rhn_sm_message_id_fk
				references rhnMessage(id)
				on delete cascade,
	server_event	number
			constraint rhn_sm_se_fk
				references rhnServerEvent(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_sm_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_sm_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_sm_uq
	on rhnServerMessage(server_id, message_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_sm_mi_sid_uq
	on rhnServerMessage(message_id, server_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index RHN_SRVR_MSSG_SRVR_EVNT_IDX
on rhnServerMessage ( server_event )
        tablespace [[64k_tbs]]
        storage ( freelists 16 )
        initrans 32;

create or replace trigger
rhn_sm_mod_trig
before insert or update on rhnServerMessage
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.5  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/08/13 19:17:59  pjones
-- cascades
--
-- Revision 1.2  2002/08/02 19:36:02  rnorwood
-- add index to rhnServerMessage
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
