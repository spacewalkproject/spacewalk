-- oracle equivalent source sha1 121938bc647a6a71742bfd0bcf5254afbf93133a
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnChannelPermissionRole.sql
create or replace function rhn_cperm_role_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_cperm_role_mod_trig
before insert or update on rhnChannelPermissionRole
for each row
execute procedure rhn_cperm_role_mod_trig_fun();
