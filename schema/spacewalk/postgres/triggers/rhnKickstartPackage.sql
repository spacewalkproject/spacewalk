-- oracle equivalent source sha1 e2308db9b015b3ed34d6cb32819692b322f35009
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartPackage.sql
create or replace function rhn_kspackage_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_kspackage_mod_trig
before insert or update on rhnKickstartPackage
for each row
execute procedure rhn_kspackage_mod_trig_fun();


