-- created by Oraschemadoc Mon Aug 31 10:54:37 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM1"."RHN_CHANNEL_ACCESS_TRIG" 
after update on rhnChannel
for each row
begin
   if :old.channel_access = 'protected' and
      :new.channel_access != 'protected'
   then
      delete from rhnChannelTrust where channel_id = :old.id;
   end if;
end;
ALTER TRIGGER "MIM1"."RHN_CHANNEL_ACCESS_TRIG" ENABLE
 
/
