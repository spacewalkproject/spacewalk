-- oracle equivalent source sha1 31266e6dd103671c0b224d5055461a0c5db3040e
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnClientCapability.sql
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
