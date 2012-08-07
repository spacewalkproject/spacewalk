-- oracle equivalent source sha1 d4d873431f9a413fe47969a735254f60163b2810

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

