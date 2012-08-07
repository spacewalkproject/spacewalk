-- oracle equivalent source sha1 4d60d3c3eb51fcd8a304c761f4411a695b417f42

create or replace function rhn_cfname_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_cfname_mod_trig
before insert or update on rhnConfigFileName
for each row
execute procedure rhn_cfname_mod_trig_fun();

