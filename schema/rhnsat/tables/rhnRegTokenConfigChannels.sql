--
-- $Id$
--

create table
rhnRegTokenConfigChannels
(
	token_id		number
				constraint rhn_regtok_confchan_tid_nn not null
				constraint rhn_regtok_confchan_tid_fk
					references rhnRegToken(id)
					on delete cascade,
	config_channel_id	number
				constraint rhn_regtok_confchan_ccid_nn not null
				constraint rhn_regtok_confchan_ccid_fk
					references rhnConfigChannel(id)
					on delete cascade,
	position		number
				constraint rhn_regtok_confchan_pos_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_regtok_confchan_t_cc_uq
	on rhnRegTokenConfigChannels( token_id, config_channel_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_regtok_confchan_ccid_idx
	on rhnRegTokenConfigChannels( config_channel_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.2  2003/11/09 19:39:29  pjones
-- bugzilla: 109083 -- identifier too long
--
-- Revision 1.1  2003/11/09 19:27:41  pjones
-- bugzilla: 109083 -- get rid of namespaces
--
