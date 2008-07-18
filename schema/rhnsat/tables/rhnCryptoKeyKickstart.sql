--
-- $Id$
--

create table
rhnCryptoKeyKickstart
(
	crypto_key_id	number
			constraint rhn_ckey_ks_ckid_nn not null
			constraint rhn_ckey_ks_ckid_fk
				references rhnCryptoKey(id)
				on delete cascade,
        ksdata_id number
                        constraint rhn_ckey_ks_ksd_nn not null
                        constraint rhn_ckey_ks_ksd_fk
                                references rhnKSData(id)
				on delete cascade
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_ckey_ks_uq
	on rhnCryptoKeyKickstart(crypto_key_id, ksdata_id)
	tablespace [[4m_tbs]]
	storage( freelists 16 )
	initrans 32;

create index rhn_ckey_ks__ckuq
	on rhnCryptoKeyKickstart(ksdata_id, crypto_key_id)
	tablespace [[4m_tbs]]
	storage( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.1  2003/11/15 20:28:24  cturner
-- bugzilla: 109898, schema to associate cryptokeys with kickstarts
--
