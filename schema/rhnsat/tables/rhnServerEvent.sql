
-- $Id$

-- information about a server event
create table
rhnServerEvent
(
	id		number
			constraint rhn_se_id_nn not null
			constraint rhn_se_id_pk primary key
				using index tablespace [[64k_tbs]],
	server_id	number
			constraint rhn_se_server_id_nn not null
			constraint rhn_se_server_id_fk
			       references rhnServer(id),
	details 	varchar2(4000)
			constraint rhn_se_details_nn not null,
	created		date default (sysdate)
			constraint rhn_se_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_se_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_se_idx
	on rhnServerEvent(server_id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;

create sequence rhn_se_id_seq;

create or replace trigger
rhn_se_mod_trig
before insert or update on rhnServerEvent
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
-- Revision 1.3  2002/08/14 22:07:48  cturner
-- add index on server_id to avoid full table locks when someone tries to delete a server
--
-- Revision 1.2  2002/08/13 19:17:58  pjones
-- cascades
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
