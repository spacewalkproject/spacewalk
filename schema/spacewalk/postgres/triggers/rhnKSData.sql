-- oracle equivalent source sha1 98f0e19ebde15ed58e55cc79d8c47fa74c94d452
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKSData.sql
create or replace function rhn_ks_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ks_mod_trig
before insert or update on rhnKSData
for each row
execute procedure rhn_ks_mod_trig_fun();

