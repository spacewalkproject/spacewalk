-- created by Oraschemadoc Fri Mar  2 05:58:07 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_PACKAGE_MOD_TRIG" 
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

        -- bz 619337 if we are updating the checksum, we need to
        -- update the last modified time on all the channels the package is in
        if :new.checksum_id != :old.checksum_id then
            update rhnChannel
              set last_modified = sysdate
              where id in (select channel_id
                              from rhnChannelPackage
                              where package_id = :new.id);
            insert into rhnRepoRegenQueue (id, CHANNEL_LABEL, REASON)
                   (select rhn_repo_regen_queue_id_seq.nextval, C.label, 'checksum modification'
                    from rhnChannel C inner join
                         rhnChannelPackage CP on CP.channel_id = C.id
                    where CP.package_id = :new.id);
            delete from rhnPackageRepodata where package_id = :new.id;
        end if;

end;
ALTER TRIGGER "SPACEWALK"."RHN_PACKAGE_MOD_TRIG" ENABLE
 
/
