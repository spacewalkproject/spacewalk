-- oracle equivalent source sha1 732bb52724d32225435820d54811a07f96bc5ff6

create or replace function rhn_confinfo_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_confinfo_mod_trig
before insert or update on rhnConfigInfo
for each row
execute procedure rhn_confinfo_mod_trig_fun();
