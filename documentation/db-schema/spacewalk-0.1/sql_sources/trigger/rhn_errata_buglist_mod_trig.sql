-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_ERRATA_BUGLIST_MOD_TRIG" 
before insert or update on rhnErrataBuglist
for each row
begin
	:new.modified := sysdate;
end rhn_errata_buglist_mod_trig;
ALTER TRIGGER "RHNSAT"."RHN_ERRATA_BUGLIST_MOD_TRIG" ENABLE
 
/
