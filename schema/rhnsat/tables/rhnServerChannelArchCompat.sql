--
-- $Id$
--

create table
rhnServerChannelArchCompat
(
        server_arch_id	number
                        constraint rhn_sc_ac_said_nn not null
                        constraint rhn_sc_ac_said_fk 
				references rhnServerArch(id),
	channel_arch_id	number
			constraint rhn_sc_ac_caid_nn not null
			constraint rhn_sc_ac_caid_fk
				references rhnChannelArch(id),
	created		date default(sysdate)
			constraint rhn_sc_ac_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_sc_ac_modified_nn not null
)
	storage( freelists 16 )
	initrans 32;

create index rhn_sc_ac_caid_paid
	on rhnServerChannelArchCompat(server_arch_id, channel_arch_id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;

create index rhn_sc_ac_paid_caid
	on rhnServerChannelArchCompat(channel_arch_id, server_arch_id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;

create or replace trigger
rhn_sc_ac_mod_trig
before insert or update on rhnServerChannelArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.6  2004/02/19 20:56:44  misa
-- Forgot to remove a line
--
-- Revision 1.5  2004/02/19 17:39:45  misa
-- Geeting rid of the server_arch_id uniqueness constraint, seems to be useless
--
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/11/14 16:25:50  misa
-- Fixing the uniqueness constraint
--
-- Revision 1.2  2002/11/14 00:36:02  misa
-- No need for preference here; added another uniqueness constraint
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
