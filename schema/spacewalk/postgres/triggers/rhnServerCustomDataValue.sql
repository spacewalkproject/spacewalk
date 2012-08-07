-- oracle equivalent source sha1 defd30f9c418cdcdc09e2612739969dc4659ef71

create or replace function rhn_scdv_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
 	return new;
end;
$$ language plpgsql;

create trigger
rhn_scdv_mod_trig
before insert or update on rhnServerCustomDataValue
for each row
execute procedure rhn_scdv_mod_trig_fun();

