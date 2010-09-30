-- oracle equivalent source sha1 7411afb8b28ccbbc3f19064e1ad470a2d3c16943
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnEmailAddress.sql
create or replace function rhn_eaddress_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_eaddress_mod_trig
before insert or update on rhnEmailAddress
for each row
execute procedure rhn_eaddress_mod_trig_fun();


