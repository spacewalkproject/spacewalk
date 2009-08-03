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
-- data for the entitlement poll
--

-- we don't have a great way to exclude 'entitlement_run_me' on satellite.
-- no big deal though, it just won't get used.
insert into rhnDaemonState values ('entitlement_run_me',sysdate-1000);
insert into rhnDaemonState values ('email_engine',sysdate-1000);
insert into rhnDaemonState values ('payloader_engine',sysdate-1000);
insert into rhnDaemonState values ('pushed_users',sysdate-1000);
commit;

--
-- Revision 1.2  2003/01/24 16:18:50  pjones
-- fix initial inserts here too
--
-- Revision 1.1  2003/01/13 22:59:03  pjones
-- rhnDaemonState population and grants/synonyms
--
