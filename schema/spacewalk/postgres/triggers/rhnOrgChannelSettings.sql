-- oracle equivalent source sha1 352d421bac863c57bb20a38c89b0381eae3e4d9a
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnOrgChannelSettings.sql
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

