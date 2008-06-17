-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_CHANNELCOMPS_MOD_TRIG" 
before insert or update on rhnChannelComps
for each row
begin
    :new.modified := sysdate;
    if :new.last_modified = :old.last_modified
    then
        :new.last_modified := sysdate;
        end if;
end rhn_channelcomps_mod_trig;
ALTER TRIGGER "RHNSAT"."RHN_CHANNELCOMPS_MOD_TRIG" ENABLE
 
/
