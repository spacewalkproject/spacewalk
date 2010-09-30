-- oracle equivalent source sha1 87d2aad4188f326d6f937f9a26606c67b23c8a2c
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartDefaultRegToken.sql
create or replace function rhn_ksdrt_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksdrt_mod_trig
before insert or update on rhnKickstartDefaultRegToken
for each row
execute procedure rhn_ksdrt_mod_trig_fun();

