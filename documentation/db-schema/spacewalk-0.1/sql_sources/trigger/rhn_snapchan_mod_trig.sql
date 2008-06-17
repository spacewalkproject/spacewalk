-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_SNAPCHAN_MOD_TRIG" 
before insert or update on rhnSnapshotChannel
for each row
begin
	update rhnSnapshot set modified = sysdate where id = :new.snapshot_id;
end;
ALTER TRIGGER "RHNSAT"."RHN_SNAPCHAN_MOD_TRIG" ENABLE
 
/
