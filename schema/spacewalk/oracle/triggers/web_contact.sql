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

create or replace trigger
web_contact_mod_trig
before insert or update on web_contact
for each row
begin
        :new.modified := sysdate;
        :new.login_uc := UPPER(:new.login);
        IF :new.password <> :old.password THEN
                :new.old_password := :old.password;
        END IF;
end;
/
show errors

--
-- Revision 1.4  2003/05/07 14:41:48  pjones
-- this should be part of satellite
--
-- Revision 1.3  2002/05/09 17:17:39  pjones
-- move the prop stuff to it's own file and merge the others
--
-- Revision 1.2  2002/05/09 06:22:25  gafton
-- exclude this one from the satellite build
--
