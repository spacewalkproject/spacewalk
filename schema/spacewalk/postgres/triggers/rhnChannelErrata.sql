-- oracle equivalent source sha1 9419918f3d4b3d1ffa0b71d3824e2efb24c09d77
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelErrata.sql
create or replace function rhn_channel_errata_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_channel_errata_mod_trig
before insert or update on rhnChannelErrata
for each row
execute procedure rhn_channel_errata_mod_trig_fun();
