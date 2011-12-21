-- created by Oraschemadoc Wed Dec 21 14:59:56 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SRV_NET_IFACE_MOD_TRIG" 
before insert or update on rhnServerNetInterface
for each row
begin
		if :new.id is null then
	        select rhn_srv_net_iface_id_seq.nextval into :new.id from dual;
	    end if;
        :new.modified := sysdate;
end;
ALTER TRIGGER "SPACEWALK"."RHN_SRV_NET_IFACE_MOD_TRIG" ENABLE
 
/
