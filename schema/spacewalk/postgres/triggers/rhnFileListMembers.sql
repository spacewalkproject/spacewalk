-- oracle equivalent source sha1 69e4ad8d7ab0f3409f9b0ec866535380f9374169
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnFileListMembers.sql
create or replace function rhn_flmembers_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_flmembers_mod_trig
before insert or update on rhnFileListMembers
for each row
execute procedure rhn_flmembers_mod_trig_fun();
