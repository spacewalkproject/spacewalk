-- created by Oraschemadoc Thu Jan 20 13:57:32 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_ERRATA_CVE_MOD_TRIG" 
before insert or update on rhnErrataCVE
for each row
begin
	:new.modified := sysdate;
end rhn_errata_cve_mod_trig;
ALTER TRIGGER "SPACEWALK"."RHN_ERRATA_CVE_MOD_TRIG" ENABLE
 
/
