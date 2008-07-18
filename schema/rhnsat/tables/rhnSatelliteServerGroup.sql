--
-- $Id$
--

create table
rhnSatelliteServerGroup
(
	server_id		number
				constraint rhn_satsg_sid_nn not null
				constraint rhn_satsg_sid_fk
					references rhnSatelliteInfo(server_id)
					on delete cascade,
	server_group_type	number
				constraint rhn_satsg_sgtype_nn not null
				constraint rhn_satsg_sgtype_fk
					references rhnServerGroupType(id),
	max_members		number,
	created			date default(sysdate)
				constraint rhn_satsg_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_satsg_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_satsg_sid_sgt_uq
	on rhnSatelliteServerGroup( server_id, server_group_type )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_satsg_mod_trig
before insert or update on rhnSatelliteServerGroup
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/10/21 19:35:19  pjones
-- bugzilla: 107200 -- rhnSatelliteServerGroup now, so we can handle
-- arbitrary server group entitlements for satellite
--
