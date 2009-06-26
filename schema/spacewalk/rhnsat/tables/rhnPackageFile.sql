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
--/

create table
rhnPackageFile
(
	package_id	number
			constraint rhn_package_file_pid_nn not null
			constraint rhn_package_file_pid_fk
				references rhnPackage(id)
                                on delete cascade,
	capability_id	number
			constraint rhn_package_file_cid_nn not null
			constraint rhn_package_file_cid_fk
				references rhnPackageCapability(id),
	device		number
			constraint rhn_package_file_devices_nn not null,
	inode		number
			constraint rhn_package_file_inode_nn not null,
	file_mode	number
			constraint rhn_package_file_mode_nn not null,
	-- No number of hard links - should we care?
	username	varchar2(32)
			constraint rhn_package_file_username_nn not null,
	groupname	varchar2(32)
			constraint rhn_package_file_groupname_nn not null,
	rdev		number
			constraint rhn_package_file_dev_nn not null,
	file_size	number
			constraint rhn_package_file_size_nn not null,
	mtime		date
			constraint rhn_package_file_mtime_nn not null,
	checksum	varchar2(128),
	linkto		varchar2(256),
	flags		number
			constraint rhn_package_file_flags_nn not null,
	verifyflags	number
			constraint rhn_package_file_verify_nn not null,
	lang		varchar2(32),
	created		date default (sysdate)
			constraint rhn_package_file_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_package_file_modified_nn not null
)
	enable row movement
  ;

create unique index rhn_package_file_pid_cid_uq
	on rhnPackageFile(package_id, capability_id)
	tablespace [[32m_tbs]]
  ;

create index rhn_package_file_cid_pid_idx
	on rhnPackageFile(capability_id, package_id)
	tablespace [[32m_tbs]]
	nologging;

create or replace trigger
rhn_packagefile_mod_trig
before insert or update on rhnPackageFile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.10  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.7  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.6  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.5  2002/02/21 16:27:20  pjones
-- rhn_ind -> [[32m_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.4  2001/09/28 15:54:31  pjones
-- typo
--
-- Revision 1.3  2001/09/24 16:42:09  pjones
-- new schema for files, new indexes as well
--
-- Revision 1.2  2001/09/13 18:47:21  pjones
-- indices
--
-- Revision 1.1  2001/09/13 18:05:29  pjones
-- new provides/requires/conflicts/obsoletes...
--

