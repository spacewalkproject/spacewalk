-- oracle equivalent source sha1 28c6fa8c4416909f1f83e1b462e622a0a3f19ea2
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerDMI.sql
create or replace function rhn_server_dmi_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_server_dmi_mod_trig
before insert or update on rhnServerDMI
for each row
execute procedure rhn_server_dmi_mod_trig_fun();

