-- oracle equivalent source sha1 26fe9163f7ac67cc7468d7a6560d82dbd829a417
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnOrgEntitlements.sql
create or replace function rhn_org_ent_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_org_ent_mod_trig
before insert or update on rhnOrgEntitlements
for each row
execute procedure rhn_org_ent_mod_trig_fun();

