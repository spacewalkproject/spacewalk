-- oracle equivalent source sha1 c6ddb562712a3d45b53502ad5d9faa106171fe51
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelArch.sql

create or replace function rhn_carch_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_carch_mod_trig
before insert or update on rhnChannelArch
for each row
execute procedure rhn_carch_mod_trig_fun();
