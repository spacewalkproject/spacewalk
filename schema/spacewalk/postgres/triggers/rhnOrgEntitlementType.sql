create or replace function rhn_org_ent_type_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_org_ent_type_mod_trig
before insert or update on rhnOrgEntitlementType
for each row
execute procedure rhn_org_ent_type_mod_trig_fun();

