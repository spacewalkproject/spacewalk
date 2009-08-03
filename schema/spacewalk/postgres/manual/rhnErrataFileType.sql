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
-- The types of files associated with an errata... normal, RPM, SRPM...?

create sequence rhn_erratafile_type_id_seq;

create table
rhnErrataFileType
(
	id		numeric not null,
	label		varchar(128) not null,
	constraint rhn_erratafile_type_id_pk primary key ( id ),
	constraint rhn_erratafile_type_label_uq unique ( label )
)
  ;
	
create index rhn_erratafile_type_id_idx
	on rhnErrataFileType ( id )
--	tablespace [[64k_tbs]]
  ;

create index rhn_erratafile_type_label_idx
	on rhnErrataFileType ( label )
--	tablespace [[64k_tbs]]
  ;

