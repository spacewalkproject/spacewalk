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
--

create or replace trigger
rhn_sg_member_mod_trig
before insert or update on rhnServerGroupMembers
for each row
begin
        :new.modified := current_timestamp;
end;
/
show errors

CREATE OR REPLACE TRIGGER
rhn_server_group_org_mapping
BEFORE INSERT OR UPDATE ON rhnServerGroupMembers
FOR EACH ROW
DECLARE
        same_org        NUMBER;
BEGIN
        same_org := 0;
        SELECT 1 INTO same_org
          FROM rhnServer S, rhnServerGroup SG
         WHERE SG.org_id = S.org_id
           AND S.id = :new.server_id
           AND SG.id = :new.server_group_id;
        IF same_org = 0 THEN
          rhn_exception.raise_exception('sgm_insert_diff_orgs');
        END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
          rhn_exception.raise_exception('sgm_insert_diff_orgs');
END;
/
SHOW ERRORS
