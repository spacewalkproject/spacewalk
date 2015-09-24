--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
        :new.modified := current_timestamp;
        :new.login_uc := UPPER(:new.login);
        IF inserting THEN
        INSERT INTO web_contact_all (id, org_id, login)
            VALUES (:new.id, :new.org_id, :new.login);
        END IF;

end;
/
show errors
