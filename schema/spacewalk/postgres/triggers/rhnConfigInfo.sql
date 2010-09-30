-- oracle equivalent source sha1 ab05538db127e3471a2e0d26008a9e53d7985996
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnConfigInfo.sql
create or replace function rhn_confinfo_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_confinfo_mod_trig
before insert or update on rhnConfigInfo
for each row
execute procedure rhn_confinfo_mod_trig_fun();
