--
-- $Id$
--

create table rhnSNPServerQueue
(
    	server_id       number
	    	    	constraint rhn_sec_np_sid_nn not null
	    	    	constraint rhn_sec_np_sid_fk
				references rhnServer(id),
	processed	number default(0)
			constraint rhn_sec_np_processed_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

-- to support deleting.
create index rhn_sec_np_sid_idx
	on rhnSNPServerQueue( server_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.8  2004/03/04 20:23:28  pjones
-- bugzilla: none -- diffs from dev and qa
--
-- Revision 1.7  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
