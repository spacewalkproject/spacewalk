-- oracle equivalent source sha1 2282f8fbcd7b6378b881388d7ccbab862e4f71c9
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnServer.sql
create or replace function rhn_server_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;
        return new;
end;
$$ language plpgsql;

create trigger
rhn_server_mod_trig
before insert or update on rhnServer
for each row
execute procedure rhn_server_mod_trig_fun();

