-- oracle equivalent source sha1 452523f6e7dd5e5fcb68e5dd561e762ce09a6497
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnAppInstallSessionData.sql
create or replace function rhn_appinst_sdata_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_appinst_sdata_mod_trig
before insert or update on rhnAppInstallSessionData
for each row
execute procedure rhn_appinst_sdata_mod_trig_fun();
