-- created by Oraschemadoc Thu Jan 20 13:58:22 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SRV_NET_IFACE_MOD_TRIG" 
before insert or update on rhnServerNetInterface
for each row
begin
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SRV_NET_IFACE_MOD_TRIG" ENABLE
 
/
