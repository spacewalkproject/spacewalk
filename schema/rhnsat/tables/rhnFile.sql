--
-- $Id$
--

create table
rhnFile
(
	id		number
			constraint rhn_file_id_nn not null
			constraint rhn_file_id_pk primary key
				using index tablespace [[64k_tbs]],
	org_id		number
			constraint rhn_file_oid_fk
				references web_customer(id)
				on delete cascade,
	file_size	number
			constraint rhn_file_fs_nn not null,
	md5sum		varchar2(64)
			constraint rhn_file_md5sum_nn not null,
	path		varchar2(1000)
			constraint rhn_file_path_nn not null,
	created		date default(sysdate)
			constraint rhn_file_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_file_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_file_id_seq;

create unique index rhn_file_path_uq
	on rhnFile(path)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.8  2003/07/25 14:56:13  misa
-- bugzilla: 98748  Dropping constraint
--
-- Revision 1.7  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.4  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.3  2001/12/27 18:22:01  pjones
-- policy change: foreign keys to other users' tables now _always_ go to
-- a synonym.  This makes satellite schema (where web_contact is in the same
-- namespace as rhn*) easier.
--
-- Revision 1.2  2001/07/25 22:56:20  pjones
-- more correct unqiueness
--
-- Revision 1.1  2001/07/25 03:59:20  pjones
-- this adds rhnFile, which represents the actual file for a source rpm
--
