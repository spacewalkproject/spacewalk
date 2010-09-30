-- oracle equivalent source sha1 35e14b05354a52d8ab03559a67268e146f651b75
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnRelationshipType.sql
create or replace function rhn_reltype_mod_trig_fun() returns trigger as
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

