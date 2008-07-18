--
-- $Id$
--

create table
rhnPublicChannelFamily
(
	channel_family_id	number
				constraint rhn_pubcf_cfid_nn not null
				constraint rhn_pubcf_cfid_fk
					references rhnChannelFamily(id),
	created			date default(sysdate)
				constraint rhn_pubcf_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_pubcf_mod_nn not null
)
	enable row movement
;

create unique index rhn_pubcf_co_uq on
	rhnPublicChannelFamily(channel_family_id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
