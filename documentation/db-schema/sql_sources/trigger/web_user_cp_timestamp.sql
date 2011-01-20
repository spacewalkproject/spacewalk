-- created by Oraschemadoc Thu Jan 20 13:58:35 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."WEB_USER_CP_TIMESTAMP" 
BEFORE INSERT OR UPDATE ON web_user_contact_permission
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
END;
ALTER TRIGGER "SPACEWALK"."WEB_USER_CP_TIMESTAMP" ENABLE
 
/
