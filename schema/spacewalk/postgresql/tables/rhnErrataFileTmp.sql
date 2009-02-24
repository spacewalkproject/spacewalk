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
rhnErrataFileTmp
(
	id		numeric not null,
	errata_id       numeric not null
			constraint rhn_erratafiletmp_errata_fk
				references rhnErrataTmp(id)
				on delete cascade,
	type		numeric not null
			constraint rhn_erratafiletmp_type_fk
				references rhnErrataFileType(id),
	md5sum		varchar(64) not null,
	filename	varchar(128) not null,
	created		timestamp default(current_timestamp) not null,
	modified	timestamp default(current_timestamp) not null,
	constraint rhn_erratafiletmp_id_pk primary key ( id ),
	constraint rhn_erratafiletmp_eid_file_uq unique ( errata_id, filename )
)
;

create index rhn_erratafiletmp_id_idx
	on rhnErrataFileTmp ( id )
--	tablespace [[64k_tbs]]
  ;

create index rhn_erratafiletmp_eid_file_idx
	on rhnErrataFileTmp ( errata_id, filename )
--	tablespace [[64k_tbs]]
  ;

