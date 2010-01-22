-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."RHN_KSPRESERVEFL_MOD_TRIG" 
before insert or update on rhnKickstartPreserveFileList
for each row
begin
	:new.modified := sysdate;
end rhn_kspreservefl_mod_trig;
ALTER TRIGGER "MIM_H1"."RHN_KSPRESERVEFL_MOD_TRIG" ENABLE
 
/
