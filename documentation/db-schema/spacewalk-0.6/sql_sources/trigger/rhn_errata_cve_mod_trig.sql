-- created by Oraschemadoc Mon Aug 31 10:54:38 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_ERRATA_CVE_MOD_TRIG" 
before insert or update on rhnErrataCVE
for each row
begin
	:new.modified := sysdate;
end rhn_errata_cve_mod_trig;
ALTER TRIGGER "MIM1"."RHN_ERRATA_CVE_MOD_TRIG" ENABLE
 
/
