
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


