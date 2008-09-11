-- Indexes for the rhnServerPackageObj table
-- they are in a separate file to speed up the import process
--
-- $Id

create index rhn_sp_snep_idx on
        rhnServerPackage(server_id, name_id, evr_id, package_arch_id)
	parallel 6
        tablespace [[128m_tbs]]
	storage ( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.13  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.12  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.11  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
