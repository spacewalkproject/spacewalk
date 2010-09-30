-- oracle equivalent source sha1 7de58348cdc962a76bede6a565f3d1a19c67672a
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelFamily.sql
create or replace function rhn_channel_family_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_channel_family_mod_trig
before insert or update on rhnChannelFamily
for each row
execute procedure rhn_channel_family_mod_trig_fun();
