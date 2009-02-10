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

create sequence rhn_kstree_id_seq;

create table
rhnKickstartableTree
(
	id		numeric not null
			constraint rhn_kstree_id_pk primary key,
        org_id          numeric
                        constraint rhn_kstree_oid_fk
                                references web_customer(id)
				on delete cascade,
	label		varchar(64) not null,
	base_path	varchar(256) not null,
	channel_id	numeric not null
			constraint rhn_kstree_cid_fk
				references rhnChannel(id),
        cobbler_id      varchar(64),
        cobbler_xen_id  varchar(64),
	boot_image	varchar(128) default('spacewalk-koan'),
        kstree_type     numeric not null
                        constraint rhn_kstree_kstreetype_fk
                                references rhnKSTreeType(id),
        install_type    numeric not null
                        constraint rhn_kstree_it_fk
                                references rhnKSInstallType(id),
	last_modified	timestamp default (current_timestamp) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
			constraint rhn_kstree_oid_label_uq unique ( org_id, label )
--       		using index  tablespace [[8m_tbs]]
)
  ;

/*create or replace trigger
rhn_kstree_mod_trig
before insert or update on rhnKickstartableTree
for each row
begin
     if (:new.last_modified = :old.last_modified) or 
        (:new.last_modified is null ) then
             :new.last_modified := sysdate;
     end if;

	:new.modified := sysdate;
end rhn_kstree_mod_trig;
/
show errors
*/

create index rhn_kstree_id_pk
	on rhnKickstartableTree( id )
--	tablespace [[4m_tbs]]
  ;

--
--
-- Revision 1.9  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.8  2004/10/29 05:20:37  pjones
-- bugzilla: 136513 -- fix the unique constraint on rhnKickstartableTree
--
-- Revision 1.7  2004/09/15 20:00:51  pjones
-- bugzilla: none -- typo fix.
--
-- Revision 1.6  2004/09/14 21:54:23  pjones
-- bugzilla: 131738 -- add last_modified and fix trigger appropriately.
--
-- Revision 1.5  2003/12/12 18:00:42  rnorwood
-- bugzilla: 111701 - schema and editing of kickstart tree defaults - also 'installer type' for dists.
--
-- Revision 1.4  2003/12/10 16:45:32  cturner
-- bugzilla: 111706, add org_id to kickstartable trees, as well as go ahead and make a treetype table.  part one, the sql
--
-- Revision 1.3  2003/10/09 22:17:50  pjones
-- bugzilla: 106718
-- add rhnActionKickstart
--
-- Revision 1.2  2003/10/03 16:32:58  pjones
-- bugzilla: none
--
-- typo fix
--
-- Revision 1.1  2003/10/02 14:31:56  pjones
-- lla: none
--
-- schema to keep track of what channels go with what files on our disks
--
