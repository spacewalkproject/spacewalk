-- oracle equivalent source sha1 931ffaaab5efd6ccf91cb875a4effff5e80054f1
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnDevice.sql

create or replace function rhn_device_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_device_mod_trig
before insert or update on rhnDevice
for each row
execute procedure rhn_device_mod_trig_fun();


