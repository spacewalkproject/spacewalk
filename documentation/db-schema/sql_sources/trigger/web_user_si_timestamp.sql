-- created by Oraschemadoc Fri Jan 22 13:41:02 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."WEB_USER_SI_TIMESTAMP" 
before insert or update on web_user_site_info
for each row
begin
  :new.email_uc := upper(:new.email);
  :new.modified := sysdate;
end;
ALTER TRIGGER "MIM_H1"."WEB_USER_SI_TIMESTAMP" ENABLE
 
/
