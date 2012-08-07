-- oracle equivalent source sha1 e6d93d5d850bd26fe55f8f1fe5ddae8c36227c6b


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


