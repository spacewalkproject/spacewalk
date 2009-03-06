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

-- this is which config channels a server was in when it was snapshotted

create table
rhnSnapshotConfigChannel
(
	snapshot_id		numeric not null
				constraint rhn_snapshotcc_sid_fk
					references rhnSnapshot(id)
					on delete cascade,
	config_channel_id	numeric not null
				constraint rhn_snapshotcc_ccid_fk
					references rhnConfigChannel(id),
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null,
				constraint rhn_snapshotcc_sid_ccid_uq unique ( snapshot_id, config_channel_id )
--        			using index tablespace [[4m_tbs]]
)
  ;
create index rhn_snpsht_cc_ccid_sid_idx
on rhnSnapshotConfigChannel ( config_channel_id, snapshot_id )
--        tablespace [[4m_tbs]]
  ;
/*
create or replace trigger
rhn_snapshotcc_mod_trig
before insert or update on rhnSnapshotConfigChannel
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.2  2004/01/15 21:25:50  pjones
-- bugzilla: none (Joe is filing one now, maybe?)
-- Fix deletion of snapshots
-- Fix deletion of channels once a snapshot has been taken of a server
--   in said channel
--
-- Revision 1.1  2003/11/09 17:17:19  pjones
-- bugzilla: 109083 -- keep track of which config channels the server
-- should be in
--
