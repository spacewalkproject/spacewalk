-- oracle equivalent source sha1 d6d002d49290933b0948f1377a2f7a748604f937
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/triggers/rhnActivationKey.sql
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
