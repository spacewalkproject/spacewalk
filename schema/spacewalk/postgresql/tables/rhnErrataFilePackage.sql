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
rhnErrataFilePackage
(
	package_id	numeric not null 
			constraint rhn_efilep_pid_fk 
				references rhnPackage(id)
				on delete cascade,
	errata_file_id	numeric not null
			constraint rhn_efilep_fileid_fk
				references rhnErrataFile(id)
				on delete cascade,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
;


create index rhn_efilep_efid_pid_idx
	on rhnErrataFilePackage( errata_file_id, package_id )
--	tablespace [[2m_tbs]]
  ;
alter table rhnErrataFilePackage add constraint rhn_efilep_efid_uq
	unique ( errata_file_id );

create index rhn_efilep_pid_idx
	on rhnErrataFilePackage ( package_id )
--	tablespace [[2m_tbs]]
  ;

