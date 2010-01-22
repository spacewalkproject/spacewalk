-- created by Oraschemadoc Fri Jan 22 13:41:02 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."RHN_USER_GROUP_ORG_MAPPING" 
BEFORE INSERT OR UPDATE ON rhnUserGroupMembers
FOR EACH ROW
DECLARE
        same_org        NUMBER;
BEGIN
        same_org := 0;
        SELECT 1 INTO same_org
          FROM web_contact U, rhnUserGroup UG
         WHERE UG.org_id = U.org_id
           AND U.id = :new.user_id
           AND UG.id = :new.user_group_id;

        IF same_org = 0 THEN
          rhn_exception.raise_exception('ugm_different_orgs');
        END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
          rhn_exception.raise_exception('ugm_different_orgs');
END;
ALTER TRIGGER "MIM_H1"."RHN_USER_GROUP_ORG_MAPPING" ENABLE
 
/
