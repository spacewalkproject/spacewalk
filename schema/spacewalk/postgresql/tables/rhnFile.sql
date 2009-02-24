--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

create table
rhnFile
(
	id		numeric
			not null
			constraint rhn_file_id_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	org_id		numeric
			constraint rhn_file_oid_fk
			references web_customer(id)
			on delete cascade,
	file_size	numeric
			not null,
	md5sum		varchar(64)
			not null,
	path		varchar(1000)
			not null
                        constraint rhn_file_path_uq unique
--                      using tablespace [[2m_tbs]]
                        ,
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create sequence rhn_file_id_seq;

--
--
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
