-- oracle equivalent source sha1 0da653da4e7a0465dc0219ca01c3f27ac1d8f7e1
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnErrataTmp.sql
create or replace function rhn_erratatmp_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        new.last_modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_erratatmp_mod_trig
before insert or update on rhnErrataTmp
for each row
execute procedure rhn_erratatmp_mod_trig_fun();

