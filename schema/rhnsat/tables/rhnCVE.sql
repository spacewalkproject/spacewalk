--
-- $Id$
-- CVE/CAN strings, for use with errata.
-- See http://cve.mitre.org/
--/

CREATE TABLE
rhnCVE
(
        id              number
			constraint rhn_cve_id_nn not null
                        constraint rhn_cve_id_pk primary key
			using index tablespace [[2m_tbs]],
        name            varchar2(13) -- like:  CXX-XXXX-XXXX
			constraint rhn_cve_name_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_cve_name_uq
	on rhnCVE(name)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_cve_id_seq;

-- $Log$
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/05/20 15:39:54  pjones
-- more grants, fix typos, rename the sequence
--
-- Revision 1.1  2002/05/20 15:34:18  pjones
-- add CVE stuff for bretm/mjc
--
