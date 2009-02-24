create or replace rhn_efilec_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_efilec_mod_trig
before insert or update on rhnErrataFileChannel
for each row
execute procedure rhn_efilec_mod_trig_fun();
