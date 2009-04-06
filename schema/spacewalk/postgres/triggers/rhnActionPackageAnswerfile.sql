create or replace function rhn_act_p_af_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;

create or replace trigger
rhn_act_p_af_mod_trig
before insert or update on rhnActionPackageAnswerfile
for each row
execute procedure rhn_act_p_af_mod_trig_fun();

