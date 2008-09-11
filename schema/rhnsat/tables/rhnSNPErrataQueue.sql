--
-- $Id$
--

-- rhnSNPErrataQueue ==  rhnErrataUpdateQueue ?  
-- probably should rename at some point
create table rhnSNPErrataQueue
(
    	errata_id       number
	    	    	constraint rhn_snpErrQueue_eid_nn not null
	    	    	constraint rhn_snpErrQueue_eid_fk
				references rhnErrata(id)
				on delete cascade,
	processed	number default(0) -- this should get a check as well?
			constraint rhn_snpErrQueue_processed_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_snpErrQueue_eid_uq
	on rhnSNPErrataQueue(errata_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.9  2003/08/14 19:59:07  pjones
-- bugzilla: none
--
-- reformat "on delete cascade" on things that reference rhnErrata*
--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
