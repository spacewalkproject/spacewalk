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
-- triggers for rhnUserInfo updates
--

create or replace trigger
rhn_user_info_mod_trig
before insert or update on rhnUserInfo
for each row
begin
	:new.modified := sysdate;
end rhn_user_info_mod_trig;
/
show errors

--
--
-- Revision 1.3  2004/11/17 22:04:44  pjones
-- bugzilla: 134953 -- remove the wacky trigger scheme for updating timezone
-- info
--
-- Revision 1.2  2004/11/05 20:48:58  pjones
-- bugzilla: none -- triggers have to be seperated out since they're there for
-- both tables.
--
