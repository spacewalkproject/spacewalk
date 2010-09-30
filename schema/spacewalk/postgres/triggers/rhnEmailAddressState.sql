-- oracle equivalent source sha1 5a3ab7016e0964ce90e01a2ebc2b7c545b49a140
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnEmailAddressState.sql
create or replace function rhn_eastate_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_eastate_mod_trig
before insert or update on rhnEmailAddressState
for each row
execute procedure rhn_eastate_mod_trig_fun();


