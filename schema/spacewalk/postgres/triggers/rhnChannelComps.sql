

create or replace function rhn_channelcomps_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        if new.last_modified = old.last_modified then
		new.last_modified := current_timestamp;
        end if;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_channelcomps_mod_trig
before insert or update on rhnChannelComps
for each row
execute procedure rhn_channelcomps_mod_trig_fun();

