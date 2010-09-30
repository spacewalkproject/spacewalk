-- oracle equivalent source sha1 f215c16664b471d144dbc5a19967dbd33aa10d63
-- retrieved from ./1241132947/9984c41fb98d15becf3c29432c19cd7a266dece4/schema/spacewalk/oracle/triggers/rhnChannelComps.sql


create or replace function rhn_channelcomps_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        if tg_op='UPDATE' then
          if new.last_modified = old.last_modified or
             new.last_modified is null then
		new.last_modified := current_timestamp;
          end if;
        else
          if new.last_modified is null then
		new.last_modified := current_timestamp;
          end if;
        end if;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_channelcomps_mod_trig
before insert or update on rhnChannelComps
for each row
execute procedure rhn_channelcomps_mod_trig_fun();

