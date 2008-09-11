--
-- $Id$
--

create table
rhnPackageSense
(
	id		number
			constraint rhn_pkg_sense_id_nn not null
			constraint rhn_pkg_sense_id_pk primary key
			using index tablespace [[64k_tbs]],
	label		varchar2(32)
			constraint rhn_pkg_sense_label_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_pkg_sense_label_uq
	on rhnPackageSense(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.6  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
