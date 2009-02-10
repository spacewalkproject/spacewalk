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
rhnSnapshotPackage
(
	snapshot_id		numeric
				constraint rhn_snapshotpkg_sid_fk
				references rhnSnapshot(id)
				on delete cascade
				not null,
	nevra_id		numeric
				constraint rhn_snapshotpkg_nid_fk
				references rhnPackageNevra(id)
				not null,
                                constraint rhn_snapshotpkg_sid_nid_uq
                                unique( snapshot_id, nevra_id )
--                              using index tablespace [[32m_tbs]]
)
 ;

create index rhn_snapshotpkg_sid
    	on rhnSnapshotPackage( snapshot_id )
--	tablespace [[8m_tbs]]
  ;

/*
create or replace trigger
rhn_snapshotpkg_mod_trig
before insert or update on rhnSnapshotPackage
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
/
show errors
*/
--
--
-- Revision 1.6  2004/01/20 16:44:05  pjones
-- bugzilla: none -- foreign keys aren't here, nobody knows why not.
--
-- Revision 1.5  2003/09/30 14:07:06  pjones
-- bugzilla: none
-- wrong index tablespace name
--
-- Revision 1.4  2003/09/26 21:14:10  pjones
-- bugzilla: none
--
-- missing storage parameters
--
-- Revision 1.3  2003/09/26 17:53:40  cturner
-- fix typos and thinkos for the qa push
--
-- Revision 1.2  2003/09/19 16:23:00  bretm
-- bugzilla:  103957
--
-- was getting full table scans on rhnSnapshotPackage w/out this index...
--
-- Revision 1.1  2003/09/15 21:01:08  pjones
-- bugzilla: none
--
-- tables for snapshot support; still need to write the code to build a snapshot
-- from a working system, but that's pretty simple.
--
