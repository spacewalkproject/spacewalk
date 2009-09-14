-- created by Oraschemadoc Mon Aug 31 10:54:40 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."WEB_USER_SI_TIMESTAMP" 
before insert or update on web_user_site_info
for each row
begin
  :new.email_uc := upper(:new.email);
  :new.modified := sysdate;
end;
ALTER TRIGGER "MIM1"."WEB_USER_SI_TIMESTAMP" ENABLE
 
/
