--
-- $Id$
--/

create table
rhnChannelErrata
(
	channel_id	number
			constraint rhn_ce_cid_nn not null 
			constraint rhn_ce_cid_fk
				references rhnChannel(id)
				on delete cascade,
	errata_id	number
			constraint rhn_ce_eid_nn not null
			constraint rhn_ce_eid_fk
				references rhnErrata(id)
				on delete cascade,
	created		date default (sysdate)
			constraint rhn_ce_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_ce_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_channel_errata_mod_trig
before insert or update on rhnChannelErrata
for each row
begin
	:new.modified := sysdate;
end rhn_channel_errata_mod_trig;
/
show errors



create unique index rhn_ce_ce_uq
	on rhnChannelErrata(channel_id, errata_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_ce_eid_cid_idx
	on rhnChannelErrata(errata_id, channel_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.12  2004/10/29 18:11:45  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.11  2003/08/14 20:01:13  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/20 13:34:26  pjones
-- on delete cascade for rhnChannel foreign keys
--
-- Revision 1.8  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
