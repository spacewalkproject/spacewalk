-- oracle equivalent source sha1 7ba6c364101eda268023cf983fd09df4c4635a37

create or replace function rhn_clientcap_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_clientcap_mod_trig
before insert or update on rhnClientCapability
for each row
execute procedure rhn_clientcap_mod_trig_fun();
