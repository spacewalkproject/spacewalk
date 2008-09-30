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
	id		number
			constraint rhn_erratafiletmp_id_nn not null,
	errata_id       number
			constraint rhn_erratafiletmp_errata_nn not null
			constraint rhn_erratafiletmp_errata_fk
				references rhnErrataTmp(id)
				on delete cascade,
	type		number
			constraint rhn_erratafiletmp_type_nn not null
			constraint rhn_erratafiletmp_type_fk
				references rhnErrataFileType(id),
	md5sum		varchar2(64)
			constraint rhn_erratafiletmp_md5_nn not null,
	filename	varchar2(128)
			constraint rhn_erratafiletmp_name_nn not null,
	created		date default(sysdate)
			constraint rhn_erratafiletmp_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_erratafiletmp_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_erratafiletmp_id_idx
	on rhnErrataFileTmp ( id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileTmp add constraint rhn_erratafiletmp_id_pk
	primary key ( id );

create index rhn_erratafiletmp_eid_file_idx
	on rhnErrataFileTmp ( errata_id, filename )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataFileTmp add constraint rhn_erratafiletmp_eid_file_uq
	unique ( errata_id, filename );

create or replace trigger
rhn_erratafiletmp_mod_trig
before insert or update on rhnErrataFileTmp
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.3  2003/08/14 20:01:13  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.2  2003/03/11 16:02:57  pjones
-- get rid of rhn_erratafiletmp_id_seq; we should use rhn_erratafile_id_seq
--
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
