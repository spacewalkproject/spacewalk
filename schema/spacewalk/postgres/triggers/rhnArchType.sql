create or replace function rhn_archtype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_archtype_mod_trig
before insert or update on rhnArchType
for each row
execute procedure rhn_archtype_mod_trig_fun();

