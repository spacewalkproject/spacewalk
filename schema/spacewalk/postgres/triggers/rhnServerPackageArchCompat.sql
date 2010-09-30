-- oracle equivalent source sha1 8b0f04f1d7dca88d76c92fd16c20372e7b3a2813
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerPackageArchCompat.sql
create or replace function rhn_sp_ac_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sp_ac_mod_trig
before insert or update on rhnServerPackageArchCompat
for each row
execute procedure rhn_sp_ac_mod_trig_fun();


