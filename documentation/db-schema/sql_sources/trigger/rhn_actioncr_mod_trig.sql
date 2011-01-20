-- created by Oraschemadoc Thu Jan 20 13:56:49 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ACTIONCR_MOD_TRIG" 
before insert or update on rhnActionConfigRevision
for each row
begin
	:new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_ACTIONCR_MOD_TRIG" ENABLE
 
/
