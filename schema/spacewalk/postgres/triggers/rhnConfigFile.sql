-- oracle equivalent source sha1 fa7bc7e8704bde663177b56b20c74a8d671d2924
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnConfigFile.sql
create or replace function rhn_conffile_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_conffile_mod_trig
before insert or update on rhnConfigFile
for each row
execute procedure rhn_conffile_mod_trig_fun();
