create or replace rhn_reltype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_reltype_mod_trig
before insert or update on rhnRelationshipType
for each row
execute procedure rhn_reltype_mod_trig_fun();

