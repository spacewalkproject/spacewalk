-- oracle equivalent source sha1 580e55e0f2147c74e5a4071f72b7d27906f7f8ae

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

