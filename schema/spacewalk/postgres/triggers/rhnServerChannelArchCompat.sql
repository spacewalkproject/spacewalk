create or replace function rhn_sc_ac_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sc_ac_mod_trig
before insert or update on rhnServerChannelArchCompat
for each row
execute procedure rhn_sc_ac_mod_trig_fun();

