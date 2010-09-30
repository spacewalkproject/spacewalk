-- oracle equivalent source sha1 a7fa1820b9ea84a70b06015a13e2f96b9cd5b942
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnOrgEntitlementType.sql
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

