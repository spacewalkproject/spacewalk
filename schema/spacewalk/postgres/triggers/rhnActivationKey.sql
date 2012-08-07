-- oracle equivalent source sha1 d96b62905b49d03f534645b53b074757cdddaec0

create or replace function rhn_act_key_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_act_key_mod_trig
before insert or update on rhnActivationKey
for each row
execute procedure rhn_act_key_mod_trig_fun();
