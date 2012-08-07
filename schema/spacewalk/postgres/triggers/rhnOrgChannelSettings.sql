-- oracle equivalent source sha1 efc3395c33150f995bc5efed8a26c51f360d64c8

create or replace function rhn_orgcsettings_mod_trig_fun() returns trigger as
$$
begin
       new.modified := current_timestamp;
        
       return new;
end;
$$ language plpgsql;

create trigger
rhn_orgcsettings_mod_trig
before insert or update on rhnOrgChannelSettings
for each row
execute procedure rhn_orgcsettings_mod_trig_fun();

