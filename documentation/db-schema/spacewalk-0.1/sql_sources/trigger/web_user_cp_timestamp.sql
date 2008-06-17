-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."WEB_USER_CP_TIMESTAMP" 
BEFORE INSERT OR UPDATE ON web_user_contact_permission
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
END;
ALTER TRIGGER "RHNSAT"."WEB_USER_CP_TIMESTAMP" ENABLE
 
/
