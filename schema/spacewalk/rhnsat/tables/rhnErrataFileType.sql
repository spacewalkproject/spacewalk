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
	id		number
			constraint rhn_erratafile_type_id_nn not null,
	label		varchar2(128)
			constraint rhn_erratafile_type_label_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;
	
create index rhn_erratafile_type_id_idx
	on rhnErrataFileType ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileType add constraint rhn_erratafile_type_id_pk
	primary key ( id );

create index rhn_erratafile_type_label_idx
	on rhnErrataFileType ( label )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileType add constraint rhn_erratafile_type_label_uq
	unique ( label );
-- $Log$
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
