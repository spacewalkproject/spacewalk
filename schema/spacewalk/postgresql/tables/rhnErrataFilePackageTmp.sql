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
rhnErrataFilePackageTmp
(
	package_id	numeric not null 
			constraint rhn_efileptmp_pid_fk
				references rhnPackage(id)
				on delete cascade,
	errata_file_id	numeric not null
			constraint rhn_efileptmp_fileid_fk
				references rhnErrataFileTmp(id)
				on delete cascade,
	created		date default (current_date) not null,
	modified	date default (current_date) not null,
	constraint rhn_efileptmp_efid_uq unique ( errata_file_id )
)
;


create index rhn_efileptmp_efid_pid_idx
	on rhnErrataFilePackageTmp( errata_file_id, package_id )
--	tablespace [[2m_tbs]]
  ;

create index rhn_efileptmp_pid_idx
	on rhnErrataFilePackageTmp ( package_id )
--	tablespace [[2m_tbs]]
  ;
