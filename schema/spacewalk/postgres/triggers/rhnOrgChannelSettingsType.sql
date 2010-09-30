-- oracle equivalent source sha1 0ca668156ba0d181464ea0455a0d4a920f6eeb47
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnOrgChannelSettingsType.sql
create or replace function rhn_orgcsettings_type_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_orgcsettings_type_mod_trig
before insert or update on rhnOrgChannelSettingsType
for each row
execute procedure rhn_orgcsettings_type_mod_trig_fun();

