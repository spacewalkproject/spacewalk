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

create sequence rhn_erratafile_id_seq;

create table
rhnErrataFile
(
	id		numeric not null constraint rhn_erratafile_id_pk
	primary key ,
	errata_id       numeric not null
			constraint rhn_erratafile_errata_fk
				references rhnErrata(id)
				on delete cascade,
	type		numeric not null
			constraint rhn_erratafile_type_fk
				references rhnErrataFileType(id),
	md5sum		varchar(64) not null,
	filename	varchar(1024)not null,
	created		date default(current_date) not null,
	modified	date default(current_date) not null,
	constraint rhn_erratafile_eid_file_uq unique ( errata_id, filename )
)
;

create index rhn_erratafile_id_idx
	on rhnErrataFile ( id )
--	tablespace [[64k_tbs]]
  ;


create index rhn_erratafile_eid_file_idx
	on rhnErrataFile ( errata_id, filename )
--	tablespace [[64k_tbs]]
  ;
