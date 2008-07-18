--
-- $Id$
--

create table
rhnServerPackage
(
        server_id       number,
        name_id         number,
        evr_id          number ,
        package_arch_id number
)
	tablespace [[server_package_tablespace]]
	storage( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_server_package_id_seq;

-- $Log$
-- Revision 1.13  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.12  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
-- Revision 1.11  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.10  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
