-- oracle equivalent source sha1 40ee010426c1cdd24b07550cd5c8da6dbc68e313
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnKickstartCommand.sql
create or replace function rhn_kscommand_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
        return new;
end;
$$ language plpgsql;

create trigger
rhn_kscommand_mod_trig
before insert or update on rhnKickstartCommand
for each row
execute procedure rhn_kscommand_mod_trig_fun();


