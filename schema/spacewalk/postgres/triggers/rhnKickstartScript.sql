-- oracle equivalent source sha1 0493d2488968aa7075394b3bbeb224df106e4dc0
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartScript.sql
create or replace function rhn_ksscript_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_ksscript_mod_trig
before insert or update on rhnKickstartSession
for each row
execute procedure rhn_ksscript_mod_trig_fun();


