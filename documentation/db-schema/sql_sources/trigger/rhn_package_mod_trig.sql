-- created by Oraschemadoc Fri Jan 22 13:40:59 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "MIM_H1"."RHN_PACKAGE_MOD_TRIG" 
before insert or update on rhnPackage
for each row
begin
	-- when we do a sat sync, we use last_modified to keep track
	-- of the upstream modification date.  So if we're setting
	-- it explicitly, don't override with sysdate.  But if we're
	-- not changing it, then this is a genuine update that needs
	-- tracking.
	--
	-- we're not using is_satellite() here instead, because we
	-- might want to use this to keep webdev in sync.
	if :new.last_modified = :old.last_modified then
		:new.last_modified := sysdate;
	end if;
	:new.modified := sysdate;
end;
ALTER TRIGGER "MIM_H1"."RHN_PACKAGE_MOD_TRIG" ENABLE
 
/
