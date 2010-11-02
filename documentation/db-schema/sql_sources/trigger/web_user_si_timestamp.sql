-- created by Oraschemadoc Tue Nov  2 08:33:18 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."WEB_USER_SI_TIMESTAMP" 
before insert or update on web_user_site_info
for each row
begin
  :new.email_uc := upper(:new.email);
  :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."WEB_USER_SI_TIMESTAMP" ENABLE
 
/
