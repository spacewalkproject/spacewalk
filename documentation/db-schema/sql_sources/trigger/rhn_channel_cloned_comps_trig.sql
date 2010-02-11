-- created by Oraschemadoc Fri Jan 22 13:40:54 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_CHANNEL_CLONED_COMPS_TRIG"
before insert on rhnChannelCloned
for each row
begin
	-- if there are not comps in the cloned channel by now,
	-- we shall clone comps from the original channel
	insert into rhnChannelComps
		( id, channel_id, relative_filename,
			last_modified, created, modified )
	select rhn_channelcomps_id_seq.nextval, :new.id, relative_filename,
			sysdate, sysdate, sysdate
	from rhnChannelComps
	where channel_id = :new.original_id
		and not exists (
			select 1
			from rhnChannelComps x
			where x.channel_id = :new.id
		);
end;
ALTER TRIGGER "SPACEWALK"."RHN_CHANNEL_CLONED_COMPS_TRIG" ENABLE
 
/
