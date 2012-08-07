-- oracle equivalent source sha1 c8bf13265b96ac286b540e459a04e3bd6eb4440f

create or replace function rhn_sactionvr_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_sactionvr_mod_trig
before insert or update on rhnServerActionVerifyResult
for each row
execute procedure rhn_sactionvr_mod_trig_fun();
