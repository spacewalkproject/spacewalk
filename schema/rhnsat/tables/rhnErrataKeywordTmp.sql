-- $Id$
--

create table
rhnErrataKeywordTmp
(
	errata_id       number
			constraint rhn_err_keywordtmp_eid_nn not null
			constraint rhn_err_keywordtmp_eid_fk
				references rhnErrataTmp(id)
				on delete cascade,
	keyword		varchar2(64),
	created		date default(sysdate)
			constraint rhn_err_keywordtmp_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_err_keywordtmp_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_err_keywordtmp_eid_uq
	on rhnErrataKeywordTmp(keyword,errata_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_errkwtmp_eid_idx
	on rhnErrataKeywordTmp(errata_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_errata_keywordtmp_mod_trig
before insert or update on rhnErrataKeywordTmp
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.9  2003/08/19 14:51:51  uid2174
-- bugzilla: 102263
--
-- indices
--
-- Revision 1.8  2003/08/14 20:01:14  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.7  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.6  2002/05/23 17:58:07  pjones
-- gdk says this stuff shouldn't be excluded now, so it isn't.
--
-- Revision 1.5  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.4  2002/05/09 05:40:41  gafton
-- more progress getting satellite schema valid
--
-- Revision 1.3  2002/04/16 20:41:08  pjones
-- more wrong fks
--
-- Revision 1.2  2002/04/01 21:45:24  pjones
-- index and constraint names i missed the first go round
--
-- Revision 1.1  2002/04/01 21:39:24  pjones
-- tmp errata tables
--
-- Revision 1.8  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.7  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.6  2001/07/05 20:09:18  pjones
-- reformat
-- naming convention
--
-- Revision 1.5  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.4  2001/07/01 06:16:56  gafton
-- named constraints, dammit.
--
-- Revision 1.3  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.2  2001/06/27 02:18:12  pjones
-- triggers
--
-- Revision 1.1  2001/06/27 01:46:05  pjones
-- initial checkin

