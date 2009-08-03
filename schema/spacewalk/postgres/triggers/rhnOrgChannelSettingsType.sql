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

