--
-- $Id$
--
-- XXX should be dev only, exclude sat
-- EXCLUDE: all

-- a server's up2date config options

create table
rhnServerClientOptions
(
	server_id	number
			constraint rhn_server_clientopts_sid_nn not null
			constraint rhn_server_clientopts_sid_fk
				references rhnServer(id)
				on delete cascade,
	option_id	number
			constraint rhn_server_clientopts_oid_nn not null
			constraint rhn_server_clientopts_oid_fk
				references rhnClientConfigOption(id),
	value		varchar2(4000)
			constraint rhn_server_clientopts_val_nn not null,
	created		date default(sysdate)
			constraint rhn_sclientopts_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_sclientopts_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_sclientopts_sid_oid_uq
	on rhnServerClientOptions(server_id, option_id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;

create or replace trigger
rhn_server_clientopts_mod_trig
before insert or update on rhnServerClientOptions
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
-- Revision 1.2  2002/05/09 04:39:33  gafton
-- - exclude from satellite
-- - use proper tablespace nomenclature
--
-- Revision 1.1  2002/04/17 19:05:44  pjones
-- proof of concept stuff for bretm
--
