--
-- $Id$
--
-- capabilities the client supports
--
-- The bug says:
--   For the capability exchange feature, the database needs to be
--   able to store capabilities for clients and potentially the server itself.
--   For now, this simple client table appears to contain the columns
--   server_id, capability, value.
--
-- I don't remember anybody ever agreeing on a format, so I'll let you 
-- guys fight it out ;)
--

create table
rhnClientCapability
(
	server_id	number
			constraint rhn_clientcap_sid_nn not null
			constraint rhn_clientcap_sid_fk
				references rhnServer(id),
	capability_name_id	number
			constraint rhn_clientcap_cap_nid_nn not null
			constraint rhn_clientcap_cap_nid_fk
				references rhnClientCapabilityName(id),
	version		varchar2(32)
			constraint rhn_clientcap_ver_nn not null,
	created		date default(sysdate)
			constraint rhn_clientcap_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_clientcap_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_clientcap_sid_cap_uq
	on rhnClientCapability(server_id, capability_name_id)
	tablespace [[32m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_clientcap_mod_trig
before insert or update on rhnClientCapability
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.5  2004/10/13 21:55:45  pjones
-- bugzilla: 135569 -- add missing foreign key constraint
--
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2003/07/29 14:40:28  pjones
-- bugzilla: none
-- rhnClientCapability.server_id needed an on delete cascade
--
-- Revision 1.2  2003/07/21 22:11:44  misa
-- bugzilla: none  More normalization; s/value/version/
--
-- Revision 1.1  2003/07/07 20:14:48  pjones
-- bugzilla: 90354
--
-- add client capability tables.
--
