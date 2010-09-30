-- oracle equivalent source sha1 7782ed77c594224c04da703665fa32ca3cafaf92
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnConfigFileType.sql
create or replace function rhn_conffiletype_mod_trig_fun() returns trigger as
$$
begin
        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_conffiletype_mod_trig
before insert or update on rhnConfigFile
for each row
execute procedure rhn_conffiletype_mod_trig_fun();
