-- oracle equivalent source sha1 ec3e38ea307866016fe73f586f55820b9642af39

create or replace function rhn_action_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_action_mod_trig
before insert or update on rhnAction
for each row
execute procedure rhn_action_mod_trig_fun();

