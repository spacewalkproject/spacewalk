-- oracle equivalent source sha1 2d45b86bdff08892e86ba86a5b1fe9cc52a48f05
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelPermission.sql
create or replace function rhn_cperm_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cperm_mod_trig
before insert or update on rhnChannelPermission
for each row
execute procedure rhn_cperm_mod_trig_fun();
