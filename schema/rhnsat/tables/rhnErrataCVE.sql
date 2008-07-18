-- $Id$
-- this matches errata <-> CVE/CAN strings, if any
--
create table
rhnErrataCVE
(
	errata_id	number
			constraint rhn_err_cve_eid_nn not null
			constraint rhn_err_cve_eid_fk
				references rhnErrata(id)
				on delete cascade,
	cve_id	        number
			constraint rhn_err_cve_cid_nn not null
			constraint rhn_err_cve_cid_fk
				references rhnCVE(id),
	created		date default (sysdate)
			constraint rhn_err_cve_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_err_cve_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_errata_cve_mod_trig
before insert or update on rhnErrataCVE
for each row
begin
	:new.modified := sysdate;
end rhn_errata_cve_mod_trig;
/
show errors

create unique index rhn_err_cve_eid_cid_uq
	on rhnErrataCVE(errata_id, cve_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_err_cve_cid_eid_idx
	on rhnErrataCVE(cve_id, errata_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.7  2004/12/07 23:17:01  misa
-- bugzilla: 141768  Dropping some unused triggers
--
-- Revision 1.6  2004/11/10 16:57:08  pjones
-- bugzilla: 137474 -- use "old" not "new" in delete triggers
--
-- Revision 1.5  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.4  2003/08/14 20:01:13  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/05/20 15:39:54  pjones
-- more grants, fix typos, rename the sequence
--
-- Revision 1.1  2002/05/20 15:34:18  pjones
-- add CVE stuff for bretm/mjc
--
