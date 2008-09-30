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
rhnKSTreeFile
(
	kstree_id		number
				constraint rhn_kstreefile_kid_nn not null
				constraint rhn_kstreefile_kid_fk
					references rhnKickstartableTree(id)
					on delete cascade,
	relative_filename	varchar2(256)
				constraint rhn_kstreefile_rfn_nn not null,
	md5sum			varchar2(64)
				constraint rhn_kstreefile_md5sum_nn not null,
	file_size		number
				constraint rhn_kstreefile_file_size_nn not null,
	last_modified		date default(sysdate)
				constraint rhn_kstreefile_lastmod_nn not null,
	created			date default(sysdate)
				constraint rhn_kstreefile_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_kstreefile_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_kstreefile_mod_trig
before insert or update on rhnKSTreeFile
for each row
begin
	:new.modified := sysdate;
	-- allow us to manually set last_modified if we wish
	if :new.last_modified = :old.last_modified
	then
  	    :new.last_modified := sysdate;
        end if;
end rhn_kstreefile_mod_trig;
/
show errors

create unique index rhn_kstreefile_kid_rfn_uq
	on rhnKSTreeFile ( kstree_id, relative_filename )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
--
-- Revision 1.7  2004/12/10 19:12:17  cturner
-- bugzilla: 142578
--
-- remove triggers we no longer need to avoid spurious updates of large
-- numbers of other triggers
--
-- Revision 1.6  2004/11/10 16:57:08  pjones
-- bugzilla: 137474 -- use "old" not "new" in delete triggers
--
-- Revision 1.5  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.4  2003/11/06 15:44:10  cturner
-- consistent column naming; use file_size, not filesize
--
-- Revision 1.3  2003/11/06 00:49:03  cturner
-- bugzilla: 109225, add md5sum, size, and mtime to rhnKSTreeFile entries
--
-- Revision 1.2  2003/10/02 18:24:07  pjones
-- bugzilla: none -- add on delete cascade
--
-- Revision 1.1  2003/10/02 14:31:56  pjones
-- lla: none
--
-- schema to keep track of what channels go with what files on our disks
--
