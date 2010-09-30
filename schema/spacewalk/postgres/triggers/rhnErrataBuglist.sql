-- oracle equivalent source sha1 617c692df7e250b3b93b11e22603d5b1a172e9d3
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnErrataBuglist.sql
create or replace function rhn_errata_buglist_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_errata_buglist_mod_trig
before insert or update on rhnErrataBuglist
for each row
execute procedure rhn_errata_buglist_mod_trig_fun();

