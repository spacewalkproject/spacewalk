-- oracle equivalent source sha1 b889c485d0f111024a30ea9352fd23b0bd493d2f
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartIPRange.sql

create or replace function rhn_ksip_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksip_mod_trig
before insert or update on rhnKickstartIPRange
for each row
execute procedure rhn_ksip_mod_trig_fun();


