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
rhnSnapshotTag
(
	snapshot_id	numeric
			not null
			constraint rhn_st_ssid_fk
				references rhnSnapshot(id)
				on delete cascade,
	tag_id          numeric
			not null
			constraint rhn_st_tid_fk
				references rhnTag(id),
	server_id	numeric
			constraint rhn_st_sid_fk
				references rhnServer(id),
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null,
                        constraint rhn_ss_tag_ssid_tid_uq 
                        unique(snapshot_id, tag_id),
                        constraint rhn_ss_tag_sid_tid_uq
                        unique(server_id, tag_id)
)
  ;
	
create index rhn_ss_tag_tid_ssid_idx
    	on rhnSnapshotTag(tag_id, snapshot_id);

create index rhn_ss_tag_tid_sid_idx
    	on rhnSnapshotTag(tag_id, server_id);


/*
create or replace trigger
rhn_ss_tag_mod_trig
before insert or update on rhnSnapshotTag
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.2  2003/10/16 14:23:33  bretm
-- bugzilla:  107189
--
-- o  added server_id to rhnSnapshotTag
-- o  added lookup_tag(org_id, tagname)
--
-- Revision 1.1  2003/10/15 20:29:53  bretm
-- bugzilla:  107189
--
-- 1st pass at snapshot tagging schema
--
