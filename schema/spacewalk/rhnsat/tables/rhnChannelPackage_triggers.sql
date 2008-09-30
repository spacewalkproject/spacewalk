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
-- triggers for rhnChannelPackage

create or replace trigger
rhn_channel_package_mod_trig
before insert or update on rhnChannelPackage
for each row
begin
	:new.modified := sysdate;
end rhn_channel_package_mod_trig;
/
show errors


--
-- Revision 1.9  2004/11/02 16:04:30  misa
-- Missing semicolon
--
-- Revision 1.8  2004/10/29 18:11:45  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.7  2003/11/09 18:13:20  pjones
-- bugzilla: 109083 -- re-enable snapshot invalidation
--
-- Revision 1.6  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
-- Revision 1.5  2003/10/13 16:24:21  pjones
-- bugzilla: none
-- One more for the "really dumb mistakes" list.
--
-- Revision 1.4  2003/10/08 20:24:28  pjones
-- bugzilla: 106188
--
-- new packages in a channel don't cause an invalidation
--
-- Revision 1.3  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
-- Revision 1.2  2002/05/07 20:31:31  pjones
-- make these do just time updates again
--
-- Revision 1.1  2002/04/10 19:57:24  pjones
-- move triggers out of rhnChannelPackage.sql
--
