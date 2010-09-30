-- oracle equivalent source sha1 12be68cd158f67a316e9b914718b05c7cf43d513
-- retrieved from ./1241102873/cdc6d42049bf86fbc9f1d3a5c54275eeacbd641d/schema/spacewalk/oracle/triggers/rhnServerInstallInfo.sql

create or replace function rhn_s_inst_info_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_s_inst_info_mod_trig
before insert or update on rhnServerInstallInfo
for each row
execute procedure rhn_s_inst_info_mod_trig_fun();


