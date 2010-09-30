-- oracle equivalent source sha1 22b1074528177a0dbdb435162840dd543cf2573d
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnErrataBuglistTmp.sql

create or replace function rhn_errata_buglisttmp_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_buglisttmp_mod_trig
before insert or update on rhnErrataBuglistTmp
for each row
execute procedure rhn_errata_buglisttmp_mod_trig_fun();


