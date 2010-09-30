-- oracle equivalent source sha1 fbd949e8c1e7b738ef7c265dd60683a60f727e4d
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnVersionInfo.sql
create or replace function rhn_versioninfo_mod_trig_fun() returns trigger as
$$
begin
	new.modified = current_timestamp;

 	return new;
end;
$$ language plpgsql;

create trigger
rhn_versioninfo_mod_trig
before insert or update on rhnVersionInfo
for each row
execute procedure rhn_versioninfo_mod_trig_fun();


