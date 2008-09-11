--
-- $Id$
--

create table
rhnPackageSenseMap
(
	sense		number
			constraint rhn_pkg_sensemap_sense_nn not null,
	sense_id	number
			constraint rhn_pkg_sensemap_sid_nn not null
			constraint rhn_pkg_sensemap_sid_fk
				references rhnPackageSense(id)
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_pkg_sensemap_s_sid_uq
	on rhnPackageSenseMap(sense,sense_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
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
